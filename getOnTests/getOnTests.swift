//
//  getOnTests.swift
//  getOnTests
//
//  Created by Shannah on 29/11/2025.
//

import XCTest
@testable import getOn
import MapKit
import SwiftUI

final class CalendarViewStateDTOTests: XCTestCase {

    // MARK: - CalendarViewState ↔ DTO Round-Trip

    func testCalendarViewStateToDTOAndBack() {
        let original = CalendarViewState()

        let dto = original.toDTO()
        let restored = CalendarViewState(from: dto)

        XCTAssertEqual(restored.uuid, original.uuid)
        XCTAssertEqual(restored.title, original.title)
        XCTAssertEqual(restored.isExpanded, original.isExpanded)
        XCTAssertEqual(restored.occurrences, original.occurrences)
        XCTAssertEqual(restored.isMonthly, original.isMonthly)
        XCTAssertEqual(restored.description, original.description)
        XCTAssertEqual(restored.startMonth, original.startMonth)
        XCTAssertEqual(restored.startDay, original.startDay)
        XCTAssertEqual(restored.duration, original.duration)
        XCTAssertEqual(restored.savedShapes.count, original.savedShapes.count)
    }

    func testCalendarViewStateDTOPreservesCustomValues() {
        var state = CalendarViewState()
        state.title = "Test Event"
        state.occurrences = 5
        state.isMonthly = true
        state.description = "A test description"
        state.startMonth = 6
        state.startDay = 15
        state.duration = 3

        let dto = state.toDTO()

        XCTAssertEqual(dto.title, "Test Event")
        XCTAssertEqual(dto.occurrences, 5)
        XCTAssertTrue(dto.isMonthly)
        XCTAssertEqual(dto.description, "A test description")
        XCTAssertEqual(dto.startMonth, 6)
        XCTAssertEqual(dto.startDay, 15)
        XCTAssertEqual(dto.duration, 3)
    }

    func testCalendarViewStateDTOWithShapes() {
        var state = CalendarViewState()
        let coord1 = CodableCoordinate(CLLocationCoordinate2D(latitude: 48.1351, longitude: 11.5820))
        let coord2 = CodableCoordinate(CLLocationCoordinate2D(latitude: 48.1400, longitude: 11.5900))
        let shape = SavedMapShape(coordinates: [coord1, coord2])
        state.savedShapes = [shape]

        let dto = state.toDTO()
        let restored = CalendarViewState(from: dto)

        XCTAssertEqual(restored.savedShapes.count, 1)
        XCTAssertEqual(restored.savedShapes[0].coordinates.count, 2)
        XCTAssertEqual(restored.savedShapes[0].coordinates[0].latitude, 48.1351, accuracy: 0.0001)
        XCTAssertEqual(restored.savedShapes[0].coordinates[0].longitude, 11.5820, accuracy: 0.0001)
    }

    func testCalendarViewStateDTOCodableRoundTrip() throws {
        var state = CalendarViewState()
        state.title = "Codable Test"
        state.occurrences = 7

        let dto = state.toDTO()

        let encoder = JSONEncoder()
        let data = try encoder.encode(dto)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(CalendarViewStateDTO.self, from: data)

        XCTAssertEqual(decoded.uuid, dto.uuid)
        XCTAssertEqual(decoded.title, "Codable Test")
        XCTAssertEqual(decoded.occurrences, 7)
    }
}

// MARK: - SavedMapShape ↔ DTO

final class SavedMapShapeDTOTests: XCTestCase {

    func testSavedMapShapeToDTOAndBack() {
        let coord1 = CodableCoordinate(CLLocationCoordinate2D(latitude: 48.1351, longitude: 11.5820))
        let coord2 = CodableCoordinate(CLLocationCoordinate2D(latitude: 48.2000, longitude: 11.6000))
        let original = SavedMapShape(coordinates: [coord1, coord2])

        let dto = original.toDTO()
        let restored = SavedMapShape(from: dto)

        XCTAssertEqual(restored.id, original.id)
        XCTAssertEqual(restored.coordinates.count, 2)
        XCTAssertEqual(restored.coordinates[0].latitude, 48.1351, accuracy: 0.0001)
        XCTAssertEqual(restored.coordinates[1].longitude, 11.6000, accuracy: 0.0001)
    }

    func testEmptyShapeRoundTrip() {
        let original = SavedMapShape(coordinates: [])

        let dto = original.toDTO()
        let restored = SavedMapShape(from: dto)

        XCTAssertEqual(restored.coordinates.count, 0)
    }
}

// MARK: - Color+Hex

final class ColorHexTests: XCTestCase {

    func testHexToColorAndBack() {
        let hexString = "FF0000" // Red
        let color = Color(hex: hexString)
        let result = color.toHex()

        XCTAssertNotNil(result)
        // The conversion should produce "FF0000" (or similar red)
        XCTAssertEqual(result?.prefix(2), "FF") // Red channel
    }

    func testBlueHex() {
        let hexString = "0000FF"
        let color = Color(hex: hexString)
        let result = color.toHex()

        XCTAssertNotNil(result)
        // Last two chars should be "FF" for blue
        if let hex = result {
            XCTAssertEqual(String(hex.suffix(2)), "FF")
        }
    }

    func testHexWithHash() {
        let color1 = Color(hex: "#00FF00")
        let color2 = Color(hex: "00FF00")
        // Both should produce the same color
        let hex1 = color1.toHex()
        let hex2 = color2.toHex()
        XCTAssertEqual(hex1, hex2)
    }

