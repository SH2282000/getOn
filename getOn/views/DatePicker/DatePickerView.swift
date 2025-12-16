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
        // --- SECTION 1: FREQUENCY ---∏
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
                            let newValue = calendarState.startMonth + 1
                            if newValue >= 1 && newValue <= 12 {
                                calendarState.startMonth = newValue
                            } else {
                                calendarState.startMonth = 1
                            }
                        }
                        feedback.impactOccurred()
                    }
                }
            ) {
                HStack {
                    Text("Day \(calendarState.startDay)")
                        .font(.title)
                        .fontWeight(.medium)
                        .contentTransition(.numericText())
                    
                    Spacer()
                    
                    Text(Calendar.current.monthSymbols[calendarState.startMonth - 1])
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
                            // Cycle duration 1..7
                            let newDuration = calendarState.duration + 1
                            calendarState.duration = newDuration > 7 ? 1 : newDuration
                        }
                        feedback.impactOccurred()
                    }
                }
            ) {
                HStack {
                    Text(calendarState.startTime.formatted(date: .omitted, time: .shortened)) // Will respect locale usually, but let's try to trust system or use formatter if needed 24h
                        .font(.title)
                        .fontWeight(.medium)
                        .contentTransition(.numericText())
                    
                    Spacer()
                    
                    Text("\(calendarState.duration) hr")
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
