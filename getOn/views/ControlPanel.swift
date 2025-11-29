//
//  ControlPanel.swift
//  getOn
//
//  Created by Shannah on 29/11/2025.
//


import SwiftUI
import MapKit

struct ControlPanel: View {
    @Binding var isExpanded: Bool
    @Binding var isDrawing: Bool
    var shapeCount: Int
    var onClear: () -> Void
    @Binding var mapStyleSelection: Int
    
    var body: some View {
        VStack {
            HStack(spacing: 12) {
                VStack(alignment: .leading) {
                    // time goes here
                    TimeDate(
                        date: Date(),
                    )
                    
                    Text("\(shapeCount) zones saved")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                // ertical Divider
                Rectangle()
                    .fill(.secondary.opacity(0.2))
                    .frame(width: 1, height: 50)
                
                Button(action: { isDrawing.toggle() }) {
                    Image(systemName: isDrawing ? "checkmark" : "pencil.tip.crop.circle")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(width: 44, height: 44) // Standard touch target size
                        .background(isDrawing ? .blue : .white.opacity(0.2))
                        .foregroundStyle(isDrawing ? .white : .blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isDrawing ? .clear : .white.opacity(0.4), lineWidth: 1)
                        )
                        // Important for icon-only buttons
                        .accessibilityLabel(isDrawing ? "Finish Drawing" : "Start Zone")
                }

                Button(action: onClear) {
                    Image(systemName: "trash")
                        .font(.title3)
                        .frame(width: 44, height: 44)
                        .background(.red.opacity(0.1))
                        .foregroundStyle(.red)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .accessibilityLabel("Clear Canvas")
                }
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


#Preview("ControlPanel Preview") {
    ControlPanel(
        isExpanded: .constant(false),
        isDrawing: .constant(false),
        shapeCount: 3,
        onClear: {},
        mapStyleSelection: .constant(0)
    )
    .padding()
}
