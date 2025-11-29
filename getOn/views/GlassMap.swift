//
//  GlassMap.swift
//  getOn
//
//  Created by Shannah on 29/11/2025.
//
import SwiftUI
import MapKit

struct GlassMap: View {
    @Binding var isExpanded: Bool
    var namespace: Namespace.ID
    
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.3346, longitude: -122.0090),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )
    
    @State private var isDrawingMode: Bool = false
    @State private var currentDrawingPath: [CLLocationCoordinate2D] = []
    @State private var savedShapes: [SavedMapShape] = []
    @State private var mapStyleSelection: Int = 0
    
    // Concrete Place and Time
    @State private var placeName: String = "Cupertino, CA"
    @State private var showSettings: Bool = false
    @State private var cardColor: Color = .white
    

    // Load saved shapes on init
    init(isExpanded: Binding<Bool>, namespace: Namespace.ID) {
        _isExpanded = isExpanded
        self.namespace = namespace
        if let data = try? Data(contentsOf: Self.shapesFileURL),
           let shapes = try? JSONDecoder().decode([SavedMapShape].self, from: data) {
            _savedShapes = State(initialValue: shapes)
        }
    }
    
    var body: some View {
            ZStack {
                MapReader { proxy in
                    ZStack {
                        
                        Map(position: $position) {
                            ForEach(savedShapes) { shape in
                                MapPolygon(coordinates: shape.coordinates.map { $0.toCoreLocation })
                                    .foregroundStyle(.indigo.opacity(0.3))
                            }
                            
                            
                            Marker("Apple Park", coordinate: CLLocationCoordinate2D(latitude: 37.3346, longitude: -122.0090))
                        }
                        .mapStyle(currentMapStyle)
                        
                        if isDrawingMode {
                            RainbowTrailView(
                                onUpdate: { location in
                                    // Convert screen point to map coordinate
                                    if let coordinate = proxy.convert(location, from: .local) {
                                        currentDrawingPath.append(coordinate)
                                    }
                                },
                                onEnd: {
                                    saveCurrentPath()
                                }
                            )
                        }
                    }
                }
                .ignoresSafeArea()

                VStack {
                    Spacer()
                        if !isExpanded {
                        ControlPanel(isExpanded: $isExpanded, isDrawing: $isDrawingMode, shapeCount: savedShapes.count, onClear: clearShapes, mapStyleSelection: $mapStyleSelection)
                            .matchedGeometryEffect(id: "GlassBackground", in: namespace)
                            .frame(maxWidth: 360)
                            .padding(.bottom, 40)
                            // Trigger Expansion
                            .onTapGesture {
                                withAnimation { isExpanded = true }
                            }
                            .gesture(
                                DragGesture(minimumDistance: 20, coordinateSpace: .global)
                                    .onEnded { value in
                                        if value.translation.height < -50 { // Swipe Up
                                            withAnimation { isExpanded = true }
                                        }
                                    }
                            )
                    }
                }
        }
    }
    
    // MARK: - Logic
    private func saveCurrentPath() {
        guard !currentDrawingPath.isEmpty else { return }
        
        let newShape = SavedMapShape(coordinates: currentDrawingPath.map { CodableCoordinate($0) })
        savedShapes.append(newShape)
        currentDrawingPath = [] // Reset current path (Path disappears)
        
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
//        case 2: return .imagery(elevation: .realistic)
        default: return .standard
        }
    }
}

#Preview {
    @Previewable @Namespace var glassNamespace
    GlassMap(isExpanded: .constant(false), namespace: glassNamespace)
}
