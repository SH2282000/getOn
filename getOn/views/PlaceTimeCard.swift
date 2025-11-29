//
//  LiquidGlassCard.swift
//  getOn
//
//  Created by Shannah on 29/11/2025.
//


import SwiftUI
import MapKit

struct PlaceTimeCard: View {
    var placeName: String
    var tintColor: Color
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { context in
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(context.date, format: .dateTime.hour().minute())
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Text(context.date, format: .dateTime.weekday(.wide).month().day())
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                }
                
                Rectangle()
                    .fill(.secondary.opacity(0.2))
                    .frame(width: 1, height: 50)
                
                // Location
                VStack(alignment: .leading, spacing: 4) {
                    Image(systemName: "location.fill") // getting direction button
                        .font(.caption)
                        .foregroundStyle(tintColor)
                        .padding(6)
                        .background(tintColor.opacity(0.2), in: Circle())
                    
                    Text(placeName)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 24)
            .background {
                // The "Liquid" Stack
                ZStack {
                    // 1. Base blur
                    Rectangle()
                        .fill(.ultraThinMaterial)
                    
                    // 2. Subtle color tint wash
                    Rectangle()
                        .fill(tintColor.opacity(0.1))
                    
                    // 3. Glare gradient to simulate curved glass
                    LinearGradient(
                        colors: [
                            .white.opacity(0.25),
                            .white.opacity(0.0),
                            .white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 35, style: .continuous))
            .overlay {
                // The "Frost" Border
                RoundedRectangle(cornerRadius: 35, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.6),
                                .white.opacity(0.1),
                                .white.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            }
            // Depth Shadow
            .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 10)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
}


#Preview {
    PlaceTimeCard(placeName: "Munich", tintColor: Color(.blue))
}
