import Fluent
import Vapor
import Crypto

// MARK: - DTOs

struct ChallengeResponse: Content {
    let challenge: String      // Base64URL
    let userID: String         // Pre-generated for registration
}

struct RegisterRequest: Content {
    let challenge: String      // Base64URL
    let credentialID: String   // Base64URL
    let publicKey: String      // Base64URL (raw COSE key bytes from attestationObject)
    let userID: String
    let username: String?
}

struct AuthenticateRequest: Content {
    let challenge: String          // Base64URL
    let credentialID: String       // Base64URL
    let userHandle: String         // Base64URL (== userID)
    let signature: String          // Base64URL
    let authenticatorData: String  // Base64URL
    let clientDataJSON: String     // Base64URL
}

struct AuthResponse: Content {
    let userID: String
    let username: String?
}

// MARK: - In-memory challenge store

struct PendingChallengesKey: StorageKey {
    typealias Value = [String: Date]   // challenge -> expiry
}

// MARK: - Controller

struct PasskeyController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let passkey = routes.grouped("passkey")
        passkey.get("challenge", use: getChallenge)
        passkey.post("register", use: register)
        passkey.post("authenticate", use: authenticate)
    }

    // MARK: GET /passkey/challenge

    func getChallenge(req: Request) async throws -> ChallengeResponse {
        req.logger.info("🟢 GET /passkey/challenge reached")
        var generator = SystemRandomNumberGenerator()
        var bytes = [UInt8](repeating: 0, count: 32)
        for i in 0..<32 {
            bytes[i] = generator.next()
        }

        let challenge = Data(bytes).base64URLEncodedString()
        let userID = UUID().uuidString

        // Store challenge with 5-min TTL
        var pending = req.application.storage[PendingChallengesKey.self] ?? [:]
        // Prune expired
        let now = Date()
        pending = pending.filter { $0.value > now }
        pending[challenge] = now.addingTimeInterval(300)
        req.application.storage[PendingChallengesKey.self] = pending

        req.logger.info("🟢 GET /passkey/challenge successful. Returning challenge for temporary userID: \(userID)")
        return ChallengeResponse(challenge: challenge, userID: userID)
    }

    // MARK: POST /passkey/register

    func register(req: Request) async throws -> AuthResponse {
        req.logger.info("🟢 POST /passkey/register reached")
        let input = try req.content.decode(RegisterRequest.self)

        // Validate challenge
        try consumeChallenge(input.challenge, on: req)

        let credential = PasskeyCredential(
            userID: input.userID,
            username: input.username,
            credentialID: Data(base64URLEncoded: input.credentialID) ?? Data(),
            publicKey: Data(base64URLEncoded: input.publicKey) ?? Data()
        )
        try await credential.save(on: req.db)

        req.logger.info("🟢 POST /passkey/register successful. Registered new passkey for userID: \(input.userID)")
        return AuthResponse(userID: input.userID, username: input.username)
    }

    // MARK: POST /passkey/authenticate

    func authenticate(req: Request) async throws -> AuthResponse {
        req.logger.info("🟢 POST /passkey/authenticate reached")
        let input = try req.content.decode(AuthenticateRequest.self)

        // Validate challenge
        try consumeChallenge(input.challenge, on: req)

        guard let userHandleData = Data(base64URLEncoded: input.userHandle) else {
            throw Abort(.badRequest, reason: "Invalid userHandle")
        }
        let userID = String(data: userHandleData, encoding: .utf8) ?? ""

        // Find credential by userID
        guard let credential = try await PasskeyCredential.query(on: req.db)
            .filter(\.$userID == userID)
            .first()
        else {
            throw Abort(.unauthorized, reason: "Unknown user")
        }

        // Verify signature: sign(authenticatorData || SHA256(clientDataJSON))
        guard let authData = Data(base64URLEncoded: input.authenticatorData),
              let clientDataJSON = Data(base64URLEncoded: input.clientDataJSON),
              let signatureData = Data(base64URLEncoded: input.signature)
        else {
            throw Abort(.badRequest, reason: "Invalid base64url fields")
        }

        // Parse the stored COSE public key — if corrupted, delete and ask client to re-register
        let pubKey: P256.Signing.PublicKey
        do {
            pubKey = try parseES256PublicKey(from: credential.publicKey)
        } catch {
            req.logger.warning("🔴 Corrupted credential for user \(userID), deleting. Error: \(error)")
            try await credential.delete(on: req.db)
            throw Abort(.conflict, reason: "credential_corrupted")
        }

        let clientDataHash = SHA256.hash(data: clientDataJSON)
        var signedData = authData
        signedData.append(contentsOf: clientDataHash)

        // DER signature from authenticator is already in ASN.1 DER
        let signature = try P256.Signing.ECDSASignature(derRepresentation: signatureData)

        guard pubKey.isValidSignature(signature, for: signedData) else {
            throw Abort(.unauthorized, reason: "Invalid signature")
        }

        req.logger.info("🟢 POST /passkey/authenticate successful. User authenticated: \(credential.userID)")
        return AuthResponse(userID: credential.userID, username: credential.username)
    }

    // MARK: - Helpers

    private func consumeChallenge(_ challenge: String, on req: Request) throws {
        var pending = req.application.storage[PendingChallengesKey.self] ?? [:]
        let now = Date()
        pending = pending.filter { $0.value > now }

        guard pending.removeValue(forKey: challenge) != nil else {
            throw Abort(.unauthorized, reason: "Invalid or expired challenge")
        }
        req.application.storage[PendingChallengesKey.self] = pending
    }

    /// Parse a COSE_Key (ES256) into a CryptoKit P256 public key.
    /// Expects the raw credential public key bytes from the attestation object.
    /// Format: 0x04 || x (32 bytes) || y (32 bytes)  — uncompressed point
    /// OR full CBOR COSE_Key map — we extract x,y from CBOR keys -2, -3.
    private func parseES256PublicKey(from data: Data) throws -> P256.Signing.PublicKey {
        // Try uncompressed point first (65 bytes: 0x04 + 32 + 32)
        if data.count == 65 && data[data.startIndex] == 0x04 {
            // let x = data[data.index(data.startIndex, offsetBy: 1)..<data.index(data.startIndex, offsetBy: 33)]
            // let y = data[data.index(data.startIndex, offsetBy: 33)..<data.index(data.startIndex, offsetBy: 65)]
            return try P256.Signing.PublicKey(x963Representation: data)
        }

        // Otherwise, try CBOR COSE_Key: extract x (-2) and y (-3) coordinates
        // Minimal CBOR map parser for the specific COSE_Key structure
        let (x, y) = try extractCOSEKeyCoordinates(from: data)
        var uncompressed = Data([0x04])
        uncompressed.append(x)
        uncompressed.append(y)
        return try P256.Signing.PublicKey(x963Representation: uncompressed)
    }

    /// Minimal CBOR parser that extracts x (-2) and y (-3) byte strings from a COSE_Key map.
    private func extractCOSEKeyCoordinates(from data: Data) throws -> (x: Data, y: Data) {
        let bytes = [UInt8](data)
        guard bytes.count > 1 else { throw Abort(.badRequest, reason: "Public key too short") }

        var i = 0
        // First byte should be a CBOR map (0xa0-0xb7 range for small maps)
        let mapHeader = bytes[i]
        guard (mapHeader & 0xe0) == 0xa0 else {
            throw Abort(.badRequest, reason: "Expected CBOR map")
        }
        let mapCount = Int(mapHeader & 0x1f)
        i += 1

        var x: Data?
        var y: Data?

        for _ in 0..<mapCount {
            guard i < bytes.count else { break }

            // Read key (negative integer for -2, -3 or positive for 1, 3)
            let keyValue = try readCBORInt(bytes: bytes, index: &i)

            // Read value
            if keyValue == -2 || keyValue == -3 {
                // Expecting byte string (major type 2)
                guard i < bytes.count else { break }
                let valHeader = bytes[i]
                let valMajor = valHeader >> 5
                let additional = Int(valHeader & 0x1f)
                guard valMajor == 2 else { i += 1; continue } // not a byte string
                let valLen: Int
                if additional < 24 {
                    // Length 0–23 encoded directly in the additional info
                    valLen = additional
                    i += 1
                } else if additional == 24 {
                    // 1-byte length follows (lengths 24–255)
                    i += 1
                    guard i < bytes.count else { break }
                    valLen = Int(bytes[i])
                    i += 1
                } else if additional == 25 {
                    // 2-byte length follows
                    i += 1
                    guard i + 2 <= bytes.count else { break }
                    valLen = Int(bytes[i]) << 8 | Int(bytes[i + 1])
                    i += 2
                } else {
                    // skip unknown length encoding
                    i += 1
                    continue
                }
                guard i + valLen <= bytes.count else { break }
                let valData = Data(bytes[i..<(i + valLen)])
                i += valLen

                if keyValue == -2 { x = valData }
                else { y = valData }
            } else {
                // Skip value (we only care about -2 and -3)
                try skipCBORValue(bytes: bytes, index: &i)
            }
        }

        guard let xCoord = x, let yCoord = y, xCoord.count == 32, yCoord.count == 32 else {
            throw Abort(.badRequest, reason: "Could not extract P-256 coordinates from COSE key")
        }
        return (xCoord, yCoord)
    }

    private func readCBORInt(bytes: [UInt8], index: inout Int) throws -> Int {
        guard index < bytes.count else { throw Abort(.badRequest, reason: "CBOR underflow") }
        let header = bytes[index]
        let majorType = header >> 5
        let additional = Int(header & 0x1f)
        index += 1

        let rawValue: Int
        if additional < 24 {
            rawValue = additional
        } else if additional == 24 {
            guard index < bytes.count else { throw Abort(.badRequest, reason: "CBOR underflow") }
            rawValue = Int(bytes[index])
            index += 1
        } else {
            throw Abort(.badRequest, reason: "Unsupported CBOR int size")
        }

        if majorType == 0 { return rawValue }          // unsigned
        if majorType == 1 { return -(rawValue + 1) }   // negative
        throw Abort(.badRequest, reason: "Expected CBOR integer, got major type \(majorType)")
    }

    private func skipCBORValue(bytes: [UInt8], index: inout Int) throws {
        guard index < bytes.count else { return }
        let header = bytes[index]
        let majorType = header >> 5
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
        } else {
            length = 0
        }

        switch majorType {
        case 0, 1: break  // integer, value already consumed
        case 2, 3: index += length  // byte/text string
        case 4: for _ in 0..<length { try skipCBORValue(bytes: bytes, index: &index) }
        case 5: for _ in 0..<length { try skipCBORValue(bytes: bytes, index: &index); try skipCBORValue(bytes: bytes, index: &index) }
        default: break
        }
    }
}

// MARK: - Base64URL helpers

extension Data {
    init?(base64URLEncoded string: String) {
        var base64 = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let remainder = base64.count % 4
        if remainder > 0 {
            base64.append(String(repeating: "=", count: 4 - remainder))
        }
        self.init(base64Encoded: base64)
    }

    func base64URLEncodedString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
