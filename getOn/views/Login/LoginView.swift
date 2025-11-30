//
//  LoginView.swift
//  getOn
//
//  Created by Shannah on 30/11/2025.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Binding var username: String
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Background
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                Spacer()
                
                // Logo / Title
                VStack(spacing: 10) {
                    Image(systemName: "livephoto")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundStyle(.tint)
                    
                    Text("getOn")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                    
                    
                    RotatingTextView(
                        prefix: "Discover",
                        words: ["people", "events", "places", "activities", "businesses", "everything"],
                        suffix: "around you"
                    )
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                .padding(.bottom, 40)
                
                // Sign in Buttons
                VStack(spacing: 16) {
                    // Apple Sign In
                    SignInWithAppleButton(
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            switch result {
                            case .success(let authResults):
                                print("Authorization successful: \(authResults)")
                                authManager.signInWithApple()
                            case .failure(let error):
                                print("Authorization failed: \(error.localizedDescription)")
                            }
                        }
                    )
                    .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                    .frame(height: 50)
                    .cornerRadius(20)
                    
                    // Google Sign In (Custom Button)
                    Button(action: {
                        authManager.signInWithGoogle()
                    }) {
                        HStack {
                            Image(systemName: "g.circle.fill") // Placeholder for Google Logo
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text("Sign in with Google")
                                .font(.system(size: 19, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(UIColor.secondarySystemBackground))
                        .foregroundColor(.primary)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                    
                    TextField("Username", text: $username).padding().glassEffect()
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Footer
                Text("By continuing, you agree to our Terms of Service and Privacy Policy.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    LoginView(username: .constant("Shannah"))
        .environmentObject(AuthenticationManager())
}
