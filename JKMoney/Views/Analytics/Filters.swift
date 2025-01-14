import SwiftUI
import SwiftData

extension AnalyticsView {
    var userFilteredTransactions: [Transaction] {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else { return [] }
        let filtered = transactions.filter { $0.userId == userId }
        
        switch selectedPeriod {
        case .oneMonth:
            let fromDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
            return filtered.filter { $0.date >= fromDate }
        case .threeMonths:
            let fromDate = Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()
            return filtered.filter { $0.date >= fromDate }
        case .sixMonths:
            let fromDate = Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()
            return filtered.filter { $0.date >= fromDate }
        case .oneYear:
            let fromDate = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
            return filtered.filter { $0.date >= fromDate }
        case .allTime:
            return filtered
        case .custom:
            return filtered.filter { $0.date >= customStartDate && $0.date <= customEndDate }
        }
    }
    
    var userFilteredBudgets: [Budget] {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else { return [] }
        let filtered = budgets.filter { $0.userId == userId }
        
        switch selectedPeriod {
        case .oneMonth:
            let fromDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
            return filtered.filter { $0.date >= fromDate }
        case .threeMonths:
            let fromDate = Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()
            return filtered.filter { $0.date >= fromDate }
        case .sixMonths:
            let fromDate = Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()
            return filtered.filter { $0.date >= fromDate }
        case .oneYear:
            let fromDate = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
            return filtered.filter { $0.date >= fromDate }
        case .allTime:
            return filtered
        case .custom:
            return filtered.filter { $0.date >= customStartDate && $0.date <= customEndDate }
        }
    }
}
