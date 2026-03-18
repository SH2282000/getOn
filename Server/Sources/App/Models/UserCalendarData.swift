import Fluent
import Vapor

final class UserCalendarData: Model, Content, @unchecked Sendable {
    static let schema = "user_calendar_data"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "user_id")
    var user_id: String

    @Field(key: "data")
    var data: Data // Storing JSON data as blob for simplicity

    init() { }

    init(id: UUID? = nil, user_id: String, data: Data) {
        self.id = id
        self.user_id = user_id
        self.data = data
    }
}

struct CreateUserCalendarDataMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("user_calendar_data")
            .id()
            .field("user_id", .string, .required)
            .field("data", .data, .required)
            .unique(on: "user_id")
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("user_calendar_data").delete()
    }
}
