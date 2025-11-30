//
//  Tab.swift
//  getOn
//
//  Created by Shannah on 30/11/2025.
//


import SwiftUI

enum Tabs: String, CaseIterable {
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
