//
//  LoginView.swift
//  getOn
//
//  Created by Shannah on 30/11/2025.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                Spacer()
                
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
                
                VStack(spacing: 16) {
                    if !authManager.isAuthenticated {
                        Button(action: {
                            authManager.signIn()
                        }) {
                            HStack {
                                Image(systemName: "person.badge.key")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                Text("Continue")
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
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                Text("By continuing, you agree that you are European and do not give your data to the US.")
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
    LoginView()
        .environmentObject(AuthenticationManager())
}
