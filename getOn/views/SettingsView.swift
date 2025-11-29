//
//  SettingsView.swift
//  getOn
//
//  Created by Shannah on 29/11/2025.
//


import SwiftUI
import MapKit

struct SettingsView: View {
    @Binding var placeName: String
    @Binding var mapStyleSelection: Int
    @Binding var cardColor: Color
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Information") {
                    TextField("Place Name", text: $placeName)
                }
                
                Section("Appearance") {
                    ColorPicker("Glass Tint", selection: $cardColor)
                }
            }
            .navigationTitle("Customize View")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


#Preview {
    SettingsView(
        placeName: .constant("Munich"),
        mapStyleSelection: .constant(0),
        cardColor: .constant(.blue)
    )
}
