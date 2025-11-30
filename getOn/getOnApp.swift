//
//  getOnApp.swift
//  getOn
//
//  Created by Shannah on 29/11/2025.
//

import SwiftUI
import SwiftData

@main
struct getOnApp: App {
    @StateObject private var authManager = AuthenticationManager()
    @State var username: String = ""

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                NavigationView(username: $username)
                    .environmentObject(authManager)
            } else {
                LoginView(username: $username)
                    .environmentObject(authManager)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
