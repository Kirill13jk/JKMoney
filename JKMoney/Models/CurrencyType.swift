import SwiftData
import Foundation

enum TransactionType: String, Codable, CaseIterable {
    case income  = "income"
    case expense = "expense"
}

enum CurrencyType: String, Codable, CaseIterable {
    case usd = "USD"
    case uzs = "UZS"
    case eur = "EUR"
    case rub = "RUB"
}
