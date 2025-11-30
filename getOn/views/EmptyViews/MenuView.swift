//
//  MenuView.swift
//  getOn
//
//  Created by Shannah on 30/11/2025.
//

import SwiftUI

struct MenuView: View {
    @State private var selectedTab: Tabs = .events
    
    var body: some View {
        ZStack {
            Group {
                switch selectedTab {
                case .search:
                    PlaceholderView(title: "Search", icon: Tabs.search.rawValue)
                case .events:
                    EventsView()
                case .profile:
                    PlaceholderView(title: "Profile", icon: Tabs.profile.rawValue)
                case .settings:
                    PlaceholderView(title: "Settings", icon: Tabs.settings.rawValue)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Navigation Layer (Floating Tab Bar)
            VStack {
                Spacer()
                LiquidTabBar(selectedTab: $selectedTab)
            }
            .padding(.horizontal)
            .padding(.bottom, 10) // Lift slightly from the bottom edge
        }
        .ignoresSafeArea(.keyboard) // Prevent tab bar from moving up with keyboard
    }
}

#Preview {
    MenuView()
}
