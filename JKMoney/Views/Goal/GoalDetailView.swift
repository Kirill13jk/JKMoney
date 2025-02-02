import SwiftUI
import SwiftData

struct GoalDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let goal: Goal
    
    @State private var changeType: TransactionType = .income
    @State private var changeAmount: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Информация о цели")) {
                Text(goal.title)
                    .font(.headline)
                
                Text("Категория: \(goal.categoryTitle)")
                
                if let currencyValue = goal.currency?.rawValue {
                    Text("Валюта: \(currencyValue)")
                }
                
                if let comment = goal.comment, !comment.isEmpty {
                    Text("Комментарий: \(comment)")
                }
                
                Text("Накоплено: \(formatted(goal.currentAmount)) / \(formatted(goal.targetAmount))")
                    .foregroundColor(.blue)
                
                if goal.targetAmount > 0 {
                    ProgressView(
                        value: clamped(goal.currentAmount, max: goal.targetAmount),
                        total: goal.targetAmount
                    )
                }
            }
            
            Section(header: Text("Изменить накопленную сумму")) {
                Picker("Операция", selection: $changeType) {
                    Text("Добавить").tag(TransactionType.income)
                    Text("Убавить").tag(TransactionType.expense)
                }
                .pickerStyle(.segmented)
                
                TextField("Введите сумму", text: $changeAmount)
                    .keyboardType(.decimalPad)
                    .onChange(of: changeAmount) { oldValue, newValue in
                        DispatchQueue.main.async {
                            let formatted = formatInput(newValue)
                            if formatted != newValue {
                                changeAmount = formatted
                            }
                        }
                    }
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
        guard let delta = parseFormatted(changeAmount), delta > 0 else {
            dismiss()
            return
        }
        
        switch changeType {
        case .income:
            goal.currentAmount += delta
        case .expense:
            goal.currentAmount -= delta
            if goal.currentAmount < 0 {
                goal.currentAmount = 0
            }
        }
        
        try? modelContext.save()
        dismiss()
    }
    
    private func clamped(_ value: Double, max: Double) -> Double {
        Swift.max(0, Swift.min(value, max))
    }
}

extension GoalDetailView {
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
