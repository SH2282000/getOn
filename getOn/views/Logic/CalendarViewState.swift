//
//  CalendarViewState.swift
//  getOn
//
//  Created by Shannah on 30/11/2025.
//


import SwiftUI
import MapKit

struct CalendarViewState: Identifiable {
    var uuid: UUID = UUID()
    var id: UUID { uuid }
    var title: String = "Example"
    var color: Color = .blue
    var isExpanded: Bool = false
    var occurrences: Int = 3
    var isMonthly: Bool = false
    var description: String = ""
    var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    var selectedDay: Int = Calendar.current.component(.day, from: Date())
    var hours: Int = 2
    var date: Date {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        var components = DateComponents()
        components.year = currentYear
        components.month = selectedMonth
        components.day = selectedDay
        components.hour = hours
        components.minute = 0
        return calendar.date(from: components) ?? Date()
    }
    var savedShapes: [SavedMapShape] = []
}

extension CalendarViewState {
    func toDTO() -> CalendarViewStateDTO {
        CalendarViewStateDTO(
            uuid: uuid,
            title: title,
            colorHex: color.toHex() ?? "0000FF",
            isExpanded: isExpanded,
            occurrences: occurrences,
            isMonthly: isMonthly,
            description: description,
            selectedMonth: selectedMonth,
            selectedDay: selectedDay,
            hours: hours,
            savedShapes: savedShapes.map { $0.toDTO() }
        )
    }
    
    init(from dto: CalendarViewStateDTO) {
        self.uuid = dto.uuid
        self.title = dto.title
        self.color = Color(hex: dto.colorHex)
        self.isExpanded = dto.isExpanded
        self.occurrences = dto.occurrences
        self.isMonthly = dto.isMonthly
        self.description = dto.description
        self.selectedMonth = dto.selectedMonth
        self.selectedDay = dto.selectedDay
        self.hours = dto.hours
        self.savedShapes = dto.savedShapes.map { SavedMapShape(from: $0) }
    }
}
