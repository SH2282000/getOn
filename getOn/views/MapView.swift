//
//  Map.swift
//  getOn
//
//  Created by Shannah on 29/11/2025.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.3346, longitude: -122.0090),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    @State private var placeName: String = "Cupertino, CA"
    @State private var showSettings: Bool = false
    @State private var mapStyleSelection: Int = 0
    @State private var cardColor: Color = .white
    
    var body: some View {
        ZStack {
            Map(position: $position) {
                Marker(placeName, coordinate: position.region?.center ?? CLLocationCoordinate2D(latitude: 37.3346, longitude: -122.0090))
                
                
            }
            .mapStyle(currentMapStyle)
            .ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    Picker("Style", selection: $mapStyleSelection) {
                        Image(systemName: "map").tag(0)
                        Image(systemName: "globe.americas.fill").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 100)
                    .padding()
                }
                
                Spacer()
                
                PlaceTimeCard(
                    placeName: placeName,
                    tintColor: cardColor
                )
                .padding(.bottom, 50)
                .onTapGesture {
                    showSettings.toggle()
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(
                placeName: $placeName,
                mapStyleSelection: $mapStyleSelection,
                cardColor: $cardColor
            )
            .presentationDetents([.height(300), .medium])
            .presentationBackground(.thinMaterial)
        }
    }
    
    var currentMapStyle: MapStyle {
        switch mapStyleSelection {
        case 0: return .standard(elevation: .realistic)
        case 1: return .hybrid(elevation: .realistic)
//        case 2: return .imagery(elevation: .realistic)
        default: return .standard
        }
    }
}

extension MKCoordinateRegion: @retroactive Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        lhs.center.latitude == rhs.center.latitude &&
        lhs.center.longitude == rhs.center.longitude
    }
}

#Preview {
    MapView()
}

