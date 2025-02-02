import SwiftUI
import SwiftData

struct AddBudgetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    private var type: TransactionType = .income
    
    @State private var selectedCategoryItem: CategoryItem = budgetCategories.first!
    @State private var amount: String = ""
    @State private var currency: CurrencyType = .usd
    @State private var date: Date = Date()
    
    private var isFormValid: Bool {
        guard let amt = Double(amount.replacingOccurrences(of: " ", with: "")), amt > 0 else {
            return false
        }
        return true
    }

    
    var body: some View {
        Form {
            Section("Категория") {
                Picker("Выберите категорию", selection: $selectedCategoryItem) {
                    ForEach(budgetCategories, id: \.id) { cat in
                        HStack {
                            Image(systemName: cat.icon)
                            Text(cat.title)
                        }
                        .tag(cat)
                    }
                }
            }
            
            Section {
                Picker("Валюта", selection: $currency) {
                    ForEach(CurrencyType.allCases, id: \.self) { c in
                        Text(c.rawValue.uppercased()).tag(c)
                    }
                }
                TextField("Сумма", text: $amount)
                    .keyboardType(.decimalPad)
                    .onChange(of: amount) { _, newValue in
                        let formatted = formatAmount(newValue)
                        if formatted != newValue {
                            amount = formatted
                        }
                    }
                DatePicker("Дата", selection: $date, displayedComponents: .date)
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Сохранить") {
                    saveBudget()
                }
                .disabled(!isFormValid)
            }
        }
    }
    
    private func saveBudget() {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else { return }
        guard let amt = Double(amount.replacingOccurrences(of: " ", with: "")), amt > 0 else { return }
        
        let budget = Budget(
            type: type,
            amount: amt,
            currency: currency,
            date: date,
            userId: userId,
            categoryTitle: selectedCategoryItem.title  // Сохраняем строку
        )
        modelContext.insert(budget)
        try? modelContext.save()
        dismiss()
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
}
