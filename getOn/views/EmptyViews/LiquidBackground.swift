//
//  LiquidBackground.swift
//  getOn
//
//  Created by Shannah on 30/11/2025.
//


import SwiftUI

struct LiquidBackground: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Color.blue.opacity(0.8)
            
            GeometryReader { proxy in
                ZStack {
                    ForEach(0..<9) { i in
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        [Color.cyan, .purple, .cyan, .blue, .white.opacity(0.2), .purple, .cyan, .blue, .cyan][i],
                                        [Color.cyan, .purple, .cyan, .blue, .white.opacity(0.2), .purple, .cyan, .blue, .cyan][i].opacity(1),
                                        .clear
                                    ]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 150
                                )
                            )
                            .frame(width: 300, height: 300)
                            .blur(radius: 60)
                            .offset(x: animate ? CGFloat.random(in: -150...150) : CGFloat.random(in: -300...300),
                                    y: animate ? CGFloat.random(in: -150...150) : CGFloat.random(in: -300...300))
                            .animation(.easeInOut(duration: 5 + Double(i) * 0.5).repeatForever(autoreverses: true), value: animate)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
    }
}

#Preview {
    @Previewable @State var calendarState: CalendarViewState = .init()
    
    SwipeCalendarView(calendarState: .constant(calendarState))
        .environmentObject(AuthenticationManager())
}
