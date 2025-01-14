import SwiftData
import Foundation

@Model
final class Budget {
    @Attribute(.unique) var id: UUID
    var type: TransactionType
    var amount: Double
    var currency: CurrencyType
    var date: Date
    var userId: String
    
    init(
        id: UUID = UUID(),
        type: TransactionType = .income,
        amount: Double = 0.0,
        currency: CurrencyType = .usd,
        date: Date = Date(),
        userId: String = ""
    ) {
        self.id = id
        self.type = type
        self.amount = amount
        self.currency = currency
        self.date = date
        self.userId = userId
    }
}
