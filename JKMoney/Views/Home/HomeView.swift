import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var colorManager: ColorManager
    
    private var userId: String? {
        UserDefaults.standard.string(forKey: "userId")
    }
    
    @Query private var transactions: [Transaction]
    
    init() {
        let uid = UserDefaults.standard.string(forKey: "userId") ?? "NOUSER"
        _transactions = Query(
            filter: #Predicate { $0.userId == uid },
            sort: [SortDescriptor(\.date, order: .reverse)]
        )
    }
    
    private var currencyTotals: [CurrencyType: (income: Double, expense: Double)] {
        let grouped = Dictionary(grouping: transactions) { $0.currency }
        var result: [CurrencyType: (Double, Double)] = [:]
        
        for (currency, txs) in grouped {
            let inc = txs.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
            let exp = txs.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
            result[currency] = (inc, exp)
        }
        return result
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(currencyTotals.keys.sorted { $0.rawValue < $1.rawValue }, id: \.self) { currency in
                        if let sums = currencyTotals[currency] {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(currency.rawValue)
                                    .font(.headline)
                                if sums.income > 0 {
                                    HStack(spacing: 6) {
                                        Image(systemName: "arrow.up.right")
                                            .foregroundColor(.white)
                                            .padding(6)
                                            .background(Color.green)
                                            .cornerRadius(6)
                                        Text("\(sums.income, specifier: "%.2f")")
                                            .foregroundColor(.green)
                                    }
                                }
                                if sums.expense > 0 {
                                    HStack(spacing: 6) {
                                        Image(systemName: "arrow.down.left")
                                            .foregroundColor(.white)
                                            .padding(6)
                                            .background(Color.red)
                                            .cornerRadius(6)
                                        Text("\(sums.expense, specifier: "%.2f")")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                        }
                    }
                }
                .padding([.horizontal, .top])
            }
            List {
                ForEach(transactions) { transaction in
                    TransactionRow(transaction: transaction)
                        .environmentObject(colorManager)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                modelContext.delete(transaction)
                                try? modelContext.save()
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                            .tint(.red)
                        }
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Транзакции")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: AddTransactionView()) {
                    Image(systemName: "plus")
                        .padding(10)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(Circle())
                }
            }
        }
    }
}
