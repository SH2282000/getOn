import Fluent
import Vapor

final class PasskeyCredential: Model, Content {
    static let schema = "passkey_credentials"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "user_id")
    var userID: String

    @OptionalField(key: "username")
    var username: String?

    @Field(key: "credential_id")
    var credentialID: Data

    @Field(key: "public_key")
    var publicKey: Data

    init() {}

    init(id: UUID? = nil, userID: String, username: String? = nil, credentialID: Data, publicKey: Data) {
        self.id = id
        self.userID = userID
        self.username = username
        self.credentialID = credentialID
        self.publicKey = publicKey
    }
}

struct CreatePasskeyCredentialMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("passkey_credentials")
            .id()
            .field("user_id", .string, .required)
            .field("username", .string)
            .field("credential_id", .data, .required)
            .field("public_key", .data, .required)
            .unique(on: "credential_id")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("passkey_credentials").delete()
    }
}
