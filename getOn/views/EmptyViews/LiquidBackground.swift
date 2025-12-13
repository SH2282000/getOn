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
            Color(red: 0.1, green: 0.1, blue: 0.2)
            
            GeometryReader { proxy in
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.4))
                        .frame(width: 300, height: 300)
                        .blur(radius: 60)
                        .offset(x: animate ? -100 : 100, y: animate ? -100 : 100)
                    
                    Circle()
                        .fill(Color.purple.opacity(0.4))
                        .frame(width: 300, height: 300)
                        .blur(radius: 60)
                        .offset(x: animate ? 100 : -100, y: animate ? 100 : -100)
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
    LiquidBackground()
}
