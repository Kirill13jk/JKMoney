import SwiftUI

struct ChangeBudgetAmountView: View {
    let budget: Budget
    @Binding var changeType: TransactionType
    @Binding var changeAmount: String
    let onApply: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Изменить сумму")) {
                    Picker("Тип", selection: $changeType) {
                        Text("Доход").tag(TransactionType.income)
                        Text("Расход").tag(TransactionType.expense)
                    }
                    .pickerStyle(.segmented)
                    
                    TextField("Введите сумму", text: $changeAmount)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Изменить бюджет")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        onApply()
                    }
                }
            }
        }
    }
}
