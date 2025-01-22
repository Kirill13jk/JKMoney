import SwiftUI
import SwiftData

struct TransactionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.date, order: .reverse) var transactions: [Transaction]

    var body: some View {
        NavigationView {
            List(transactions) { transaction in
                HStack {
                    VStack(alignment: .leading) {
                        Text(transaction.title)
                            .font(.headline)
                        Text(transaction.category)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(String(format: "%.2f %@", transaction.amount, transaction.currency.rawValue))
                        .foregroundColor(transaction.type == .income ? .green : .red)
                }
                .padding(.vertical, 5)
            }
            .navigationTitle("Все транзакции")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        AddTransactionView()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}
