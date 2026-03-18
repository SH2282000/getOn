import Fluent
import Vapor

struct CalendarController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let calendar = routes.grouped("calendar")
        calendar.post(use: save)
        calendar.get(":userID", use: get)
    }

    func save(req: Request) async throws -> HTTPStatus {
        let input = try req.content.decode(UserCalendarRequest.self)

        // Encode the states to JSON Data
        let data = try JSONEncoder().encode(input.states)

        // Check if user exists
        if let existing = try await UserCalendarData.query(on: req.db)
            .filter(\.$user_id == input.userID)
            .first()
        {
            existing.data = data
            try await existing.save(on: req.db)
        } else {
            let newData = UserCalendarData(user_id: input.userID, data: data)
            try await newData.save(on: req.db)
        }

        return .ok
    }

    func get(req: Request) async throws -> UserCalendarRequest {
        guard let userID = req.parameters.get("userID") else {
            throw Abort(.badRequest)
        }

        guard
            let userRecord = try await UserCalendarData.query(on: req.db)
                .filter(\.$user_id == userID)
                .first()
        else {
            // Return empty list if user not found
            return UserCalendarRequest(userID: userID, states: [])
        }

        let states = try JSONDecoder().decode([CalendarViewStateDTO].self, from: userRecord.data)
        return UserCalendarRequest(userID: userID, states: states)
    }
}
