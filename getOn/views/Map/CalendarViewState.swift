//
//  CalendarViewState.swift
//  getOn
//
//  Created by Shannah on 30/11/2025.
//


import SwiftUI
import MapKit

struct CalendarViewState {
    var title: String = "Example"
    var isExpanded: Bool = false
    var occurrences: Int = 3
    var isMonthly: Bool = false
    var description: String = ""
    var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    var selectedDay: Int = Calendar.current.component(.day, from: Date())
    var date: Date = Date()
    var durationHours: Int = 2
}
