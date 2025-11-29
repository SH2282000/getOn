//
//  LiquidMapTransitionView.swift
//  getOn
//
//  Created by Shannah on 29/11/2025.
//

import SwiftUI
import MapKit

// MARK: - Parent Container
struct LiquidMapTransitionView: View {
    // Transition State
    @State private var isExpanded: Bool = false
    @Namespace private var glassNamespace // For matchedGeometryEffect

    var body: some View {
        ZStack {
            // 1. The Map (Always in background, but interacts when not expanded)
            MainView(isExpanded: $isExpanded, namespace: glassNamespace)
                .zIndex(0)

            // 2. The Expanded View (Overlays when active)
            if isExpanded {
                SwipeCalendarView(isExpanded: $isExpanded)
                    .zIndex(1)
                    .transition(.asymmetric(
                        insertion: .opacity.animation(.easeIn(duration: 0.2)),
                        removal: .opacity.animation(.easeOut(duration: 0.2).delay(0.2))
                    ))
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isExpanded)
    }
}
