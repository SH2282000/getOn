//
//  SettingsView.swift
//  getOn
//
//  Created by Shannah on 15/03/2026.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    HStack {
                        Label("User ID", systemImage: "person.text.rectangle")
                        Spacer()
                        Text(authManager.userId ?? "—")
                            .foregroundStyle(.secondary)
                            .font(.footnote)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }

                    HStack {
                        Label("Username", systemImage: "at")
                        Spacer()
                        Text(authManager.username ?? "—")
                            .foregroundStyle(.secondary)
                            .font(.footnote)
                    }
                }

                Section {
                    Button(role: .destructive) {
                        authManager.signOut()
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject({
            let mgr = AuthenticationManager()
            mgr.userId = "ABCDEF-1234"
            mgr.username = "shannah"
            return mgr
        }())
}
