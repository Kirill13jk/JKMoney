import SwiftData
import Foundation

@Model
final class Credit: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var categoryTitle: String
    var totalAmount: Double
    var paidAmount: Double
    var dateCreated: Date
    var userId: String
    var currency: CurrencyType?
    var comment: String?

    init(
        id: UUID = UUID(),
        title: String,
        categoryTitle: String,
        totalAmount: Double,
        paidAmount: Double = 0.0,
        dateCreated: Date = Date(),
        userId: String,
        currency: CurrencyType? = nil,
        comment: String? = nil
    ) {
        self.id = id
        self.title = title
        self.categoryTitle = categoryTitle
        self.totalAmount = totalAmount
        self.paidAmount = paidAmount
        self.dateCreated = dateCreated
        self.userId = userId
        self.currency = currency
        self.comment = comment
    }
}
