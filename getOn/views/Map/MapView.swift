//
//  GlassMap.swift
//  getOn
//
//  Created by Shannah on 29/11/2025.
//
import SwiftUI
import MapKit

struct MapView: View {
    @Binding var calendarState: CalendarViewState
    var namespace: Namespace.ID
    
    @StateObject private var locationManager = LocationManager()
    
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    @State private var isDrawingMode: Bool = false
    @State private var currentDrawingPath: [CLLocationCoordinate2D] = []
    @State private var savedShapes: [SavedMapShape] = []
    @State private var mapStyleSelection: Int = 0
    
    var body: some View {
            ZStack {
                MapReader { proxy in
                    ZStack {
                        
                        Map(position: $position) {
                            UserAnnotation()
                            
                            ForEach(savedShapes) { shape in
                                MapPolygon(coordinates: shape.coordinates.map { $0.toCoreLocation })
                                    .foregroundStyle(.indigo.opacity(0.3))
                            }
                            
                            
                            Marker("Munich", coordinate: CLLocationCoordinate2D(latitude: 37.3346, longitude: -122.0090))
                        }
                        .mapStyle(currentMapStyle)
                        .onAppear {
                            locationManager.requestLocation()
                        }
                        
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
                    if !calendarState.isExpanded {
                            ControlPanel(
                                calendarState: $calendarState,
                                title: $calendarState.title,
                                isExpanded: $calendarState.isExpanded,
                                 isDrawing: $isDrawingMode,
                                 shapeCount: savedShapes.count, onClear: clearShapes, mapStyleSelection: $mapStyleSelection)
                            .matchedGeometryEffect(id: "GlassBackground", in: namespace)
                            .frame(maxWidth: 360)
                            .padding(.bottom, 40)
                            // Trigger Expansion
                            .onTapGesture {
                                withAnimation { calendarState.isExpanded = true }
                            }
                            .gesture(
                                DragGesture(minimumDistance: 20, coordinateSpace: .global)
                                    .onEnded { value in
                                        if value.translation.height < -50 { // Swipe Up
                                            withAnimation { calendarState.isExpanded = true }
                                        }
                                    }
                            )
                    }
                }
        }
        .task {
            await loadShapes()
        }
    }
}

extension MapView {
    // MARK: - Logic
    private func saveCurrentPath() {
        guard !currentDrawingPath.isEmpty else { return }
        
        let newShape = SavedMapShape(coordinates: currentDrawingPath.map { CodableCoordinate($0) })
        savedShapes.append(newShape)
        currentDrawingPath = [] // Reset current path (Path disappears)
        
        Task {
            await saveToDisk()
        }
    }
    
    private func clearShapes() {
        savedShapes.removeAll()
        currentDrawingPath.removeAll()
        Task {
            try? FileManager.default.removeItem(at: Self.shapesFileURL)
        }
    }
    
    private func loadShapes() async {
        do {
            let data = try Data(contentsOf: Self.shapesFileURL)
            let shapes = try JSONDecoder().decode([SavedMapShape].self, from: data)
            await MainActor.run {
                self.savedShapes = shapes
            }
        } catch {
            print("Error loading shapes: \(error)")
        }
    }

    private func saveToDisk() async {
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
    @Previewable @State var calendarState: CalendarViewState = .init()

    MapView(calendarState: .constant(calendarState), namespace: glassNamespace)
}
