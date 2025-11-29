import SwiftUI

// MARK: - Interaction Models
enum EditMode: CaseIterable {
    case frequency
    case month
    case dayDuration
}

struct SwipeCalendarView: View {
    @Binding var isExpanded: Bool
    @State private var occurrences: Int = 3
    @State private var isMonthly: Bool = false
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var selectedDay: Int = Calendar.current.component(.day, from: Date())
    @State private var durationHours: Int = 2
    
    // Interaction State
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
            VStack(spacing: 30) {
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
                
                Spacer()
                
                // --- SECTION 1: FREQUENCY ---
                GlassRow(
                    isActive: activeMode == .frequency,
                    icon: "waveform.path.ecg",
                    title: "FREQUENCY"
                ) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("\(occurrences)")
                            .font(.system(size: 56, weight: .thin, design: .rounded))
                            .contentTransition(.numericText())
                        
                        Text(isMonthly ? "/ month" : "/ week")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
                .onTapGesture {
                    setActive(.frequency)
                    // Optional: Tap while active toggles the sub-unit
                    if activeMode == .frequency {
                        withAnimation { isMonthly.toggle() }
                        feedback.impactOccurred()
                    }
                }

                // --- SECTION 2: MONTH ---
                GlassRow(
                    isActive: activeMode == .month,
                    icon: "calendar",
                    title: "MONTH"
                ) {
                    Text(Calendar.current.monthSymbols[selectedMonth - 1])
                        .font(.system(size: 44, weight: .light))
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
                        Text("Day \(selectedDay)")
                            .font(.title)
                            .fontWeight(.medium)
                            .contentTransition(.numericText())
                        
                        Spacer()
                        
                        Text("\(durationHours) hr")
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
                            durationHours = (durationHours % 12) + 1
                        }
                        feedback.impactOccurred()
                    }
                }
                
                Spacer()
                
                // Instructional Footer
                Text("Tap a card to select • Swipe vertically to adjust")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.2))
                    .padding(.bottom, 20)
            }
            .padding(20)
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
                let newValue = occurrences + step
                if newValue >= 1 && newValue <= 30 {
                    occurrences = newValue
                }
            case .month:
                let newValue = selectedMonth + step
                if newValue >= 1 && newValue <= 12 {
                    selectedMonth = newValue
                }
            case .dayDuration:
                // Adjust Day
                let daysInMonth = rangeForMonth(month: selectedMonth)
                let newValue = selectedDay + step
                if newValue >= 1 && newValue <= daysInMonth {
                    selectedDay = newValue
                }
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
    SwipeCalendarView(isExpanded: .constant(true))
}
