//
//  LiquidTabBar.swift
//  getOn
//
//  Created by Shannah on 30/11/2025.
//


import SwiftUI

struct LiquidTabBar: View {
    @Binding var selectedTab: Tabs
    @Namespace private var animation
    
    var body: some View {
        HStack {
            ForEach(Tabs.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        // Icon
                        Image(systemName: tab.rawValue)
                            .font(.title2)
                            .symbolVariant(selectedTab == tab ? .fill : .none)
                            .scaleEffect(selectedTab == tab ? 1.2 : 1.0)
                        
                        // Label (Optional, can hide for cleaner look)
                        if selectedTab == tab {
                            Text(tab.title)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .transition(.opacity.combined(with: .scale))
                                .lineLimit(1)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .glassEffect(.clear)
                    .foregroundStyle(selectedTab == tab ? .secondary : .secondary)
                    .overlay(
                        // Active Indicator (Glowing Orb effect)
                        ZStack {
                            if selectedTab == tab {
                                Circle()
                                    .fill(Color.white.opacity(0.5))
                                    .frame(width: 50, height: 50)
                                    .blur(radius: 15)
                                    .matchedGeometryEffect(id: "activeTab", in: animation)
                            }
                        }
                    )
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(
            ZStack {
                // Glass Material
                RoundedRectangle(cornerRadius: 35, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                // Subtle Gradient Tint
                RoundedRectangle(cornerRadius: 35, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.2),
                                .white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Glass Border
                RoundedRectangle(cornerRadius: 35, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.5),
                                .white.opacity(0.1),
                                .white.opacity(0.05),
                                .white.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
        )
    }
}
