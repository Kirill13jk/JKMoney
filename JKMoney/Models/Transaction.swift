import SwiftData
import Foundation

@Model
final class Transaction {
    @Attribute(.unique) var id: UUID
    var title: String
    var amount: Double
    var date: Date
    var category: String
    var type: TransactionType
    var currency: CurrencyType
    var userId: String
    var comment: String?

    init(
        id: UUID = UUID(),
        title: String = "",
        amount: Double = 0.0,
        date: Date = Date(),
        category: String = "",
        type: TransactionType = .income,
        currency: CurrencyType = .usd,
        userId: String = "",
        comment: String? = nil
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.date = date
        self.category = category
        self.type = type
        self.currency = currency
        self.userId = userId
        self.comment = comment
    }
}
