import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Считываем значение по умолчанию из AppStorage
    @AppStorage("defaultCurrency") private var defaultCurrency: CurrencyType = .usd

    @State private var amount: String = ""
    @State private var date: Date = Date()
    @State private var selectedType: TransactionType = .income
    
    // Держим выбранную валюту в @State, изначально .usd (или любое другое)
    @State private var selectedCurrency: CurrencyType = .usd

    @State private var selectedCategoryItem: CategoryItem = incomeCategories.first!
    @State private var comment: String = ""
    @State private var customCategoryTitle: String = ""

    private var currentCategories: [CategoryItem] {
        selectedType == .income ? incomeCategories : expenseCategories
    }

    private var isFormValid: Bool {
        guard let amt = Double(amount.replacingOccurrences(of: " ", with: "")), amt > 0 else {
            return false
        }
        if selectedCategoryItem.title == "Другое",
           customCategoryTitle.trimmingCharacters(in: .whitespaces).isEmpty {
            return false
        }
        return true
    }

    var body: some View {
        Form {
            Section {
                // Тип транзакции
                Picker("Тип транзакции", selection: $selectedType) {
                    ForEach(TransactionType.allCases, id: \.self) { type in
                        Text(type == .income ? "Доход" : "Расход").tag(type)
                    }
                }
                .pickerStyle(.segmented)

                // Категория
                Picker("Категория", selection: $selectedCategoryItem) {
                    ForEach(currentCategories, id: \.id) { category in
                        HStack {
                            Image(systemName: category.icon)
                            Text(category.title)
                        }
                        .tag(category)
                    }
                }
                
                if selectedCategoryItem.title == "Другое" {
                    TextField("Введите вашу категорию", text: $customCategoryTitle)
                }

                // Валюта
                Picker("Валюта", selection: $selectedCurrency) {
                    ForEach(CurrencyType.allCases, id: \.self) { currency in
                        Text(currency.rawValue).tag(currency)
                    }
                }

                TextField("Сумма", text: $amount)
                    .keyboardType(.decimalPad)
                    .onChange(of: amount) { newVal in
                        let formatted = formatAmount(newVal)
                        if formatted != newVal {
                            amount = formatted
                        }
                    }

                DatePicker("Дата", selection: $date, displayedComponents: .date)
            }
            
            Section("Комментарий (необязательно)") {
                TextField("Комментарий...", text: $comment, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
            }
        }
        .onChange(of: selectedType) { _ in
            if !currentCategories.contains(selectedCategoryItem),
               let firstCat = currentCategories.first {
                selectedCategoryItem = firstCat
            }
            customCategoryTitle = ""
        }
        // При появлении экрана устанавливаем валюту из настроек
        .onAppear {
            selectedCurrency = defaultCurrency
        }
        .toolbar {
            // Кнопка "Сохранить" (подтверждающее действие)
            ToolbarItem(placement: .confirmationAction) {
                Button("Сохранить") {
                    saveTransaction()
                }
                .disabled(!isFormValid)
            }
            // Кнопка "Отмена" (отменяет и закрывает экран)
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

        let finalCategoryTitle = (selectedCategoryItem.title == "Другое")
            ? customCategoryTitle
            : selectedCategoryItem.title

        let transaction = Transaction(
            title: finalCategoryTitle,
            amount: amt,
            date: date,
            category: finalCategoryTitle,
            type: selectedType,
            currency: selectedCurrency,
            userId: uid,
            comment: comment.isEmpty ? nil : comment
        )

        modelContext.insert(transaction)
        try? modelContext.save()
        dismiss()
    }

    private func formatAmount(_ input: String) -> String {
        let rawString = input.replacingOccurrences(of: " ", with: "")
        guard let rawNumber = Double(rawString) else {
            return input
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = " "
        return formatter.string(from: NSNumber(value: rawNumber)) ?? input
    }
}
