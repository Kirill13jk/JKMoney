import SwiftUI
import SwiftData

struct CreditDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let credit: Credit
    
    @State private var changeType: TransactionType = .income
    @State private var changeAmount: String = ""
    
    // Убрали отключение toggle, чтобы он работал для обоих типов операций
    @State private var subtractFromBudget: Bool = false
    
    @Query(sort: \Budget.date, order: .reverse) private var allBudgets: [Budget]
    
    var body: some View {
        Form {
            Section(header: Text("Информация о кредите/займе")) {
                Text(credit.creditKind.rawValue)
                Text(credit.title)
                    .font(.headline)
                Text("Категория: \(credit.categoryTitle)")
                
                if let cur = credit.currency?.rawValue {
                    Text("Валюта: \(cur)")
                }
                if let comment = credit.comment, !comment.isEmpty {
                    Text("Комментарий: \(comment)")
                }
                
                Text("Выплачено: \(formatIntForCredit(credit.paidAmount)) / \(formatIntForCredit(credit.totalAmount))")
                    .foregroundColor(.blue)
                
                if credit.totalAmount > 0 {
                    ProgressView(value: clamp(credit.paidAmount, max: credit.totalAmount),
                                 total: credit.totalAmount)
                }
            }
            
            Section(header: Text("Изменить выплаченную сумму")) {
                Picker("Операция", selection: $changeType) {
                    Text("Добавить").tag(TransactionType.income)
                    Text("Убавить").tag(TransactionType.expense)
                }
                .pickerStyle(.segmented)
                
                TextField("Введите сумму", text: $changeAmount)
                    .keyboardType(.decimalPad)
                    .onChange(of: changeAmount) { _, newVal in
                        let fmt = formatIntForCredit(newVal)
                        if fmt != newVal {
                            changeAmount = fmt
                        }
                    }
                
                Toggle("Вычесть из бюджета?", isOn: $subtractFromBudget)
                // Если вам нужно, чтобы вычиталось из бюджета ТОЛЬКО при "убавить (expense)",
                // можно вернуть блокировку: .disabled(changeType == .income)
            }
        }
        .navigationTitle("Детали")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Сохранить") {
                    applyChange()
                }
            }
        }
        .onAppear {
            changeType = .income
            changeAmount = ""
        }
    }
    
    private func applyChange() {
        guard let delta = parseFormattedForCredit(changeAmount), delta > 0 else {
            dismiss()
            return
        }
        
        switch changeType {
        case .income:
            credit.paidAmount += delta
            
            // Если включён toggle и вы хотите даже при income вычитать из бюджета,
            // тогда оставьте логику здесь. Иначе не будем вычитать.
            if subtractFromBudget {
                subtractFromFirstBudget(delta)
            }
            
        case .expense:
            credit.paidAmount -= delta
            if credit.paidAmount < 0 {
                credit.paidAmount = 0
            }
            
            if subtractFromBudget {
                subtractFromFirstBudget(delta)
            }
        }
        
        // Сохраняем модель
        try? modelContext.save()
        dismiss()
    }
    
    /// Пример: вычитаем сумму из ПЕРВОГО бюджета в списке
    private func subtractFromFirstBudget(_ amount: Double) {
        guard let firstBudget = allBudgets.first else { return }
        if firstBudget.amount >= amount {
            firstBudget.amount -= amount
        } else {
            firstBudget.amount = 0
        }
        try? modelContext.save()
    }
    
    private func clamp(_ value: Double, max: Double) -> Double {
        Swift.max(0, Swift.min(value, max))
    }
    
    // MARK: - Методы форматирования
    private func parseFormattedForCredit(_ input: String) -> Double? {
        let raw = input.replacingOccurrences(of: " ", with: "")
        return Double(raw)
    }
    
    private func formatIntForCredit(_ input: String) -> String {
        let raw = input.replacingOccurrences(of: " ", with: "")
        guard let val = Double(raw) else { return input }
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        f.groupingSeparator = " "
        return f.string(from: NSNumber(value: val)) ?? input
    }
    
    private func formatIntForCredit(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        f.groupingSeparator = " "
        return f.string(from: NSNumber(value: value)) ?? "\(Int(value))"
    }
}
