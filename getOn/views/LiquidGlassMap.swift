//
//  LiquidGlassMap.swift
//  getOn
//
//  Created by Shannah on 29/11/2025.
//
import SwiftUI
import MapKit

// MARK: - Models for Persistence
// CLLocationCoordinate2D is not Codable by default, so we need a helper struct.
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

struct SavedMapShape: Codable, Identifiable {
    var id = UUID()
    var coordinates: [CodableCoordinate]
}

// MARK: - Main View
struct LiquidGlassMap: View {
    // MARK: - Map State
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.3346, longitude: -122.0090),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )
    
    // MARK: - Drawing State
    @State private var isDrawingMode: Bool = false
    @State private var currentDrawingPath: [CLLocationCoordinate2D] = []
    @State private var savedShapes: [SavedMapShape] = []
    @State private var mapStyleSelection: Int = 0
    
    // MARK: - Initialization
    // Load saved shapes on init
    init() {
        if let data = try? Data(contentsOf: Self.shapesFileURL),
           let shapes = try? JSONDecoder().decode([SavedMapShape].self, from: data) {
            _savedShapes = State(initialValue: shapes)
        }
    }
    
    var body: some View {
        ZStack {
            // 1. Map Reader enables coordinate conversion
            MapReader { proxy in
                ZStack {
                    // 2. The Map Layer
                    Map(position: $position) {
                        // User's current partial drawing (Fuzzy Multicolor Path)
                        if !currentDrawingPath.isEmpty {
                            MapPolyline(coordinates: currentDrawingPath)
                                .stroke(
                                    LinearGradient(
                                        colors: [.red, .purple, .blue, .cyan, .green, .yellow, .orange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round)
                                )
                        }
                        
                        // Previously saved shapes (Overlay Zones)
                        ForEach(savedShapes) { shape in
                            MapPolygon(coordinates: shape.coordinates.map { $0.toCoreLocation })
                                .foregroundStyle(.indigo.opacity(0.3))
                        }
                        
                        // Optional Marker
                        Marker("Apple Park", coordinate: CLLocationCoordinate2D(latitude: 37.3346, longitude: -122.0090))
                    }
                    .mapStyle(currentMapStyle)
                    
                    // 3. Gesture Overlay (Active only in Draw Mode)
                    if isDrawingMode {
                        Color.white.opacity(0.001) // Nearly transparent view to catch gestures
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        // Convert screen point to map coordinate
                                        if let coordinate = proxy.convert(value.location, from: .local) {
                                            currentDrawingPath.append(coordinate)
                                        }
                                    }
                                    .onEnded { _ in
                                        saveCurrentPath()
                                    }
                            )
                    }
                }
            }
            .ignoresSafeArea()
            
            // 4. Liquid Glass Control Panel
            VStack {
                Spacer()
                
                LiquidControlPanel(
                    isDrawing: $isDrawingMode,
                    shapeCount: savedShapes.count,
                    onClear: clearShapes,
                    mapStyleSelection: $mapStyleSelection
                )
                .padding(.bottom, 40)
            }
        }
    }
    
    // MARK: - Logic
    
    private func saveCurrentPath() {
        guard !currentDrawingPath.isEmpty else { return }
        
        let newShape = SavedMapShape(coordinates: currentDrawingPath.map { CodableCoordinate($0) })
        savedShapes.append(newShape)
        currentDrawingPath = [] // Reset current path (Path disappears)
        
        // Save to disk
        saveToDisk()
    }
    
    private func clearShapes() {
        savedShapes.removeAll()
        currentDrawingPath.removeAll()
        try? FileManager.default.removeItem(at: Self.shapesFileURL)
    }
    
    private func saveToDisk() {
        do {
            let data = try JSONEncoder().encode(savedShapes)
            try data.write(to: Self.shapesFileURL)
            print("Saved to: \(Self.shapesFileURL)")
        } catch {
            print("Error saving shapes: \(error)")
        }
    }
    
    private static var shapesFileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("saved_map_shapes.json")
    }
    
    var currentMapStyle: MapStyle {
        switch mapStyleSelection {
        case 0: return .standard(elevation: .realistic)
        case 1: return .hybrid(elevation: .realistic)
        case 2: return .imagery(elevation: .realistic)
        default: return .standard
        }
    }
}

// MARK: - The Liquid Glass Controls


#Preview {
    LiquidGlassMap()
}
