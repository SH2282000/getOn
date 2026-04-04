import XCTest
@testable import getOn

// Server-side DTOs are duplicated on the client (SharedDTOs.swift), so we test
// the client-side version which is functionally identical. These tests validate
// the shared contract between client and server.

final class ServerDTOContractTests: XCTestCase {

    func testCalendarViewStateDTOEncodeDecode() throws {
        let dto = CalendarViewStateDTO(
            uuid: UUID(),
            title: "Server Test Event",
            colorHex: "00FF00",
            isExpanded: true,
            occurrences: 5,
            isMonthly: true,
            description: "Server test description",
            startMonth: 7,
            startDay: 20,
            startTime: Date(),
            duration: 4,
            savedShapes: [
                SavedMapShapeDTO(
                    id: UUID(),
                    coordinates: [
                        CodableCoordinateDTO(latitude: 48.1351, longitude: 11.5820)
                    ]
                )
            ]
        )

        let data = try JSONEncoder().encode(dto)
        let decoded = try JSONDecoder().decode(CalendarViewStateDTO.self, from: data)

        XCTAssertEqual(decoded.uuid, dto.uuid)
        XCTAssertEqual(decoded.title, "Server Test Event")
        XCTAssertEqual(decoded.colorHex, "00FF00")
        XCTAssertTrue(decoded.isExpanded)
        XCTAssertEqual(decoded.occurrences, 5)
        XCTAssertTrue(decoded.isMonthly)
        XCTAssertEqual(decoded.savedShapes.count, 1)
        XCTAssertEqual(decoded.savedShapes[0].coordinates[0].latitude, 48.1351, accuracy: 0.0001)
    }

    func testSavedMapShapeDTOEncodeDecode() throws {
        let shapeDTO = SavedMapShapeDTO(
            id: UUID(),
            coordinates: [
                CodableCoordinateDTO(latitude: 10.0, longitude: 20.0),
                CodableCoordinateDTO(latitude: 30.0, longitude: 40.0)
            ]
        )

        let data = try JSONEncoder().encode(shapeDTO)
        let decoded = try JSONDecoder().decode(SavedMapShapeDTO.self, from: data)

        XCTAssertEqual(decoded.id, shapeDTO.id)
        XCTAssertEqual(decoded.coordinates.count, 2)
        XCTAssertEqual(decoded.coordinates[1].latitude, 30.0, accuracy: 0.0001)
    }

    func testUserCalendarRequestMultipleStates() throws {
        let states = (0..<3).map { i in
            CalendarViewStateDTO(
                uuid: UUID(),
                title: "Event \(i)",
                colorHex: "AABBCC",
                isExpanded: false,
                occurrences: i + 1,
                isMonthly: false,
                description: "",
                startMonth: 1,
                startDay: 1,
                startTime: Date(),
                duration: 1,
                savedShapes: []
            )
        }
        let request = UserCalendarRequest(userID: "multi-user", states: states)

        let data = try JSONEncoder().encode(request)
        let decoded = try JSONDecoder().decode(UserCalendarRequest.self, from: data)

        XCTAssertEqual(decoded.states.count, 3)
        XCTAssertEqual(decoded.states[2].title, "Event 2")
        XCTAssertEqual(decoded.states[0].occurrences, 1)
    }
}
