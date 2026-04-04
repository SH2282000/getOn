//
//  NavigationView.swift
//  getOn
//
//  Created by Shannah on 30/11/2025.
//

import SwiftUI

struct NavigationView: View {
    @State var activeTab: Tabs = .events
    @State private var searchText: String = ""
    
    var body: some View {
        TabView {
            Tab(Tabs.events.title, systemImage: "calendar") {
                EventsView()
            }
            Tab(Tabs.settings.title, systemImage: Tabs.settings.rawValue) {
                SettingsView()
            }
            
            Tab(role: .search) {
                NavigationStack {
                    EventsView()
                        .searchable(text: $searchText, prompt: "Search map...")
                }
            }
        }
        .tabBarMinimizeBehavior(.automatic)
    }
}
