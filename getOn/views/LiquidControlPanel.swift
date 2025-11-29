//
//  LiquidControlPanel.swift
//  getOn
//
//  Created by Shannah on 29/11/2025.
//


import SwiftUI
import MapKit

struct LiquidControlPanel: View {
    @Binding var isDrawing: Bool
    var shapeCount: Int
    var onClear: () -> Void
    @Binding var mapStyleSelection: Int
    
    var body: some View {
        VStack(spacing: 20) {
            
            // Status Info
            HStack {
                VStack(alignment: .leading) {
                    Text(isDrawing ? "Drawing Mode" : "View Mode")
                        .font(.headline)
                        .foregroundStyle(isDrawing ? .blue : .primary)
                    Text("\(shapeCount) zones saved")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            
            Divider()
                .overlay(.white.opacity(0.5))
            
            // Action Buttons
            HStack(spacing: 15) {
                Button(action: { isDrawing.toggle() }) {
                    Label(isDrawing ? "Finish" : "Zone", systemImage: "pencil.tip.crop.circle")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isDrawing ? .blue.opacity(0.2) : .white.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.white.opacity(0.4), lineWidth: 1)
                        )
                }
                .foregroundStyle(isDrawing ? .blue : .primary)
                
                Button(action: onClear) {
                    Label("Clear", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.red.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .foregroundStyle(.red)
            }
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .strokeBorder(.white.opacity(0.4), lineWidth: 1.5)
        )
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        .padding(.horizontal)
    }
}


#Preview("LiquidControlPanel Preview") {
    LiquidControlPanel(
        isDrawing: .constant(false),
        shapeCount: 3,
        onClear: {},
        mapStyleSelection: .constant(0)
    )
    .padding()
}
