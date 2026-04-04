import SwiftUI

// MARK: - Models

struct TimeSlot: Identifiable, Equatable {
    let id = UUID()
    var dayIndex: Int        // 0 = Monday .. 6 = Sunday
    var startHalfHour: Int   // 0..47  (0 = 00:00, 1 = 00:30, …)
    var endHalfHour: Int     // 1..48  (exclusive end)
}

enum WeekDragMode {
    case add, remove
}

// MARK: - WeekView

struct WeekView: View {
    @State private var timeSlots: [TimeSlot] = []
    @State private var dragMode: WeekDragMode = .add
    @State private var weekOffset: Int = 0

    // Drag state
    @State private var currentDragSlot: TimeSlot? = nil
    @State private var dragAnchorHalfHour: Int? = nil
    @State private var dragDayIndex: Int? = nil
    @State private var lastSnappedHalfHour: Int? = nil

    private let feedback = UIImpactFeedbackGenerator(style: .light)
    private let mediumFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let selectionFeedback = UISelectionFeedbackGenerator()

    private let dayLabelWidth: CGFloat = 55
    private let rowHeight: CGFloat = 40
    private let hourLabels = [0, 3, 6, 9, 12, 15, 18, 21]

    // MARK: - Date helpers

    private var weekStartDate: Date {
        let cal = Calendar.current
        let today = Date()
        let weekday = cal.component(.weekday, from: today) // 1=Sun
        let daysToMonday = weekday == 1 ? -6 : (2 - weekday)
        let thisMonday = cal.date(byAdding: .day, value: daysToMonday, to: today)!
        return cal.date(byAdding: .weekOfYear, value: weekOffset, to: thisMonday)!
    }

    private var daysOfWeek: [(label: String, date: Date)] {
        let cal = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return (0..<7).map { i in
            let date = cal.date(byAdding: .day, value: i, to: weekStartDate)!
            let day = cal.component(.day, from: date)
            let name = formatter.string(from: date)
            return ("\(name) \(day)", date)
        }
    }

