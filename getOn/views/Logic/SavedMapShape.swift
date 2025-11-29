//
//  SavedMapShape.swift
//  getOn
//
//  Created by Shannah on 29/11/2025.
//


import SwiftUI
import MapKit

struct SavedMapShape: Codable, Identifiable {
    var id = UUID()
    var coordinates: [CodableCoordinate]
}
