import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var amount: String = ""
    @State private var date: Date = Date()
    @State private var selectedType: TransactionType = .income
    @State private var selectedCurrency: CurrencyType = .usd
    @State private var selectedCategory: String = "Работа"
    @State private var comment: String = ""
    
    private let incomeCategories = ["Работа", "Фриланс", "Депозит", "Другое"]
    private let expenseCategories = ["Транспорт", "Здоровье", "Дом", "Ремонт", "Еда", "Другое"]
    
    private var currentCategories: [String] {
        selectedType == .income ? incomeCategories : expenseCategories
    }
    
    private func updateCategoryIfNeeded() {
        if !currentCategories.contains(selectedCategory) {
            selectedCategory = currentCategories.first ?? ""
        }
    }
    
    private var isFormValid: Bool {
        guard let amt = Double(amount.replacingOccurrences(of: " ", with: "")), amt > 0 else { return false }
        return true
    }
    
    private func formatAmount(_ input: String) -> String {
        let rawNumber = Double(input.replacingOccurrences(of: " ", with: "")) ?? 0
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = " "
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: rawNumber)) ?? input
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
                
                Picker("Категория", selection: $selectedCategory) {
                    ForEach(currentCategories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                
                Picker("Валюта", selection: $selectedCurrency) {
                    ForEach(CurrencyType.allCases, id: \.self) { currency in
                        Text(currency.rawValue).tag(currency)
                    }
                }
                
                TextField("Сумма", text: $amount)
                    .keyboardType(.decimalPad)
                    .onChange(of: amount) { _, newValue in
                        DispatchQueue.main.async {
                            if newValue != formatAmount(newValue) {
                                amount = formatAmount(newValue)
                            }
                        }
                    }
                
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
        .onChange(of: selectedType) { _, _ in
            updateCategoryIfNeeded()
        }
        .task {
            updateCategoryIfNeeded()
        }
    }
    
    private func saveTransaction() {
        guard isFormValid else { return }
        guard let uid = UserDefaults.standard.string(forKey: "userId") else { return }
        guard let amt = Double(amount.replacingOccurrences(of: " ", with: "")) else { return }
        
        let transaction = Transaction(
            title: selectedCategory,
            amount: amt,
            date: date,
            category: selectedCategory,
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
