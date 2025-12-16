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
    var startMonth: Int = Calendar.current.component(.month, from: Date())
    var startDay: Int = Calendar.current.component(.day, from: Date())
    var startTime: Date = {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 14
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }()
    var duration: Int = 2
    var date: Date {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let hour = calendar.component(.hour, from: startTime)
        let minute = calendar.component(.minute, from: startTime)
        var components = DateComponents()
        components.year = currentYear
        components.month = startMonth
        components.day = startDay
        components.hour = hour
        components.minute = minute
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
            startMonth: startMonth,
            startDay: startDay,
            startTime: startTime,
            duration: duration,
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
        self.startMonth = dto.startMonth
        self.startDay = dto.startDay
        self.startTime = dto.startTime
        self.duration = dto.duration
        self.savedShapes = dto.savedShapes.map { SavedMapShape(from: $0) }
    }
}
