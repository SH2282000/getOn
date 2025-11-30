//
//  AuthenticationManager.swift
//  getOn
//
//  Created by Shannah on 30/11/2025.
//

import SwiftUI
import AuthenticationServices
import Combine

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var userId: String?
    @Published var username: String = ""
    
    func signInWithApple() {
        print("Simulating Apple Sign In...")
        self.isAuthenticated = true
        self.userId = "apple_user_123"
    }
    
    func signInWithGoogle() {
        print("Simulating Google Sign In...")
        self.isAuthenticated = true
        self.userId = "google_user_123"
    }
    
    func signOut() {
        self.isAuthenticated = false
        self.userId = nil
    }
}

