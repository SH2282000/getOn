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
            
            PlaceholderView(title: Tabs.search.title, icon: Tabs.search.rawValue)
                .tag(Tabs.search)
                .tabItem {
                    Image(systemName: Tabs.search.rawValue)
                    Text(Tabs.search.title)
                }
            
            LoginView()
                .tag(Tabs.profile)
                .tabItem {
                    Image(systemName: Tabs.profile.rawValue)
                    Text(Tabs.profile.title)
                }
            
            PlaceholderView(title: Tabs.settings.title, icon: Tabs.settings.rawValue)
                .tag(Tabs.profile)
                .tabItem {
                    Image(systemName: Tabs.settings.rawValue)
                    Text(Tabs.settings.title)
                }
        }
    }
}

#Preview {
    NavigationView()
}
