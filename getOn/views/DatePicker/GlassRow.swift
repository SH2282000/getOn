//
//  GlassRow.swift
//  getOn
//
//  Created by Shannah on 29/11/2025.
//


import SwiftUI

struct GlassRow<Content: View>: View {
    let isActive: Bool
    let icon: String
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(title)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(isActive ? .white : .white.opacity(0.5))
                
                Spacer()
                
                Image(systemName: icon)
                    .foregroundStyle(isActive ? .white : .white.opacity(0.3))
            }
            
            content
                .foregroundStyle(isActive ? .primary : .secondary)
                .opacity(isActive ? 1.0 : 0.6)
        }
        .padding(15)
        .background {
            ZStack {
                // 1. Base Glass Material
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .opacity(isActive ? 1.0 : 0.6) // Dim inactive cards
                
                // 2. Active State: Glow & Border
                if isActive {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [.white.opacity(0.8), .white.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .shadow(color: .white.opacity(0.2), radius: 10, x: 0, y: 0)
                } else {
                    // Inactive State: Subtle Border
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                }
            }
        }
        // Scale effect for active focus
        .scaleEffect(isActive ? 1.02 : 0.98)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isActive)
    }
}

#Preview("TITLE") {
    GlassRow(
        isActive: true,
        icon: "waveform.path.ecg",
        title: "TITLE"
    ){
        HStack {
            Text("Go to Ski")
                .font(.largeTitle.bold())
                .contentTransition(.numericText())
        }
    }
}


#Preview("DESCRIPTION") {
    GlassRow(
        isActive: true,
        icon: "waveform.path.ecg",
        title: "DESCRIPTION"
    ){
        HStack {
            Text("Day")
                .fontWeight(.medium)
                .contentTransition(.numericText())
        }
    }
}
