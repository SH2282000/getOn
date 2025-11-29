//
//  GlassControlPanel.swift
//  getOn
//
//  Created by Shannah on 29/11/2025.
//

import SwiftUI

struct GlassControlPanel: View {
    @Binding var isExpanded: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Current Selection")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Tap or Swipe Up")
                    .font(.headline)
            }
            Spacer()
            Image(systemName: "chevron.up.circle.fill")
                .font(.title)
                .foregroundStyle(.blue.opacity(0.8))
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding(.horizontal)
    }
}

