import Fluent
import Vapor

final class UserCalendarData: Model, Content {
    static let schema = "user_calendar_data"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "username")
    var username: String

    @Field(key: "data")
    var data: Data // Storing JSON data as blob for simplicity

    init() { }

    init(id: UUID? = nil, username: String, data: Data) {
        self.id = id
        self.username = username
        self.data = data
    }
}

struct CreateUserCalendarDataMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("user_calendar_data")
            .id()
            .field("username", .string, .required)
            .field("data", .data, .required)
            .unique(on: "username")
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("user_calendar_data").delete()
    }
}
