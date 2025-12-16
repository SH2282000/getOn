//
//  ExpandableGlassRow.swift
//  getOn
//
//  Created by Shannah on 16/12/2025.
//


import SwiftUI

struct ExpandableGlassRow<Content: View>: View {
    let isActive: Bool
    let icon: String
    let title: String
    let onTap: () -> Void
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(spacing: 0) {
            GlassRow(isActive: isActive, icon: icon, title: title) {
                // Empty content for the header, as the actual content is below
                EmptyView()
                if isActive {
                    content
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .transition(.opacity.combined(with: .scale(scale: 0.5, anchor: .top)))
                    
                }
            }
            .onTapGesture(perform: onTap)
        }
    }
}
