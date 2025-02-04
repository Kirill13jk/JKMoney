import SwiftUI
import SwiftData

struct AddPlanView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @AppStorage("defaultCurrency") private var defaultCurrency: CurrencyType = .usd
    
    @State private var selectedCategory: CategoryItem = budgetCategories.first!
    @State private var customCategoryTitle: String = ""
    
    // Держим выбранную валюту в @State, изначально .usd (или любое другое)
    @State private var selectedCurrency: CurrencyType = .usd
    
    @State private var amount: String = ""
    @State private var reminderDate: Date = Date()
    
    @State private var comment: String = ""
    
    private var isFormValid: Bool {
        guard let val = Double(amount.replacingOccurrences(of: " ", with: "")), val > 0 else {
            return false
        }
        if selectedCategory.title == "Другое",
           customCategoryTitle.trimmingCharacters(in: .whitespaces).isEmpty {
            return false
        }
        return true
    }
    
    var body: some View {
        Form {
            Section("Категория") {
                Picker("Категория", selection: $selectedCategory) {
                    ForEach(budgetCategories, id: \.id) { cat in
                        Text(cat.title).tag(cat)
                    }
                }
                if selectedCategory.title == "Другое" {
                    TextField("Введите свою категорию", text: $customCategoryTitle)
                }
            }
            
            Section("Сумма, валюта и дата") {
                // Добавляем Picker для валюты
                Picker("Валюта", selection: $selectedCurrency) {
                    ForEach(CurrencyType.allCases, id: \.self) { currency in
                        Text(currency.rawValue).tag(currency)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 4)
                
                TextField("Сумма", text: $amount)
                    .keyboardType(.decimalPad)
                    .onChange(of: amount) { newVal in
                        let fmt = formatAmount(newVal)
                        if fmt != newVal {
                            amount = fmt
                        }
                    }
                
                DatePicker("Дата напоминания", selection: $reminderDate, displayedComponents: .date)
            }
            
            Section("Комментарий (необязательно)") {
                TextField("Ваш комментарий...", text: $comment, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
            }
        }
        .navigationTitle("Новый план")
        .onAppear {
            selectedCurrency = defaultCurrency
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Сохранить") {
                    savePlan()
                }
                .disabled(!isFormValid)
            }
        }
    }
    
    private func savePlan() {
        guard let uid = UserDefaults.standard.string(forKey: "userId") else { return }
        guard let val = Double(amount.replacingOccurrences(of: " ", with: "")) else { return }
        
        let finalCat = (selectedCategory.title == "Другое") ? customCategoryTitle : selectedCategory.title
        
        let newPlan = PlannedExpense(
            userId: uid,
            title: finalCat,
            categoryTitle: finalCat,
            amount: val,
            reminderDate: reminderDate,
            comment: comment.isEmpty ? nil : comment,
            currency: selectedCurrency    // Передаём выбранную валюту
        )
        
        modelContext.insert(newPlan)
        try? modelContext.save()
        
        // Планируем уведомление
        NotificationManager.shared.scheduleMonthlyNotification(for: newPlan)
        
        dismiss()
    }
    
    private func formatAmount(_ input: String) -> String {
        let raw = input.replacingOccurrences(of: " ", with: "")
        guard let rawNum = Double(raw) else { return input }
        
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 2
        f.groupingSeparator = " "
        
        return f.string(from: NSNumber(value: rawNum)) ?? input
    }
}
