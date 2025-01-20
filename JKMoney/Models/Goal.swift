import SwiftData
import Foundation

@Model
final class Goal {
    @Attribute(.unique) var id: UUID
    var title: String
    var categoryTitle: String
    var targetAmount: Double
    var currentAmount: Double
    var dateCreated: Date
    var userId: String
    var currency: CurrencyType?
    var comment: String?

    init(
        id: UUID = UUID(),
        title: String,
        categoryTitle: String,
        targetAmount: Double,
        currentAmount: Double = 0.0,
        dateCreated: Date = Date(),
        userId: String,
        currency: CurrencyType? = nil,
        comment: String? = nil
    ) {
        self.id = id
        self.title = title
        self.categoryTitle = categoryTitle
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.dateCreated = dateCreated
        self.userId = userId
        self.currency = currency
        self.comment = comment
    }
}
