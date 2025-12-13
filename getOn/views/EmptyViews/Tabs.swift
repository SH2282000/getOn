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
    case offline = "network"
    case settings = "gearshape.fill"
    
    var title: String {
        switch self {
        case .search: return "Search"
        case .events: return "Events"
        case .offline: return "Network"
        case .settings: return "Settings"
        }
    }
}
