import SwiftData
import Foundation

@Model
final class UserProfile: Identifiable {
    var id: UUID
    var userId: String
    var username: String
    var email: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        userId: String,
        username: String,
        email: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.username = username
        self.email = email
        self.createdAt = createdAt
    }
}
