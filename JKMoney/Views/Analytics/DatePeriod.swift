import Foundation

enum DatePeriod: CaseIterable, Equatable {
    case oneMonth
    case threeMonths
    case sixMonths
    case oneYear
    case allTime
    case custom
    
    var displayName: String {
        switch self {
        case .oneMonth:    return "1 месяц"
        case .threeMonths: return "3 месяца"
        case .sixMonths:   return "6 месяцев"
        case .oneYear:     return "1 год"
        case .allTime:     return "Все время"
        case .custom:      return "Пользовательский"
        }
    }
    
    static var predefinedCases: [DatePeriod] {
        [.oneMonth, .threeMonths, .sixMonths, .oneYear, .allTime]
    }
}
