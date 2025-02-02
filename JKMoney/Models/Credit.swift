import SwiftData
import Foundation

enum CreditKind: String, Codable, CaseIterable {
    case credit = "Кредит"
    case loan   = "Займ"
}

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
    var creditKind: CreditKind

    init(
        id: UUID = UUID(),
        title: String,
        categoryTitle: String,
        totalAmount: Double,
        paidAmount: Double = 0.0,
        dateCreated: Date = Date(),
        userId: String,
        currency: CurrencyType? = nil,
        comment: String? = nil,
        creditKind: CreditKind = .credit
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
        self.creditKind = creditKind
    }
}
