//
//  MenuView.swift
//  getOn
//
//  Created by Shannah on 30/11/2025.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case search = "magnifyingglass"
    case events = "calendar.badge.clock"
    case profile = "person.crop.circle"
    case settings = "gearshape.fill"
    
    var title: String {
        switch self {
        case .search: return "Search"
        case .events: return "Events"
        case .profile: return "Profile"
        case .settings: return "Settings"
        }
    }
}

struct MenuView: View {
    @State private var selectedTab: Tab = .events
    
    var body: some View {
        ZStack {
            // Content Layer
            // Using a ZStack for content to avoid state loss when switching if possible,
            // or just a Switch for simplicity. For complex views like Maps, keeping them alive is often better.
            // Here we use a switch for standard tab behavior.
            Group {
                switch selectedTab {
                case .search:
                    PlaceholderView(title: "Search", icon: Tab.search.rawValue)
                case .events:
                    EventsView()
                case .profile:
                    PlaceholderView(title: "Profile", icon: Tab.profile.rawValue)
                case .settings:
                    PlaceholderView(title: "Settings", icon: Tab.settings.rawValue)
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
