import SwiftUI
import SwiftData

/// Экран добавления нового бюджета
struct AddBudgetView: View {
    // Для закрытия экрана
    @Environment(\.dismiss) private var dismiss
    // Контекст SwiftData для сохранения объектов
    @Environment(\.modelContext) private var modelContext
    
    // Поля формы
    @State private var type: TransactionType = .income       // По умолчанию "Доход"
    @State private var amount: Double? = nil                 // Сумма (опционально, в начале нет)
    @State private var currency: CurrencyType = .usd         // Выбранная валюта
    @State private var date: Date = Date()                   // Дата
    
    // Форма валидна, если сумма указана и она > 0
    private var isFormValid: Bool {
        guard let amt = amount, amt > 0 else { return false }
        return true
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        // Переключатель между Доходом и Расходом
                        Picker("Тип", selection: $type) {
                            Text("Доход").tag(TransactionType.income)
                            Text("Расход").tag(TransactionType.expense)
                        }
                        .pickerStyle(.segmented)
                        
                        // Выбор валюты из списка CurrencyType
                        Picker("Валюта", selection: $currency) {
                            ForEach(CurrencyType.allCases, id: \.self) { c in
                                Text(c.rawValue).tag(c)
                            }
                        }
                        
                        // Поле для ввода суммы (используем формат .number)
                        TextField("Сумма", value: $amount, format: .number)
                            .keyboardType(.decimalPad)
                        
                        // Выбор даты (только день, месяц, год)
                        DatePicker("Дата", selection: $date, displayedComponents: .date)
                    }
                }
                .formStyle(.grouped)
            }
            .padding(.top, 8)
            .navigationTitle("Новый бюджет")
            .toolbar {
                // Кнопка "Сохранить" справа
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        saveBudget()
                    }
                    // Блокируем, если форма не валидна
                    .disabled(!isFormValid)
                }
                // Кнопка "Отмена" слева
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    /// Сохраняет новый объект `Budget` в SwiftData и закрывает экран
    private func saveBudget() {
        // Проверяем, что форма валидна
        guard isFormValid else { return }
        
        // Получаем userId (должен быть сохранён ранее при аутентификации)
        guard let userId = UserDefaults.standard.string(forKey: "userId") else { return }
        // Парсим сумму
        guard let amt = amount else { return }
        
        // Создаем объект `Budget`
        let budget = Budget(
            type: type,
            amount: amt,
            currency: currency,
            date: date,
            userId: userId
        )
        
        // Вставляем в контекст
        modelContext.insert(budget)
        
        // Пытаемся сохранить изменения
        do {
            try modelContext.save()
            // Закрываем экран
            dismiss()
        } catch {
            print("Ошибка сохранения Budget: \(error)")
        }
    }
}
