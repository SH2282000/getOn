import Vapor

struct SavedMapShapeDTO: Codable {
    var id: UUID
    var coordinates: [CodableCoordinateDTO]
}

struct CodableCoordinateDTO: Codable {
    var latitude: Double
    var longitude: Double
}

struct CalendarViewStateDTO: Codable, Content {
    var uuid: UUID
    var title: String
    var colorHex: String
    var isExpanded: Bool
    var occurrences: Int
    var isMonthly: Bool
    var description: String
    var startMonth: Int
    var startDay: Int
    var startTime: Date
    var duration: Int
    var savedShapes: [SavedMapShapeDTO]
}

struct UserCalendarRequest: Content {
    var userID: String
    var states: [CalendarViewStateDTO]
}
