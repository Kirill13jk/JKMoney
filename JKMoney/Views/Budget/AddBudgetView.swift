import SwiftUI
import SwiftData

struct AddBudgetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private var type: TransactionType = .income

    @State private var amount: String = ""
    @State private var currency: CurrencyType = .usd
    @State private var date: Date = Date()

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
                Picker("Валюта", selection: $currency) {
                    ForEach(CurrencyType.allCases, id: \.self) { c in
                        Text(c.rawValue.uppercased()).tag(c)
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
        }
        .navigationTitle("Новый бюджет")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Сохранить") {
                    saveBudget()
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

    private func saveBudget() {
        guard isFormValid else { return }
        guard let userId = UserDefaults.standard.string(forKey: "userId") else { return }
        guard let amt = Double(amount.replacingOccurrences(of: " ", with: "")) else { return }

        let budget = Budget(
            type: type,
            amount: amt,
            currency: currency,
            date: date,
            userId: userId
        )
        modelContext.insert(budget)
        try? modelContext.save()
        dismiss()
    }
}