    private var monthYearTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: weekStartDate)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerRow
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 8)

            // Time axis
            timeAxisRow
                .padding(.horizontal, 12)

            // Day rows
            ForEach(0..<7, id: \.self) { dayIndex in
                dayRow(dayIndex: dayIndex)
            }

            // Footer
            footerRow
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
        }
        .padding(.vertical, 4)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)

                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.6), .white.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            }
        }
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
    }

    // MARK: - Header

    private var headerRow: some View {
        HStack {
            Text(monthYearTitle)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)

            Spacer()

            HStack(spacing: 12) {
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        weekOffset -= 1
                    }
                    feedback.impactOccurred()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.caption.bold())
                        .foregroundStyle(.white.opacity(0.6))
                }

                Text("Scroll weeks")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.4))

                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        weekOffset += 1
                    }
                    feedback.impactOccurred()
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
    }

    // MARK: - Time Axis

    private var timeAxisRow: some View {
        HStack(spacing: 0) {
            Color.clear.frame(width: dayLabelWidth)

            GeometryReader { geo in
                let stripWidth = geo.size.width
                ForEach(hourLabels, id: \.self) { hour in
                    let x = xPosition(for: hour * 2, in: stripWidth)
                    Text(String(format: "%02d", hour))
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.4))
                        .position(x: x, y: 10)
                }
            }
        }
        .frame(height: 20)
    }

    // MARK: - Day Row

    private func dayRow(dayIndex: Int) -> some View {
        HStack(spacing: 0) {
            // Day label
            Text(daysOfWeek[dayIndex].label)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.white.opacity(0.7))
                .frame(width: dayLabelWidth, alignment: .leading)

            // Time strip
            GeometryReader { geo in
                let stripWidth = geo.size.width
                ZStack(alignment: .leading) {
                    // Grid lines
                    ForEach(hourLabels + [24], id: \.self) { hour in
                        let x = xPosition(for: hour * 2, in: stripWidth)
                        Rectangle()
                            .fill(.white.opacity(0.08))
                            .frame(width: 0.5)
                            .position(x: x, y: rowHeight / 2)
                    }

                    // Committed time slots
                    ForEach(timeSlots.filter { $0.dayIndex == dayIndex }) { slot in
                        timeBlockCapsule(slot: slot, stripWidth: stripWidth, isPreview: false)
                    }

                    // Live drag preview
                    if let preview = currentDragSlot, preview.dayIndex == dayIndex {
                        timeBlockCapsule(slot: preview, stripWidth: stripWidth, isPreview: true)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .coordinateSpace(name: "strip\(dayIndex)")
                .gesture(
                    DragGesture(minimumDistance: 5, coordinateSpace: .named("strip\(dayIndex)"))
                        .onChanged { value in
                            handleDragChanged(value: value, dayIndex: dayIndex, stripWidth: stripWidth)
                        }
                        .onEnded { _ in
                            handleDragEnded()
                        }
                )
            }
        }
        .frame(height: rowHeight)
        .padding(.horizontal, 12)
    }

    // MARK: - Time Block Capsule

    private func timeBlockCapsule(slot: TimeSlot, stripWidth: CGFloat, isPreview: Bool) -> some View {
        let x = xPosition(for: slot.startHalfHour, in: stripWidth)
        let w = xPosition(for: slot.endHalfHour, in: stripWidth) - x

        return Capsule()
            .fill(
                LinearGradient(
                    colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.7)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
            .frame(width: max(w, 4), height: 28)
            .position(x: x + w / 2, y: rowHeight / 2)
            .opacity(isPreview ? 0.55 : 1.0)
    }

    // MARK: - Footer

    private var footerRow: some View {
        HStack {
            Text("Drag & release to create time blocks")
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.3))

            Spacer()

            HStack(spacing: 10) {
                modeButton(mode: .add, icon: "plus")
                modeButton(mode: .remove, icon: "minus")
            }
        }
    }

    private func modeButton(mode: WeekDragMode, icon: String) -> some View {
        let isActive = dragMode == mode
        return Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                dragMode = mode
            }
            feedback.impactOccurred()
        } label: {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(isActive ? .white : .white.opacity(0.4))
                .frame(width: 32, height: 32)
                .background {
                    Circle()
                        .fill(isActive ? Color.blue.opacity(0.6) : Color.white.opacity(0.1))
                }
                .overlay {
                    Circle()
                        .strokeBorder(.white.opacity(isActive ? 0.5 : 0.15), lineWidth: 1)
                }
                .scaleEffect(isActive ? 1.1 : 1.0)
        }
    }

    // MARK: - Coordinate Math

    private func halfHourIndex(x: CGFloat, stripWidth: CGFloat) -> Int {
        let clamped = max(0, min(x, stripWidth))
        let raw = Int((clamped / stripWidth) * 48.0)
        return min(raw, 47)
    }

    private func xPosition(for halfHour: Int, in stripWidth: CGFloat) -> CGFloat {
        CGFloat(halfHour) / 48.0 * stripWidth
    }

    // MARK: - Gesture Handlers

    private func handleDragChanged(value: DragGesture.Value, dayIndex: Int, stripWidth: CGFloat) {
        let hh = halfHourIndex(x: value.location.x, stripWidth: stripWidth)

        switch dragMode {
        case .add:
            if dragAnchorHalfHour == nil {
                dragAnchorHalfHour = hh
                dragDayIndex = dayIndex
                lastSnappedHalfHour = hh
            }

            guard dragDayIndex == dayIndex, let anchor = dragAnchorHalfHour else { return }

            let start = min(anchor, hh)
            let end = max(anchor, hh) + 1
            currentDragSlot = TimeSlot(dayIndex: dayIndex, startHalfHour: start, endHalfHour: end)

            if hh != lastSnappedHalfHour {
                lastSnappedHalfHour = hh
                selectionFeedback.selectionChanged()
            }

        case .remove:
            // Find and remove any slot under the finger
            if let idx = timeSlots.firstIndex(where: {
                $0.dayIndex == dayIndex && $0.startHalfHour <= hh && hh < $0.endHalfHour
            }) {
                timeSlots.remove(at: idx)
                feedback.impactOccurred()
            }
        }
    }

    private func handleDragEnded() {
        if dragMode == .add, let slot = currentDragSlot {
            timeSlots.append(slot)
            mergeSlotsForDay(slot.dayIndex)
            mediumFeedback.impactOccurred()
        }

        currentDragSlot = nil
        dragAnchorHalfHour = nil
        dragDayIndex = nil
        lastSnappedHalfHour = nil
    }

    // MARK: - Merge Logic

    private func mergeSlotsForDay(_ dayIndex: Int) {
        let daySlots = timeSlots
            .filter { $0.dayIndex == dayIndex }
            .sorted { $0.startHalfHour < $1.startHalfHour }

        var merged: [TimeSlot] = []
        for slot in daySlots {
            if var last = merged.last, slot.startHalfHour <= last.endHalfHour {
                last.endHalfHour = max(last.endHalfHour, slot.endHalfHour)
                merged[merged.count - 1] = last
            } else {
                merged.append(slot)
            }
        }

        timeSlots.removeAll { $0.dayIndex == dayIndex }
        timeSlots.append(contentsOf: merged)
    }
}

// MARK: - Preview

#Preview("WeekView / Edit") {
    ZStack {
        LiquidBackground()
            .ignoresSafeArea()
        WeekView()
            .padding()
    }
}
