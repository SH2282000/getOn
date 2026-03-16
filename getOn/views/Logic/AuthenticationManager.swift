//
//  AuthenticationManager.swift
//  getOn
//
//  Created by Shannah on 30/11/2025.
//

import SwiftUI
import AuthenticationServices
import Combine
import CryptoKit

#if canImport(UIKit)
import UIKit
#endif

// MARK: - Server DTOs

private struct ChallengeResponse: Decodable {
    let challenge: String
    let userID: String
}

private struct AuthResponse: Decodable {
    let userID: String
    let username: String?
}

// MARK: - AuthenticationManager

class AuthenticationManager: NSObject, ObservableObject,
                             ASAuthorizationControllerDelegate,
                             ASAuthorizationControllerPresentationContextProviding {

    @Published var isAuthenticated: Bool = false
    @Published var userId: String?
    @Published var username: String?

    private static let relyingParty = "87-106-60-114.nip.io"
    private static let baseURL = "https://87-106-60-114.nip.io/geton/passkey"

    // Transient state for the in-flight ceremony
    private var pendingChallenge: String?
    private var pendingUserID: String?

    // MARK: - Presentation Anchor

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            return UIWindow()
        }
        return window
    }

    // MARK: - Public API

    /// Single entry point: passes both assertion and registration to allow sign in or account creation.
    func signIn() {
        Task {
            do {
                let resp = try await fetchChallenge()
                pendingChallenge = resp.challenge
                pendingUserID = resp.userID

                guard let challengeData = Data(base64URLEncoded: resp.challenge),
                      let userIDData = resp.userID.data(using: .utf8) else { return }

                let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(
                    relyingPartyIdentifier: Self.relyingParty
                )
                let assertion = provider.createCredentialAssertionRequest(challenge: challengeData)
                let registration = provider.createCredentialRegistrationRequest(
                    challenge: challengeData,
                    name: "getOn Account",
                    userID: userIDData
                )

                let controller = ASAuthorizationController(authorizationRequests: [assertion, registration])
                controller.delegate = self
                controller.presentationContextProvider = self
                await MainActor.run { controller.performRequests() }
            } catch {
                print("[Auth] signIn error: \(error)")
            }
        }
    }

    func signOut() {
        isAuthenticated = false
        userId = nil
        username = nil
    }

    // MARK: - Registration (fallback)

    private func register() {
        Task {
            do {
                let resp = try await fetchChallenge()
                pendingChallenge = resp.challenge
                pendingUserID = resp.userID

                guard let challengeData = Data(base64URLEncoded: resp.challenge),
                      let userIDData = resp.userID.data(using: .utf8) else { return }

                let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(
                    relyingPartyIdentifier: Self.relyingParty
                )
                let registration = provider.createCredentialRegistrationRequest(
                    challenge: challengeData,
                    name: "getOn Account",
                    userID: userIDData
                )

                let controller = ASAuthorizationController(authorizationRequests: [registration])
                controller.delegate = self
                controller.presentationContextProvider = self
                await MainActor.run { controller.performRequests() }
            } catch {
                print("[Auth] register error: \(error)")
            }
        }
    }

    // MARK: - ASAuthorizationControllerDelegate

    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        if let cred = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialRegistration {
            handleRegistration(cred)
        } else if let cred = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion {
            handleAssertion(cred)
        }
    }

    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithError error: Error) {
        if let asError = error as? ASAuthorizationError {
            switch asError.code {
            case .canceled:
                print("[Auth] User canceled")
            default:
                print("[Auth] Auth failed (\(asError.code.rawValue))")
            }
        } else {
            print("[Auth] Error: \(error.localizedDescription)")
        }
    }

    // MARK: - Handle Registration Result

    private func handleRegistration(_ cred: ASAuthorizationPlatformPublicKeyCredentialRegistration) {
        guard let challenge = pendingChallenge,
              let userID = pendingUserID else { return }

        // Extract the raw public key from the attestation object
        let rawAttestationObject = cred.rawAttestationObject ?? Data()
        let publicKeyBytes = extractPublicKey(from: rawAttestationObject)

        let body: [String: Any] = [
            "challenge": challenge,
            "credentialID": cred.credentialID.base64URLEncodedString(),
            "publicKey": publicKeyBytes.base64URLEncodedString(),
            "userID": userID,
            "username": NSNull()
        ]

        Task {
            do {
                let auth: AuthResponse = try await post(path: "/register", body: body)
                await MainActor.run {
                    self.userId = auth.userID
                    self.username = auth.username
                    self.isAuthenticated = true
                }
            } catch {
                print("[Auth] Register POST error: \(error)")
            }
        }
    }

    // MARK: - Handle Assertion Result

    private func handleAssertion(_ cred: ASAuthorizationPlatformPublicKeyCredentialAssertion) {
        guard let challenge = pendingChallenge else { return }

        let body: [String: Any] = [
            "challenge": challenge,
            "credentialID": cred.credentialID.base64URLEncodedString(),
            "userHandle": cred.userID.base64URLEncodedString(),
            "signature": cred.signature.base64URLEncodedString(),
            "authenticatorData": cred.rawAuthenticatorData.base64URLEncodedString(),
            "clientDataJSON": cred.rawClientDataJSON.base64URLEncodedString()
        ]

        Task {
            do {
                let auth: AuthResponse = try await post(path: "/authenticate", body: body)
                await MainActor.run {
                    self.userId = auth.userID
                    self.username = auth.username
                    self.isAuthenticated = true
                }
            } catch {
                print("[Auth] Authenticate POST error: \(error)")
            }
        }
    }

    // MARK: - Networking Helpers

    private func fetchChallenge() async throws -> ChallengeResponse {
        let url = URL(string: "\(Self.baseURL)/challenge")!
        let (data, resp) = try await URLSession.shared.data(from: url)
        guard let http = resp as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if http.statusCode != 200 {
            let bodyStr = String(data: data, encoding: .utf8) ?? ""
            print("[Auth] GET \(url) failed with status \(http.statusCode). Body: \(bodyStr)")
            throw URLError(URLError.Code(rawValue: http.statusCode)) // Throw the actual status code for easier debugging
        }
        
        return try JSONDecoder().decode(ChallengeResponse.self, from: data)
    }

    private func post<T: Decodable>(path: String, body: [String: Any]) async throws -> T {
        let url = URL(string: "\(Self.baseURL)\(path)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, resp) = try await URLSession.shared.data(for: request)
        guard let http = resp as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if http.statusCode != 200 {
            let bodyStr = String(data: data, encoding: .utf8) ?? ""
            print("[Auth] POST \(url) failed with status \(http.statusCode). Body: \(bodyStr)")
            throw URLError(URLError.Code(rawValue: http.statusCode)) // Throw the actual status code
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }

    // MARK: - Attestation Object Parsing

    /// Extracts the uncompressed EC public key (0x04 || x || y) from a CBOR attestation object.
    /// Falls back to returning raw bytes if parsing fails — the server will handle it.
    private func extractPublicKey(from attestationObject: Data) -> Data {
        let bytes = [UInt8](attestationObject)
        // The attestation object is CBOR: { "fmt": ..., "attStmt": ..., "authData": ... }
        // authData layout: rpIdHash(32) + flags(1) + signCount(4) + attestedCredentialData(...)
        // attestedCredentialData: aaguid(16) + credIdLen(2) + credId(credIdLen) + credentialPublicKey(CBOR)
        guard let authDataRange = findCBORByteString(for: "authData", in: bytes) else {
            return attestationObject
        }
        let authData = [UInt8](bytes[authDataRange])
        let flags = authData[32]
        let hasAttestedCred = (flags & 0x40) != 0
        guard hasAttestedCred, authData.count > 55 else { return attestationObject }

        let credIdLen = Int(authData[53]) << 8 | Int(authData[54])
        let pubKeyStart = 55 + credIdLen
        guard pubKeyStart < authData.count else { return attestationObject }

        return Data(authData[pubKeyStart...])
    }

    /// Minimal helper: find the byte range for a text key's value in a CBOR map.
    private func findCBORByteString(for key: String, in bytes: [UInt8]) -> Range<Int>? {
        guard bytes.count > 1 else { return nil }
        var i = 0
        let mapHeader = bytes[i]
        guard (mapHeader & 0xe0) == 0xa0 || mapHeader == 0xb8 || mapHeader == 0xb9 else { return nil }
        let mapCount: Int
        if (mapHeader & 0xe0) == 0xa0 {
            mapCount = Int(mapHeader & 0x1f)
            i += 1
        } else {
            return nil
        }

        for _ in 0..<mapCount {
            guard i < bytes.count else { return nil }
            // Read text string key
            let keyHeader = bytes[i]
            let keyMajor = keyHeader >> 5
            if keyMajor == 3 { // text string
                let keyLen = Int(keyHeader & 0x1f)
                i += 1
                guard i + keyLen <= bytes.count else { return nil }
                let keyStr = String(bytes: bytes[i..<(i + keyLen)], encoding: .utf8) ?? ""
                i += keyLen

                if keyStr == key {
                    // Read the value (byte string)
                    guard i < bytes.count else { return nil }
                    let valHeader = bytes[i]
                    let valMajor = valHeader >> 5
                    if valMajor == 2 { // byte string
                        let valLen: Int
                        let additional = Int(valHeader & 0x1f)
                        if additional < 24 {
                            valLen = additional
                            i += 1
                        } else if additional == 24 {
                            i += 1
                            guard i < bytes.count else { return nil }
                            valLen = Int(bytes[i])
                            i += 1
                        } else if additional == 25 {
                            i += 1
                            guard i + 2 <= bytes.count else { return nil }
                            valLen = Int(bytes[i]) << 8 | Int(bytes[i + 1])
                            i += 2
                        } else { return nil }
                        guard i + valLen <= bytes.count else { return nil }
                        return i..<(i + valLen)
                    }
                }
                // Skip value
                skipCBOR(bytes: bytes, index: &i)
            } else {
                // Skip key + value
                skipCBOR(bytes: bytes, index: &i)
                skipCBOR(bytes: bytes, index: &i)
            }
        }
        return nil
    }

    private func skipCBOR(bytes: [UInt8], index: inout Int) {
        guard index < bytes.count else { return }
        let header = bytes[index]
        let major = header >> 5
        let additional = Int(header & 0x1f)
        index += 1

        let length: Int
        if additional < 24 {
            length = additional
        } else if additional == 24 {
            guard index < bytes.count else { return }
            length = Int(bytes[index])
            index += 1
        } else if additional == 25 {
            guard index + 2 <= bytes.count else { return }
            length = Int(bytes[index]) << 8 | Int(bytes[index + 1])
            index += 2
        } else if additional == 26 {
            guard index + 4 <= bytes.count else { return }
            length = Int(bytes[index]) << 24 | Int(bytes[index + 1]) << 16 | Int(bytes[index + 2]) << 8 | Int(bytes[index + 3])
            index += 4
        } else {
            length = 0
        }

        switch major {
        case 0, 1: break
        case 2, 3: index += length
        case 4: for _ in 0..<length { skipCBOR(bytes: bytes, index: &index) }
        case 5: for _ in 0..<length { skipCBOR(bytes: bytes, index: &index); skipCBOR(bytes: bytes, index: &index) }
        default: break
        }
    }
}

// MARK: - Base64URL

private extension Data {
    init?(base64URLEncoded string: String) {
        var base64 = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let r = base64.count % 4
        if r > 0 { base64.append(String(repeating: "=", count: 4 - r)) }
        self.init(base64Encoded: base64)
    }

    func base64URLEncodedString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
