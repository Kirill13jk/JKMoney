import SwiftUI
import SwiftData
import Combine

/// ViewModel для домашнего экрана (теперь без фильтра)
class HomeViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let modelContext: ModelContext
    private let currentUserId: String?
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.currentUserId = UserDefaults.standard.string(forKey: "userId")
        
        // Выполняем одну загрузку транзакций (без фильтра)
        fetchTransactions()
    }
    
    // MARK: - Загрузка всех транзакций текущего пользователя
    
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
            // Получаем все транзакции пользователя (без фильтра доход/расход)
            transactions = try modelContext.fetch(descriptor)
        } catch {
            print("Ошибка загрузки транзакций: \(error)")
            transactions = []
        }
    }
    
    // MARK: - Сводка доход/расход по валютам (по всем транзакциям)
    
    /// Группируем по валюте и считаем суммы доходов и расходов.
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
    
    // MARK: - Удаление транзакции
    
    func deleteTransaction(_ transaction: Transaction) {
        modelContext.delete(transaction)
        saveContext()
        // Перезагружаем список
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
