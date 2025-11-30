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
    @State private var calendarStates: [CalendarViewState] = [
        CalendarViewState(title: "Go Fishing", color: .blue),
        CalendarViewState(title: "Painting Course", color: .pink),
        CalendarViewState(title: "Go Skiing", color: .green)
    ]
    @State private var selectedID: UUID
    
    init() {
        let states = [
            CalendarViewState(title: "Go Fishing", color: .blue),
            CalendarViewState(title: "Painting Course", color: .pink),
            CalendarViewState(title: "Go Skiing", color: .green)
        ]
        _calendarStates = State(initialValue: states)
        _selectedID = State(initialValue: states[0].uuid)
    }
    
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
    }
}



