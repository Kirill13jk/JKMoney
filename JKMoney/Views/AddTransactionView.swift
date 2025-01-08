import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Вместо 0.0 — делаем опциональный Double, чтобы поле было пустым при старте
    @State private var amount: Double? = nil
    @State private var date: Date = Date()
    @State private var selectedType: TransactionType = .income
    @State private var selectedCurrency: CurrencyType = .usd
    @State private var selectedCategory: String = "Работа"
    @State private var comment: String = ""
    
    // Категории доходов и расходов
    private let incomeCategories = ["Работа", "Фриланс", "Депозит", "Другое"]
    private let expenseCategories = ["Транспорт", "Здоровье", "Дом", "Ремонт", "Еда", "Другое"]
    
    // Текущий набор категорий (зависит от типа)
    private var currentCategories: [String] {
        selectedType == .income ? incomeCategories : expenseCategories
    }
    
    // Если выбранная категория не подходит новому типу, сбрасываем
    private func updateCategoryIfNeeded() {
        if !currentCategories.contains(selectedCategory) {
            selectedCategory = currentCategories.first ?? ""
        }
    }
    
    // Форма валидна, если сумма есть и > 0
    private var isFormValid: Bool {
        guard let amt = amount, amt > 0 else { return false }
        return true
    }
    
    var body: some View {
        NavigationView {
            // Оборачиваем Form в VStack с отступом, чтобы «дать дышать»
            VStack {
                Form {
                    Section {
                        // Тип транзакции
                        Picker("Тип транзакции", selection: $selectedType) {
                            ForEach(TransactionType.allCases, id: \.self) { type in
                                Text(localizedTypeName(type)).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)

                        // Категория
                        Picker("Категория", selection: $selectedCategory) {
                            ForEach(currentCategories, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }

                        // Валюта
                        Picker("Валюта", selection: $selectedCurrency) {
                            ForEach(CurrencyType.allCases, id: \.self) { currency in
                                Text(currency.rawValue).tag(currency)
                            }
                        }

                        // Сумма (используем опциональный Double?)
                        TextField("Сумма", value: $amount, format: .number)
                            .keyboardType(.decimalPad)

                        // Дата
                        DatePicker("Дата", selection: $date, displayedComponents: .date)
                    }
                    
                    Section("Комментарий (необязательно)") {
                        TextField("Комментарий...", text: $comment, axis: .vertical)
                            .lineLimit(3, reservesSpace: true)
                    }
                }
                .formStyle(.grouped)
                .onChange(of: selectedType) { _ in
                    // При смене типа — проверяем категорию
                    updateCategoryIfNeeded()
                }
                // При первом появлении — сброс категории, если она недопустима
                .task {
                    updateCategoryIfNeeded()
                }
            }
            .padding(.top, 8)
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
    }
    
    // Локализация названий типов (можно и без этого, если устраивают rawValue)
    private func localizedTypeName(_ type: TransactionType) -> String {
        switch type {
        case .income:
            return "Доход"
        case .expense:
            return "Расход"
        }
    }
    
    private func saveTransaction() {
        // Проверяем, что форма валидна
        guard isFormValid else { return }
        guard let uid = UserDefaults.standard.string(forKey: "userId") else {
            print("Нет userId, пользователь не залогинен.")
            return
        }
        guard let amt = amount else { return }
        
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
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Ошибка сохранения: \(error)")
        }
    }
}
