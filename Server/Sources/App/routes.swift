import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It just works!"
    }

    let geton = app.grouped("geton")
    try geton.register(collection: CalendarController())
    try geton.register(collection: PasskeyController())
}
