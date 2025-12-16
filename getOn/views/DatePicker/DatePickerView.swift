//
//  DatePickerView.swift
//  getOn
//
//  Created by Shannah on 16/12/2025.
//

import SwiftUI

struct DatePickerView: View {
    @Binding var calendarState: CalendarViewState
    @Binding var activeMode: EditMode
    private let feedback = UIImpactFeedbackGenerator(style: .heavy)
    var setActive: (EditMode) -> Void
    
    var body: some View {
        // --- SECTION 1: FREQUENCY ---
        GlassRow(
            isActive: activeMode == .frequency,
            icon: "waveform.path.ecg",
            title: "FREQUENCY"
        ) {
            HStack(alignment: .firstTextBaseline) {
                Text("\(calendarState.occurrences)")
                    .font(.system(size: 44, weight: .thin, design: .rounded))
                    .contentTransition(.numericText())
                
                Text(calendarState.isMonthly ? "/ month" : "/ week")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
        .onTapGesture {
            setActive(.frequency)
            // Optional: Tap while active toggles the sub-unit
            if activeMode == .frequency {
                withAnimation { calendarState.isMonthly.toggle() }
                feedback.impactOccurred()
            }
        }
        
        // --- SECTION 2: MONTH ---
        GlassRow(
            isActive: activeMode == .month,
            icon: "calendar",
            title: "MONTH"
        ) {
            Text(Calendar.current.monthSymbols[calendarState.selectedMonth - 1])
                .font(.system(size: 34, weight: .light))
                .contentTransition(.numericText())
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onTapGesture { setActive(.month) }
        
        // --- SECTION 3: DAY & DURATION ---
        GlassRow(
            isActive: activeMode == .dayDuration,
            icon: "clock",
            title: "DAY & DURATION"
        ) {
            HStack {
                Text("Day \(calendarState.selectedDay)")
                    .font(.title)
                    .fontWeight(.medium)
                    .contentTransition(.numericText())
                
                Spacer()
                
                Text("\(calendarState.hours) hr")
                    .font(.title)
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
            }
        }
        .onTapGesture {
            setActive(.dayDuration)
            // Optional: Tap while active toggles editing duration vs day?
            // For now, let's keep swipe for Day, and maybe auto-cycle duration on tap?
            if activeMode == .dayDuration {
                withAnimation {
                    calendarState.hours = (calendarState.hours % 12) + 1
                }
                feedback.impactOccurred()
            }
        }
    }
}

#Preview {
    DatePickerView(
        calendarState: .constant(CalendarViewState()),
        activeMode: .constant(.frequency),
        setActive: { _ in }
    )
}
