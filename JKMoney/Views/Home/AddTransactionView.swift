import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var amount: String = ""
    @State private var date: Date = Date()
    @State private var selectedType: TransactionType = .income
    @State private var selectedCurrency: CurrencyType = .usd
    @State private var selectedCategoryItem: CategoryItem = incomeCategories.first!
    @State private var comment: String = ""
    
    private var currentCategories: [CategoryItem] {
        selectedType == .income ? incomeCategories : expenseCategories
    }
    
    private var isFormValid: Bool {
        guard let amt = Double(amount.replacingOccurrences(of: " ", with: "")), amt > 0 else {
            return false
        }
        return true
    }
    
    var body: some View {
        Form {
            Section {
                Picker("Тип транзакции", selection: $selectedType) {
                    ForEach(TransactionType.allCases, id: \.self) { type in
                        Text(type == .income ? "Доход" : "Расход").tag(type)
                    }
                }
                .pickerStyle(.segmented)
                
                Picker("Категория", selection: $selectedCategoryItem) {
                    ForEach(currentCategories, id: \.id) { category in
                        HStack {
                            Image(systemName: category.icon)
                            Text(category.title)
                        }
                        .tag(category)
                    }
                }
                
                Picker("Валюта", selection: $selectedCurrency) {
                    ForEach(CurrencyType.allCases, id: \.self) { currency in
                        Text(currency.rawValue).tag(currency)
                    }
                }
                
                TextField("Сумма", text: $amount)
                    .keyboardType(.decimalPad)
                
                DatePicker("Дата", selection: $date, displayedComponents: .date)
            }
            
            Section("Комментарий (необязательно)") {
                TextField("Комментарий...", text: $comment, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
            }
        }
        .navigationTitle("Новая транзакция")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Сохранить") {
                    saveTransaction()
                }
                .disabled(!isFormValid)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Отмена") {
                    dismiss()
                }
            }
        }
    }
    
    private func saveTransaction() {
        guard isFormValid else { return }
        guard let uid = UserDefaults.standard.string(forKey: "userId") else { return }
        guard let amt = Double(amount.replacingOccurrences(of: " ", with: "")) else { return }
        
        let transaction = Transaction(
            title: selectedCategoryItem.title,
            amount: amt,
            date: date,
            category: selectedCategoryItem.title,
            type: selectedType,
            currency: selectedCurrency,
            userId: uid,
            comment: comment.isEmpty ? nil : comment
        )
        
        modelContext.insert(transaction)
        try? modelContext.save()
        dismiss()
    }
}
