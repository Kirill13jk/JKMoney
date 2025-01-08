import SwiftUI
import SwiftData

class AddTransactionViewModel: ObservableObject {
    @Published var amount: String = ""
    @Published var date: Date = Date()
    @Published var selectedType: TransactionType = .income
    @Published var selectedCurrency: CurrencyType = .usd
    @Published var selectedCategory: String = "Работа"
    @Published var comment: String = ""
    
    let incomeCategories = ["Работа", "Фриланс", "Депозит", "Другое"]
    let expenseCategories = ["Транспорт", "Здоровье", "Дом", "Ремонт", "Еда", "Другое"]
    
    private let modelContext: ModelContext
    private let currentUserId: String?
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.currentUserId = UserDefaults.standard.string(forKey: "userId")
        self.selectedCategory = incomeCategories.first ?? "Работа"
    }
    
    var currentCategories: [String] {
        selectedType == .income ? incomeCategories : expenseCategories
    }
    
    var isFormValid: Bool {
        guard !amount.isEmpty, Double(amount) != nil else {
            return false
        }
        return true
    }
    
    func saveTransaction() -> Bool {
        guard isFormValid else { return false }
        guard let amountValue = Double(amount),
              let uid = currentUserId else { return false }
        
        let transaction = Transaction(
            title: selectedCategory,
            amount: amountValue,
            date: date,
            category: selectedCategory,
            type: selectedType,
            currency: selectedCurrency,
            userId: uid,
            comment: comment.isEmpty ? nil : comment
        )
        modelContext.insert(transaction)
        
        do {
            try modelContext.save()
            print("Транзакция сохранена: \(transaction.category)")
            return true
        } catch {
            print("Ошибка сохранения контекста: \(error)")
            return false
        }
    }
}
