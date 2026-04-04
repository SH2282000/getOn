//
//  getOnApp.swift
//  getOn
//
//  Created by Shannah on 29/11/2025.
//

import SwiftUI

@main
struct getOnApp: App {
    @StateObject private var authManager = AuthenticationManager()

    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                NavigationView()
                    .environmentObject(authManager)
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
    }
}
