import SwiftUI
import SwiftData

struct PlanDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let plan: PlannedExpense
    
    @State private var editedAmount: String = ""
    @State private var editedReminderDate: Date = Date()
    
    var body: some View {
        Form {
            Section("Информация") {
                Text(plan.title)
                    .font(.headline)
                
                if let c = plan.comment, !c.isEmpty {
                    Text("Комментарий: \(c)")
                }
                
                Text("Создано: \(plan.dateCreated, style: .date)")
            }
            
            Section("Редактирование") {
                TextField("Сумма", text: $editedAmount)
                    .keyboardType(.decimalPad)
                    .onChange(of: editedAmount) { _, newVal in
                        let fmt = formatAmount(newVal)
                        if fmt != newVal {
                            editedAmount = fmt
                        }
                    }
                
                DatePicker("Дата напоминания", selection: $editedReminderDate, displayedComponents: .date)
            }
        }
        .navigationTitle("Детали плана")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Сохранить") {
                    saveChanges()
                }
            }

        }
        .onAppear {
            editedAmount = formatAmount(String(plan.amount))
            editedReminderDate = plan.reminderDate
        }
    }
    
    private func saveChanges() {
        let raw = editedAmount.replacingOccurrences(of: " ", with: "")
        guard let val = Double(raw) else {
            dismiss()
            return
        }
        plan.amount = val
        plan.reminderDate = editedReminderDate
        
        try? modelContext.save()
        // Обновляем уведомление
        NotificationManager.shared.scheduleMonthlyNotification(for: plan)
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
