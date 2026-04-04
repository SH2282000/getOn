//
//  MapShapeManager.swift
//  getOn
//
//  Shared utilities for map shape operations, used by MapView and SearchView.
//

import SwiftUI
import MapKit

enum MapShapeManager {

    /// Returns the animated coordinates for a shape based on the expansion progress (0.0 = centroid, 1.0 = original).
    static func animatedCoordinates(for shape: SavedMapShape, progress: Double) -> [CLLocationCoordinate2D] {
        let coordinates = shape.coordinates.map { $0.toCoreLocation }

        guard !coordinates.isEmpty else { return coordinates }

        if progress >= 1.0 {
            return coordinates
        }

        // Calculate centroid
        let latitudeSum = coordinates.reduce(0) { $0 + $1.latitude }
        let longitudeSum = coordinates.reduce(0) { $0 + $1.longitude }
        let count = Double(coordinates.count)
        let centroid = CLLocationCoordinate2D(latitude: latitudeSum / count, longitude: longitudeSum / count)

        // Interpolate from centroid toward actual position
        return coordinates.map { coord in
            let lat = centroid.latitude + (coord.latitude - centroid.latitude) * progress
            let lon = centroid.longitude + (coord.longitude - centroid.longitude) * progress
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
    }

    /// Returns the file URL for persisting shapes associated with a given selectedID.
    static func shapesFileURL(for selectedID: UUID) -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("saved_map_shapes_\(selectedID).json")
    }

    /// Loads shapes from disk for a given selectedID.
    static func loadShapes(for selectedID: UUID) async -> [SavedMapShape] {
        do {
            let data = try Data(contentsOf: shapesFileURL(for: selectedID))
            return try JSONDecoder().decode([SavedMapShape].self, from: data)
        } catch {
            return []
        }
    }

    /// Returns the MapStyle for a given selection index.
    static func mapStyle(for selection: Int) -> MapStyle {
        switch selection {
        case 0: return .standard(elevation: .realistic)
        case 1: return .hybrid(elevation: .realistic)
        default: return .standard
        }
    }
}
