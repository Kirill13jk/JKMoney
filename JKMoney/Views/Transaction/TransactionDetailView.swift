import SwiftUI

struct TransactionDetailView: View {
    @Environment(\.dismiss) private var dismiss   // добавляем
    
    let transaction: Transaction
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Информация") {
                    HStack {
                        Text("Категория:")
                        Spacer()
                        Text(transaction.category)
                    }
                    
                    HStack {
                        Text("Тип:")
                        Spacer()
                        Text(transaction.type == .income ? "Доход" : "Расход")
                    }
                    
                    HStack {
                        Text("Сумма:")
                        Spacer()
                        Text("\(transaction.amount, specifier: "%.2f") \(transaction.currency.rawValue)")
                    }
                    
                    HStack {
                        Text("Дата:")
                        Spacer()
                        Text(transaction.date, style: .date)
                    }
                    
                    if let comment = transaction.comment, !comment.isEmpty {
                        Text("Комментарий: \(comment)")
                    }
                }
            }
            .navigationTitle("Детали транзакции")
            .navigationBarTitleDisplayMode(.inline)
            // Добавляем тулбар с кнопкой "Закрыть"
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }
}