    func testInvalidHexFallsBackToWhite() {
        let color = Color(hex: "ZZZZZZ")
        let hex = color.toHex()
        // Invalid hex should fall back to white (FFFFFF)
        XCTAssertNotNil(hex)
        XCTAssertEqual(hex, "FFFFFF")
    }
}

// MARK: - MapShapeManager Tests

final class MapShapeManagerTests: XCTestCase {

    func testAnimatedCoordinatesFullyExpanded() {
        let coords = [
            CodableCoordinate(CLLocationCoordinate2D(latitude: 48.0, longitude: 11.0)),
            CodableCoordinate(CLLocationCoordinate2D(latitude: 49.0, longitude: 12.0)),
            CodableCoordinate(CLLocationCoordinate2D(latitude: 50.0, longitude: 13.0))
        ]
        let shape = SavedMapShape(coordinates: coords)

        let result = MapShapeManager.animatedCoordinates(for: shape, progress: 1.0)

        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].latitude, 48.0, accuracy: 0.0001)
        XCTAssertEqual(result[1].latitude, 49.0, accuracy: 0.0001)
        XCTAssertEqual(result[2].latitude, 50.0, accuracy: 0.0001)
    }

    func testAnimatedCoordinatesZeroProgress() {
        let coords = [
            CodableCoordinate(CLLocationCoordinate2D(latitude: 48.0, longitude: 11.0)),
            CodableCoordinate(CLLocationCoordinate2D(latitude: 50.0, longitude: 13.0))
        ]
        let shape = SavedMapShape(coordinates: coords)

        let result = MapShapeManager.animatedCoordinates(for: shape, progress: 0.0)

        // At progress 0, all points should be at the centroid
        let centroidLat = (48.0 + 50.0) / 2.0
        let centroidLon = (11.0 + 13.0) / 2.0

        XCTAssertEqual(result[0].latitude, centroidLat, accuracy: 0.0001)
        XCTAssertEqual(result[0].longitude, centroidLon, accuracy: 0.0001)
        XCTAssertEqual(result[1].latitude, centroidLat, accuracy: 0.0001)
        XCTAssertEqual(result[1].longitude, centroidLon, accuracy: 0.0001)
    }

    func testAnimatedCoordinatesHalfProgress() {
        let coords = [
            CodableCoordinate(CLLocationCoordinate2D(latitude: 48.0, longitude: 11.0)),
            CodableCoordinate(CLLocationCoordinate2D(latitude: 50.0, longitude: 13.0))
        ]
        let shape = SavedMapShape(coordinates: coords)

        let result = MapShapeManager.animatedCoordinates(for: shape, progress: 0.5)

        let centroidLat = (48.0 + 50.0) / 2.0
        let centroidLon = (11.0 + 13.0) / 2.0

        // At 0.5 progress: centroid + 0.5 * (coord - centroid) = centroid + 0.5*(coord - centroid)
        let expectedLat0 = centroidLat + 0.5 * (48.0 - centroidLat)
        let expectedLon0 = centroidLon + 0.5 * (11.0 - centroidLon)

        XCTAssertEqual(result[0].latitude, expectedLat0, accuracy: 0.0001)
        XCTAssertEqual(result[0].longitude, expectedLon0, accuracy: 0.0001)
    }

    func testShapesFileURL() {
        let testID = UUID()
        let url = MapShapeManager.shapesFileURL(for: testID)

        XCTAssertTrue(url.lastPathComponent.contains(testID.uuidString))
        XCTAssertTrue(url.lastPathComponent.hasSuffix(".json"))
        XCTAssertTrue(url.lastPathComponent.hasPrefix("saved_map_shapes_"))
    }

    func testMapStyleSelection() {
        XCTAssertNotNil(MapShapeManager.mapStyle(for: 0))
        XCTAssertNotNil(MapShapeManager.mapStyle(for: 1))
        XCTAssertNotNil(MapShapeManager.mapStyle(for: 99)) // default case
    }
}

// MARK: - UserCalendarRequest Codable

final class UserCalendarRequestTests: XCTestCase {

    func testUserCalendarRequestCodableRoundTrip() throws {
        let dto = CalendarViewStateDTO(
            uuid: UUID(),
            title: "Test",
            colorHex: "FF0000",
            isExpanded: false,
            occurrences: 3,
            isMonthly: false,
            description: "Desc",
            startMonth: 4,
            startDay: 10,
            startTime: Date(),
            duration: 2,
            savedShapes: []
        )
        let request = UserCalendarRequest(userID: "test-user-123", states: [dto])

        let data = try JSONEncoder().encode(request)
        let decoded = try JSONDecoder().decode(UserCalendarRequest.self, from: data)

        XCTAssertEqual(decoded.userID, "test-user-123")
        XCTAssertEqual(decoded.states.count, 1)
        XCTAssertEqual(decoded.states[0].title, "Test")
    }

    func testEmptyStatesRoundTrip() throws {
        let request = UserCalendarRequest(userID: "empty-user", states: [])

        let data = try JSONEncoder().encode(request)
        let decoded = try JSONDecoder().decode(UserCalendarRequest.self, from: data)

        XCTAssertEqual(decoded.userID, "empty-user")
        XCTAssertTrue(decoded.states.isEmpty)
    }
}
