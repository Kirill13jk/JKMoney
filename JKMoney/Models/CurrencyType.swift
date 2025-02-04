import SwiftData
import Foundation

enum TransactionType: String, Codable, CaseIterable, Equatable {
    case income  = "income"
    case expense = "expense"
}

enum CurrencyType: String, Codable, CaseIterable, Equatable {
    case usd = "USD"
    case uzs = "UZS"
    case eur = "EUR"
    case rub = "RUB"
}
