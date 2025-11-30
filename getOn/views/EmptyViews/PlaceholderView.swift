//
//  PlaceholderView.swift
//  getOn
//
//  Created by Shannah on 30/11/2025.
//


import SwiftUI

struct PlaceholderView: View {
    let title: String
    let icon: String
    
    var body: some View {
        ZStack {
            // Reuse the liquid background for consistency
            LiquidBackground()
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 80))
                    .foregroundStyle(.white.opacity(0.1))
                    .shadow(radius: 10)
                
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Text("Coming Soon")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
    }
}