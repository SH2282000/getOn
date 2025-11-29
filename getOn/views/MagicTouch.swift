//
//  MagicTouch.swift
//  getOn
//
//  Created by Shannah on 29/11/2025.
//

import SwiftUI

struct MagicTouch: View {
    var body: some View {
        
        let currentDrawingPath: CurrentD
        if !currentDrawingPath.isEmpty {
            MapPolyline(coordinates: currentDrawingPath)
                .stroke(
                    LinearGradient(
                        colors: [.red, .purple, .blue, .cyan, .green, .yellow, .orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round)
                )
        }
        
        
        Color.white.opacity(0.001) // Nearly transparent view to catch gestures
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        // Convert screen point to map coordinate
                        if let coordinate = proxy.convert(value.location, from: .local) {
                            currentDrawingPath.append(coordinate)
                        }
                    }
                    .onEnded { _ in
                        saveCurrentPath()
                    }
            )
}

#Preview {
    MagicTouch()
}
