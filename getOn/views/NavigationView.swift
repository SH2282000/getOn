//
//  NavigationView.swift
//  getOn
//
//  Created by Shannah on 30/11/2025.
//

import SwiftUI

struct NavigationView: View {
    @State var activeTab: Tabs = .events
    
    var body: some View {
        TabView(selection: $activeTab) {
            EventsView()
                .tag(Tabs.events)
                .tabItem {
                    Image(systemName: "calendar")
                }
            
            LoginView()
                .tag(Tabs.offline)
                .tabItem {
                    Image(systemName: Tabs.offline.rawValue)
                }
            
            Spacer()
            SettingsView()
                .tag(Tabs.settings)
                .tabItem {
                    Image(systemName: Tabs.settings.rawValue)
                }
        }
    }
}

#Preview {
    NavigationView()
}
