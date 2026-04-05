//
//  CommonBackground.swift
//  getOn
//
//  Created by Shannah on 05/04/2026.
//

import SwiftUI

struct CommonBackground: View {
    @State private var animate = false
    
    var body: some View {
        Color.blue.opacity(0.8)
    }
}

#Preview {
    @Previewable @State var calendarState: CalendarViewState = .init()
    
    SwipeCalendarView(calendarState: .constant(calendarState))
        .environmentObject(AuthenticationManager())}
