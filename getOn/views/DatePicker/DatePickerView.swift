//
//  DatePickerView.swift
//  getOn
//
//  Created by Shannah on 16/12/2025.
//

import SwiftUI

struct DatePickerView: View {
    @Binding var calendarState: CalendarViewState
    @Binding var activeMode: CalendarEditMode
    private let feedback = UIImpactFeedbackGenerator(style: .heavy)
    var setActive: (CalendarEditMode) -> Void
    
    var body: some View {
        // --- SECTION 1: FREQUENCY ---
        VStack(spacing: 16) {
            ExpandableGlassRow(
                isActive: activeMode == .frequency,
                icon: "waveform.path.ecg",
                title: "FREQUENCY",
                onTap: {
                    setActive(.frequency)
                    if activeMode == .frequency {
                        withAnimation { calendarState.isMonthly.toggle() }
                        feedback.impactOccurred()
                    }
                }
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
            
            ExpandableGlassRow(
                isActive: activeMode == .monthDay,
                icon: "calendar",
                title: "DAY & MONTH",
                onTap: {
                    setActive(.monthDay)
                    if activeMode == .monthDay {
                        withAnimation {
                            let newValue = calendarState.selectedMonth + 1
                            if newValue >= 1 && newValue <= 12 {
                                calendarState.selectedMonth = newValue
                            } else {
                                calendarState.selectedMonth = 1
                            }
                        }
                        feedback.impactOccurred()
                    }
                }
            ) {
                HStack {
                    Text("Day \(calendarState.selectedDay)")
                        .font(.title)
                        .fontWeight(.medium)
                        .contentTransition(.numericText())
                    
                    Spacer()
                    
                    Text(Calendar.current.monthSymbols[calendarState.selectedMonth - 1])
                        .font(.title)
                        .foregroundStyle(.secondary)
                        .contentTransition(.numericText())
                }
            }
            
            ExpandableGlassRow(
                isActive: activeMode == .timeDuration,
                icon: "clock",
                title: "TIME & DURATION",
                onTap: {
                    setActive(.timeDuration)
                    if activeMode == .timeDuration {
                        withAnimation {
                            calendarState.hours = (calendarState.hours % 12) + 1
                        }
                        feedback.impactOccurred()
                    }
                }
            ) {
                HStack {
                    Text("\(calendarState.hours) : 00")
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


#Preview {
    @Previewable @State var calendarState: CalendarViewState = .init()

    SwipeCalendarView(calendarState: .constant(calendarState))
        .environmentObject(AuthenticationManager())
}
