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
            
            ExternalEventsView()
                .tag(Tabs.search)
                .tabItem {
                    Image(systemName: Tabs.search.rawValue)
                }
            
            LoginView()
                .tag(Tabs.offline)
                .tabItem {
                    Image(systemName: Tabs.offline.rawValue)
                }
            
            Spacer()
            PlaceholderView(title: Tabs.settings.title, icon: Tabs.settings.rawValue) // TODO: move the profile part to settings
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
