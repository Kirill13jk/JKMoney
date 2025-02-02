import SwiftUI
import SwiftData

struct BudgetDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let budget: Budget
    
    @Query private var history: [BudgetHistory]
    @State private var changeType: TransactionType = .income
    @State private var changeAmount: String = ""
    
    init(budget: Budget) {
        self.budget = budget
        let localID = budget.id
        _history = Query(
            filter: #Predicate { $0.budgetID == localID },
            sort: [SortDescriptor(\.date, order: .reverse)]
        )
    }
    
    var body: some View {
        Form {
            Section("Текущий бюджет") {
                HStack {
                    Text("Текущая сумма:")
                    Spacer()
                    Text("\(formatted(budget.amount)) \(budget.currency.rawValue)")
                        .fontWeight(.bold)
                }
                Text("Дата: \(budget.date, style: .date)")
            }
            Section("Изменить сумму") {
                Picker("Тип", selection: $changeType) {
                    Text("Доход").tag(TransactionType.income)
                    Text("Расход").tag(TransactionType.expense)
                }
                .pickerStyle(.segmented)
                TextField("Введите сумму", text: $changeAmount)
                    .keyboardType(.decimalPad)
                    .onChange(of: changeAmount) { _, newValue in
                        let formatted = formatInput(newValue)
                        if formatted != newValue {
                            changeAmount = formatted
                        }
                    }
            }
            Section("История") {
                if history.isEmpty {
                    Text("Пока нет операций.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(history) { record in
                        HStack {
                            Text(record.date, style: .date)
                            Spacer()
                            Text(record.type == .income ? "+" : "–")
                                .foregroundColor(record.type == .income ? .green : .red)
                            Text("\(formatted(record.amount))")
                                .foregroundColor(record.type == .income ? .green : .red)
                        }
                    }
                }
            }
        }
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
        guard let delta = parseFormatted(changeAmount), delta > 0 else {
            dismiss()
            return
        }
        switch changeType {
        case .income:
            budget.amount += delta
        case .expense:
            budget.amount -= delta
            if budget.amount < 0 { budget.amount = 0 }
        }
        budget.date = Date()
        
        let record = BudgetHistory(
            budgetID: budget.id,
            date: Date(),
            type: changeType,
            amount: delta
        )
        modelContext.insert(record)
        
        try? modelContext.save()
        dismiss()
    }
    
    private func formatted(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = " "
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
    
    private func parseFormatted(_ input: String) -> Double? {
        let raw = input.replacingOccurrences(of: " ", with: "")
        return Double(raw)
    }
    
    private func formatInput(_ input: String) -> String {
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
