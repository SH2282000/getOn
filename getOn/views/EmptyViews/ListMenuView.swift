//
//  ListMenuView.swift
//  getOn
//
//  Created by Shannah on 30/11/2025.
//

import SwiftUI

struct ListMenuView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // Ambient Background
                LiquidGlassBackground()
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header
                    Text("Menu")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        .padding(.top, 50)
                    
                    Spacer()
                    
                    // Menu Items
                    VStack(spacing: 20) {
                        NavigationLink(destination: EventsView().navigationBarBackButtonHidden(false)) {
                            MenuButtonLabel(title: "Events", icon: "calendar.badge.clock")
                        }
                        
                        NavigationLink(destination: Text("Profile Settings (Placeholder)")) {
                            MenuButtonLabel(title: "Profile", icon: "person.crop.circle")
                        }
                        
                        NavigationLink(destination: Text("Settings (Placeholder)")) {
                            MenuButtonLabel(title: "Settings", icon: "gearshape.fill")
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
            }
        }
    }
}

// MARK: - Subviews

struct MenuButtonLabel: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 30)
            
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.body)
                .opacity(0.6)
        }
        .padding()
        .frame(height: 70)
        .foregroundStyle(.white)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .opacity(0.9) // Enhance the glass effect
                
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(LinearGradient(
                        colors: [.white.opacity(0.6), .white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ), lineWidth: 1)
            }
        )
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct LiquidGlassBackground: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Deep base color
            Color(red: 0.1, green: 0.1, blue: 0.2)
            
            // Animated Orbs
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
                    
                    Circle()
                        .fill(Color.cyan.opacity(0.4))
                        .frame(width: 200, height: 200)
                        .blur(radius: 50)
                        .offset(x: animate ? -50 : 150, y: animate ? 150 : -50)
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
    ListMenuView()
}
