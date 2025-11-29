//
//  MapElements.swift
//  getOn
//
//  Created by Shannah on 29/11/2025.
//

import SwiftUI
import MapKit

struct MapElements: View {
    var placeName: String
    var currentMapStyle: MapStyle
    var initialRegion: MKCoordinateRegion
    var followsUserLocation: Bool

    // Internal state derived from inputs
    @State private var position: MapCameraPosition

    init(
        placeName: String = "Location",
        currentMapStyle: MapStyle = .standard,
        initialRegion: MKCoordinateRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.3346, longitude: -122.0090),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ),
        followsUserLocation: Bool = false
    ) {
        self.placeName = placeName
        self.currentMapStyle = currentMapStyle
        self.initialRegion = initialRegion
        self.followsUserLocation = followsUserLocation
        // Initialize position from inputs
        self._position = State(initialValue: .region(initialRegion))
    }
    
    var body: some View {
        Map(position: $position) {
            Marker(placeName, coordinate: position.region?.center ?? CLLocationCoordinate2D(latitude: 37.3346, longitude: -122.0090))
            
            
        }
        .mapStyle(currentMapStyle)
        .ignoresSafeArea()

    }
}

#Preview {
    MapElements(placeName: "Munich", currentMapStyle: .standard, initialRegion:  MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37, longitude: -122), span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)), followsUserLocation: true)
}
