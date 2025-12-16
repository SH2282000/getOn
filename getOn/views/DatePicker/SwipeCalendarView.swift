import SwiftUI

struct SwipeCalendarView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Binding var calendarState: CalendarViewState

    // Interaction State
    @State private var activeMode: CalendarEditMode = .frequency
    @State private var dragOffset: CGFloat = 0
    @State private var lastDragValue: CGFloat = 0

    // Feedback
    private let feedback = UIImpactFeedbackGenerator(style: .light)
    private let selectionFeedback = UISelectionFeedbackGenerator()

    var body: some View {
        ZStack {
            LiquidBackground()
                .ignoresSafeArea()
                .overlay(.ultraThinMaterial.opacity(0.1))

            // 2. Main Content
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .colorInvert()
                        .opacity(0.8)
                        .padding()
                        .onTapGesture {
                            withAnimation { calendarState.isExpanded = false }
                            Task {
                                try? await APIManager.shared.saveCalendarStates(
                                    username: authManager.username, states: [calendarState])
                            }
                        }
                }

                GlassRow(
                    isActive: activeMode == .title,
                    icon: "waveform.path.ecg",
                    title: "TITLE"
                ) {
                    HStack {
                        TextField("Title", text: $calendarState.title)
                            .font(.system(size: 20, weight: .thin, design: .rounded))
                            .contentTransition(.numericText())
                            .disabled(activeMode != .title)

                    }
                }
                .onTapGesture {
                    setActive(.title)
                    // Optional: Tap while active toggles the sub-unit
                    if activeMode == .title {
                        feedback.impactOccurred()
                    }
                }
                GlassRow(
                    isActive: activeMode == .description,
                    icon: "waveform.path.ecg",
                    title: "DESCRIPTION"
                ) {
                    HStack {
                        TextField("Description", text: $calendarState.description)
                            .contentTransition(.numericText())
                            .disabled(activeMode != .description)
                    }
                }
                .onTapGesture {
                    setActive(.description)
                    // Optional: Tap while active toggles the sub-unit
                    if activeMode == .description {
                        feedback.impactOccurred()
                    }
                }

                DatePickerView(
                    calendarState: $calendarState,
                    activeMode: $activeMode,
                    setActive: setActive
                )

                // Instructional Footer
                Text("Tap a card to select • Swipe horizontally to adjust")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.2))
                    .padding(.bottom, 20)
            }
            .padding(.horizontal, 15)
        }
        // 3. GLOBAL horizontal SWIPE GESTURE
        .contentShape(Rectangle())  // Ensures the whole screen captures the gesture
        .gesture(
            DragGesture(minimumDistance: 10, coordinateSpace: .local)
                .onChanged { value in
                    // Calculate horizontal delta only
                    let horizontalTranslation = value.translation.width
                    let delta = horizontalTranslation - lastDragValue
                    // Sensitivity factor (higher = slower change)
                    let sensitivity: CGFloat = 30

                    if abs(delta) > sensitivity {
                        let step = delta > 0 ? 1 : -1
                        adjustActiveValue(by: step)

                        // Reset reference for continuous swiping
                        lastDragValue = horizontalTranslation
                        selectionFeedback.selectionChanged()
                    }
                }
                .onEnded { _ in
                    lastDragValue = 0
                }
        )
    }

    // MARK: - Logic Helper

    private func setActive(_ mode: CalendarEditMode) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            activeMode = mode
        }
        feedback.impactOccurred()
    }

    private func adjustActiveValue(by step: Int) {
        // Use withAnimation for smooth numeric transitions
        withAnimation(.interactiveSpring) {
            switch activeMode {
            case .frequency:
                let newValue = calendarState.occurrences + step
                if newValue >= 1 && newValue <= 30 {
                    calendarState.occurrences = newValue
                }
            case .monthDay:
                let daysInMonth = rangeForMonth(month: calendarState.startMonth)
                let newValue = calendarState.startDay + step
                if newValue >= 1 && newValue <= daysInMonth {
                    calendarState.startDay = newValue
                }
            case .timeDuration:
                // Adjust time by 15 minutes
                let interval = TimeInterval(step * 15 * 60)
                calendarState.startTime = calendarState.startTime.addingTimeInterval(interval)

            default:
                break
            }
        }
    }

    private func rangeForMonth(month: Int) -> Int {
        let dateComponents = DateComponents(
            year: Calendar.current.component(.year, from: Date()), month: month)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        return calendar.range(of: .day, in: .month, for: date)?.count ?? 30
    }
}

#Preview {
    @Previewable @State var calendarState: CalendarViewState = .init()

    SwipeCalendarView(calendarState: .constant(calendarState))
        .environmentObject(AuthenticationManager())
}
