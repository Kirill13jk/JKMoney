import SwiftData
import Foundation

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
