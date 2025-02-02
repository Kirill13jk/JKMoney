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
    var categoryTitle: String  // Новое поле для "Депозит, Счет, Наличка"

    init(
        id: UUID = UUID(),
        type: TransactionType,
        amount: Double,
        currency: CurrencyType,
        date: Date,
        userId: String,
        categoryTitle: String
    ) {
        self.id = id
        self.type = type
        self.amount = amount
        self.currency = currency
        self.date = date
        self.userId = userId
        self.categoryTitle = categoryTitle
    }
}

@Model
final class BudgetHistory {
    @Attribute(.unique) var id: UUID
    var budgetID: UUID
    var date: Date
    var type: TransactionType
    var amount: Double

    init(
        id: UUID = UUID(),
        budgetID: UUID,
        date: Date,
        type: TransactionType,
        amount: Double
    ) {
        self.id = id
        self.budgetID = budgetID
        self.date = date
        self.type = type
        self.amount = amount
    }
}
