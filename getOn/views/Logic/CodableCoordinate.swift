//
//  CodableCoordinate.swift
//  getOn
//
//  Created by Shannah on 29/11/2025.
//


import SwiftUI
import MapKit

struct CodableCoordinate: Codable, Equatable {
    let latitude: Double
    let longitude: Double
    
    init(_ coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    var toCoreLocation: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
