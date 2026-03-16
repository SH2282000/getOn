import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It just works!"
    }

    try app.register(collection: CalendarController())

    let geton = app.grouped("geton")
    try geton.register(collection: PasskeyController())
}
