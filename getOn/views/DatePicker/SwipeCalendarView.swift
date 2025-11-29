import SwiftUI

// MARK: - Interaction Models
enum EditMode: CaseIterable {
    case title
    case frequency
    case month
    case dayDuration
    case description
}

struct SwipeCalendarView: View {
    @Binding var calendarState: CalendarViewState
    
    // Interaction State
    @State var isExpanded: Bool
    @State private var activeMode: EditMode = .frequency
    @State private var dragOffset: CGFloat = 0
    @State private var lastDragValue: CGFloat = 0
    
    // Feedback
    private let feedback = UIImpactFeedbackGenerator(style: .medium)
    private let selectionFeedback = UISelectionFeedbackGenerator()

    var body: some View {
        ZStack {
            // 1. Dynamic  Background
            MeshGradient(width: 3, height: 3, points: [
                .init(0, 0), .init(0.5, 0), .init(1, 0),
                .init(0, 0.5), .init(0.8, 0.5), .init(1, 0.5),
                .init(0, 1), .init(0.5, 1), .init(1, 1)
            ], colors: [
                .indigo, .purple, .cyan,
                .blue, .white.opacity(0.2), .purple,
                .cyan, .blue, .indigo
            ])
            .ignoresSafeArea()
            .overlay(.ultraThinMaterial.opacity(0.1))

            // 2. Main Content
            VStack(spacing: 15) {
                HStack {
                    Spacer()
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .colorInvert()
                        .opacity(0.8)
                        .padding()
                        .onTapGesture {
                        withAnimation { isExpanded = false }
                    }
                }
                
                
                GlassRow(
                    isActive: activeMode == .title,
                    icon: "waveform.path.ecg",
                    title: "TITLE"
                ){
                    HStack {
                        TextField("Title", text: $calendarState.title)
                            .font(.system(size: 44, weight: .thin, design: .rounded))
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
                        
                        Text("\(calendarState.durationHours) hr")
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
                            calendarState.durationHours = (calendarState.durationHours % 12) + 1
                        }
                        feedback.impactOccurred()
                    }
                }
                
                GlassRow(
                    isActive: activeMode == .description,
                    icon: "waveform.path.ecg",
                    title: "DESCRIPTION"
                ){
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
                
                
                // Instructional Footer
                Text("Tap a card to select • Swipe vertically to adjust")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.2))
                    .padding(.bottom, 20)
            }
            .padding(.horizontal, 15)
        }
        // 3. GLOBAL VERTICAL SWIPE GESTURE
        .contentShape(Rectangle()) // Ensures the whole screen captures the gesture
        .gesture(
            DragGesture(minimumDistance: 10, coordinateSpace: .local)
                .onChanged { value in
                    // Calculate vertical delta only
                    let verticalTranslation = value.translation.height
                    let delta = lastDragValue - verticalTranslation // Inverted for natural scroll feel
                    
                    // Sensitivity factor (higher = slower change)
                    let sensitivity: CGFloat = 30
                    
                    if abs(delta) > sensitivity {
                        let step = delta > 0 ? 1 : -1
                        adjustActiveValue(by: step)
                        
                        // Reset reference for continuous swiping
                        lastDragValue = verticalTranslation
                        selectionFeedback.selectionChanged()
                    }
                }
                .onEnded { _ in
                    lastDragValue = 0
                }
        )
    }
    
    // MARK: - Logic Helper
    
    private func setActive(_ mode: EditMode) {
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
                case .month:
                let newValue = calendarState.selectedMonth + step
                    if newValue >= 1 && newValue <= 12 {
                        calendarState.selectedMonth = newValue
                    }
                case .dayDuration:
                    // Adjust Day
                let daysInMonth = rangeForMonth(month: calendarState.selectedMonth)
                let newValue = calendarState.selectedDay + step
                    if newValue >= 1 && newValue <= daysInMonth {
                        calendarState.selectedDay = newValue
                }
                default:
                    break
            }
        }
    }
    
    private func rangeForMonth(month: Int) -> Int {
        let dateComponents = DateComponents(year: Calendar.current.component(.year, from: Date()), month: month)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        return calendar.range(of: .day, in: .month, for: date)?.count ?? 30
    }
}

#Preview {
    @Previewable @State var calendarState: CalendarViewState = .init()
    
    SwipeCalendarView(calendarState: .constant(calendarState), isExpanded: false)
}
