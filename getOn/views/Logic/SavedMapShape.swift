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

extension SavedMapShape {
    func toDTO() -> SavedMapShapeDTO {
        SavedMapShapeDTO(id: id, coordinates: coordinates.map { CodableCoordinateDTO(latitude: $0.latitude, longitude: $0.longitude) })
    }
    
    init(from dto: SavedMapShapeDTO) {
        self.id = dto.id
        self.coordinates = dto.coordinates.map { CodableCoordinate(CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)) }
    }
}
