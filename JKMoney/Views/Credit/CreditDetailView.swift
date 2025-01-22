import SwiftUI
import SwiftData

struct CreditDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let credit: Credit
    
    @State private var changeType: TransactionType = .income
    @State private var changeAmount: String = ""
    
    var body: some View {
        Form {
            Section("Информация о кредите") {
                Text(credit.title)
                    .font(.headline)
                Text("Категория: \(credit.categoryTitle)")
                if let cur = credit.currency?.rawValue {
                    Text("Валюта: \(cur)")
                }
                if let comment = credit.comment, !comment.isEmpty {
                    Text("Комментарий: \(comment)")
                }
                Text("Выплачено: \(formatted(credit.paidAmount)) / \(formatted(credit.totalAmount))")
                    .foregroundColor(.blue)
                if credit.totalAmount > 0 {
                    ProgressView(value: clamp(credit.paidAmount, max: credit.totalAmount),
                                 total: credit.totalAmount)
                }
            }
            Section("Изменить выплаченную сумму") {
                Picker("Операция", selection: $changeType) {
                    Text("Добавить").tag(TransactionType.income)
                    Text("Убавить").tag(TransactionType.expense)
                }
                .pickerStyle(.segmented)
                TextField("Введите сумму", text: $changeAmount)
                    .keyboardType(.decimalPad)
                    .onChange(of: changeAmount) { _, newVal in
                        let fmt = formatInput(newVal)
                        if fmt != newVal { changeAmount = fmt }
                    }
            }
        }
        .navigationTitle("Детали кредита")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Сохранить") { applyChange() }
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
            credit.paidAmount += delta
        case .expense:
            credit.paidAmount -= delta
            if credit.paidAmount < 0 { credit.paidAmount = 0 }
        }
        try? modelContext.save()
        dismiss()
    }
    
    private func clamp(_ value: Double, max: Double) -> Double {
        Swift.max(0, Swift.min(value, max))
    }
    
    private func formatted(_ val: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 2
        f.groupingSeparator = " "
        return f.string(from: NSNumber(value: val)) ?? "\(val)"
    }
    
    private func parseFormatted(_ input: String) -> Double? {
        let raw = input.replacingOccurrences(of: " ", with: "")
        return Double(raw)
    }
    
    private func formatInput(_ input: String) -> String {
        let raw = input.replacingOccurrences(of: " ", with: "")
        guard let val = Double(raw) else { return input }
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 2
        f.groupingSeparator = " "
        return f.string(from: NSNumber(value: val)) ?? input
    }
}
