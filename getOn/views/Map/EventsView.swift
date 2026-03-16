//
//  LiquidMapTransitionView.swift
//  getOn
//
//  Created by Shannah on 29/11/2025.
//

import SwiftUI
import MapKit

// MARK: - Parent Container
struct EventsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var calendarStates: [CalendarViewState] = []
    @State private var selectedID: UUID = UUID()

    // Default initializer is sufficient now

    @Namespace private var glassNamespace // For matchedGeometryEffect

    var body: some View {
        ZStack {
            // 1. The Map (Always in background, but interacts when not expanded)
            MapView(calendarStates: $calendarStates, selectedID: $selectedID, namespace: glassNamespace)
                .zIndex(0)

            // 2. The Expanded View (Overlays when active)
            if let selectedIndex = calendarStates.firstIndex(where: { $0.uuid == selectedID }),
               calendarStates[selectedIndex].isExpanded {
                SwipeCalendarView(calendarState: $calendarStates[selectedIndex])
                    .zIndex(1)
                    .transition(.asymmetric(
                        insertion: .opacity.animation(.easeIn(duration: 0.2)),
                        removal: .opacity.animation(.easeOut(duration: 0.2).delay(0.2))
                    ))
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: calendarStates.first(where: { $0.uuid == selectedID })?.isExpanded)
        .onChange(of: selectedID) { oldId, newId in
            // Handle infinite scroll / sliding to the end to append a new dummy
            if let index = calendarStates.firstIndex(where: { $0.uuid == newId }) {
                if index == calendarStates.count - 1 && calendarStates[index].title == "New Event" {
                    // Re-title the dummy and save to API
                    calendarStates[index].title = "Untitled Event \(calendarStates.count)"
                    
                    // Create new placeholder
                    let newPlaceholder = CalendarViewState(title: "New Event", color: .gray)
                    calendarStates.append(newPlaceholder)
                    
                    // Trigger an async save to backend
                    Task {
                        try? await APIManager.shared.saveCalendarStates(username: authManager.userId ?? "", states: calendarStates)
                    }
                }
            }
        }
        .task {
            // Make sure we have a username before fetching
            guard let uid = authManager.userId, !uid.isEmpty else { return }
            
            // Fetch data when view appears
            do {
                let fetchedStates = try await APIManager.shared.fetchCalendarStates(username: uid)
                if !fetchedStates.isEmpty {
                    self.calendarStates = fetchedStates
                    
                    // Ensure the array ends with our 'New Event' dummy
                    if self.calendarStates.last?.title != "New Event" {
                        self.calendarStates.append(CalendarViewState(title: "New Event", color: .gray))
                    }
                    
                    if let first = self.calendarStates.first {
                        self.selectedID = first.uuid
                    }
                } else {
                    // It's empty, just give them a dummy right away
                    self.calendarStates = [CalendarViewState(title: "New Event", color: .gray)]
                    self.selectedID = self.calendarStates[0].uuid
                }
            } catch {
                print("Error fetching calendar states: \(error)")
                // Load dummy on fail so map doesn't crash empty array
                self.calendarStates = [CalendarViewState(title: "New Event", color: .gray)]
                self.selectedID = self.calendarStates[0].uuid
            }
        }
    }
}



