//
//  LiquidMapTransitionView.swift
//  getOn
//
//  Created by Shannah on 29/11/2025.
//

import SwiftUI
import MapKit

// MARK: - Parent Container
struct ExternalEventsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var calendarStates: [CalendarViewState] = [
        CalendarViewState(title: "Go Fishing", color: .blue),
        CalendarViewState(title: "Painting Course", color: .pink),
        CalendarViewState(title: "Go Skiing", color: .green)
    ]
    @State private var selectedID: UUID = UUID()
    
    // Default initializer is sufficient now
    
    @Namespace private var glassNamespace // For matchedGeometryEffect

    var body: some View {
        ZStack {
            // 1. The Map (Always in background, but interacts when not expanded)
            SearchView(calendarStates: $calendarStates, selectedID: $selectedID, namespace: glassNamespace)
                .zIndex(0)
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: calendarStates.first(where: { $0.uuid == selectedID })?.isExpanded)
        .task {
            // Fetch data when view appears
            do {
                let fetchedStates = try await APIManager.shared.fetchCalendarStates(username: authManager.username)
                if !fetchedStates.isEmpty {
                    self.calendarStates = fetchedStates
                    if let first = fetchedStates.first {
                        self.selectedID = first.uuid
                    }
                }
            } catch {
                print("Error fetching calendar states: \(error)")
            }
        }
    }
}



