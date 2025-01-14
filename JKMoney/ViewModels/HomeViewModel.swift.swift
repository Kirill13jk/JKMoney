import SwiftUI
import SwiftData
import Combine

class HomeViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let modelContext: ModelContext
    private let currentUserId: String?
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.currentUserId = UserDefaults.standard.string(forKey: "userId")
        fetchTransactions()
    }
    
    private func fetchTransactions() {
        guard let uid = currentUserId else {
            transactions = []
            return
        }
        
        let descriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate { $0.userId == uid },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        do {
            transactions = try modelContext.fetch(descriptor)
        } catch {
            print("Ошибка загрузки транзакций: \(error)")
            transactions = []
        }
    }
    
    var currencyTotals: [CurrencyType: (income: Double, expense: Double)] {
        let groupedByCurrency = Dictionary(grouping: transactions, by: { $0.currency })
        
        var result: [CurrencyType: (Double, Double)] = [:]
        for (currency, txs) in groupedByCurrency {
            let totalIncome = txs
                .filter { $0.type == .income }
                .reduce(0) { $0 + $1.amount }
            
            let totalExpense = txs
                .filter { $0.type == .expense }
                .reduce(0) { $0 + $1.amount }
            
            result[currency] = (totalIncome, totalExpense)
        }
        return result
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        modelContext.delete(transaction)
        saveContext()
        fetchTransactions()
    }
    
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Ошибка сохранения контекста: \(error)")
        }
    }
}
