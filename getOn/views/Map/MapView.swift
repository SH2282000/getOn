//
//  GlassMap.swift
//  getOn
//
//  Created by Shannah on 29/11/2025.
//
import SwiftUI
import MapKit

struct MapView: View {
    @Binding var calendarStates: [CalendarViewState]
    @Binding var selectedID: UUID
    var namespace: Namespace.ID
    
    @StateObject private var locationManager = LocationManager()
    
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    @State private var isDrawingMode: Bool = false
    @State private var currentDrawingPath: [CLLocationCoordinate2D] = []
    @State private var mapStyleSelection: Int = 0
    @State private var shapeAnimations: [UUID: Double] = [:]
    
    private var selectedStateBinding: Binding<CalendarViewState> {
        Binding(
            get: {
                calendarStates.first(where: { $0.uuid == selectedID }) ?? CalendarViewState()
            },
            set: { newValue in
                if let index = calendarStates.firstIndex(where: { $0.uuid == selectedID }) {
                    calendarStates[index] = newValue
                }
            }
        )
    }
    
    private var selectedState: CalendarViewState {
        selectedStateBinding.wrappedValue
    }
    
    var body: some View {
            ZStack {
                MapReader { proxy in
                    ZStack {
                        
                        Map(position: $position) {
                            UserAnnotation()
                            
                            ForEach(selectedState.savedShapes) { shape in
                                MapPolygon(coordinates: getAnimatedCoordinates(for: shape))
                                    .foregroundStyle(selectedState.color.opacity(0.3))
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
                    
                    if !selectedState.isExpanded {
                        TabView(selection: $selectedID) {
                            ForEach($calendarStates) { $state in
                                ControlPanel(
                                    calendarState: $state,
                                    title: $state.title,
                                    isExpanded: $state.isExpanded,
                                     isDrawing: $isDrawingMode,
                                    shapeCount: state.savedShapes.count, onClear: clearShapes, mapStyleSelection: $mapStyleSelection)
                                .glassEffectTransition(.matchedGeometry)
                                .tag(state.uuid)
                                .padding(.horizontal, 20)
                                .onTapGesture {
                                    withAnimation { state.isExpanded = true }
                                }
                                .gesture(
                                    DragGesture(minimumDistance: 20, coordinateSpace: .global)
                                        .onEnded { value in
                                            if value.translation.height < -50 { // Swipe Up
                                                withAnimation { state.isExpanded = true }
                                            }
                                        }
                                )
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(height: 250) // Adjust height as needed for ControlPanel
                        .matchedGeometryEffect(id: "GlassBackground", in: namespace)
                    }
                }
        }
        .task(id: selectedID) {
            await loadShapes()
        }
    }
}

extension MapView {
    // MARK: - Logic
    
    private func getAnimatedCoordinates(for shape: SavedMapShape) -> [CLLocationCoordinate2D] {
        let progress = shapeAnimations[shape.id] ?? 1.0
        let coordinates = shape.coordinates.map { $0.toCoreLocation }
        
        if progress >= 1.0 {
            return coordinates
        }
        
        // Calculate centroid
        let latitudeSum = coordinates.reduce(0) { $0 + $1.latitude }
        let longitudeSum = coordinates.reduce(0) { $0 + $1.longitude }
        let count = Double(coordinates.count)
        let centroid = CLLocationCoordinate2D(latitude: latitudeSum / count, longitude: longitudeSum / count)
        
        // Interpolate
        return coordinates.map { coord in
            let lat = centroid.latitude + (coord.latitude - centroid.latitude) * progress
            let lon = centroid.longitude + (coord.longitude - centroid.longitude) * progress
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
    }

    private func saveCurrentPath() {
        guard !currentDrawingPath.isEmpty else { return }
        
        let newShape = SavedMapShape(coordinates: currentDrawingPath.map { CodableCoordinate($0) })
        
        // Start animation from 0
        shapeAnimations[newShape.id] = 0.0
        
        selectedStateBinding.wrappedValue.savedShapes.append(newShape)
        currentDrawingPath = [] // Reset current path (Path disappears)
        
        // Animate to 1
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            shapeAnimations[newShape.id] = 1.0
        }
        
        Task {
            await saveToDisk()
        }
    }
    
    private func clearShapes() {
        selectedStateBinding.wrappedValue.savedShapes.removeAll()
        currentDrawingPath.removeAll()
        shapeAnimations.removeAll()
        Task {
            try? FileManager.default.removeItem(at: shapesFileURL)
        }
    }
    
    private func loadShapes() async {
        do {
            let data = try Data(contentsOf: shapesFileURL)
            let shapes = try JSONDecoder().decode([SavedMapShape].self, from: data)
            await MainActor.run {
                self.selectedStateBinding.wrappedValue.savedShapes = shapes
                // Ensure loaded shapes are fully visible
                for shape in shapes {
                    self.shapeAnimations[shape.id] = 1.0
                }
            }
        } catch {
            print("Error loading shapes: \(error)")
            // If file doesn't exist, just clear shapes for this state
             await MainActor.run {
                self.selectedStateBinding.wrappedValue.savedShapes = []
            }
        }
    }

    private func saveToDisk() async {
        do {
            let data = try JSONEncoder().encode(selectedState.savedShapes)
            try data.write(to: shapesFileURL)
            print("Saved to: \(shapesFileURL)")
        } catch {
            print("Error saving shapes: \(error)")
        }
    }
    
    private var shapesFileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("saved_map_shapes_\(selectedID).json")
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
    @Previewable @State var calendarStates: [CalendarViewState] = [CalendarViewState()]
    @Previewable @State var selectedID: UUID = UUID()

    MapView(calendarStates: $calendarStates, selectedID: $selectedID, namespace: glassNamespace)
        .onAppear {
            if let first = calendarStates.first {
                selectedID = first.uuid
            }
        }
}
