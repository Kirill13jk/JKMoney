import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var colorManager: ColorManager
    
    // Текущий userId из UserDefaults
    private var userId: String? {
        UserDefaults.standard.string(forKey: "userId")
    }
    
    // Живая выборка всех транзакций для userId, отсортированных по дате (свежие сверху)
    @Query private var transactions: [Transaction]
    
    init() {
        // Так как SwiftData требует «фиксированный» #Predicate,
        // мы берём userId (или "NOUSER", если нет) при инициализации
        let uid = UserDefaults.standard.string(forKey: "userId") ?? "NOUSER"
        _transactions = Query(
            filter: #Predicate { $0.userId == uid },
            sort: [SortDescriptor(\.date, order: .reverse)]
        )
    }
    
    /// Сводка доход/расход по каждой валюте (считаем в памяти)
    private var currencyTotals: [CurrencyType: (income: Double, expense: Double)] {
        let groupedByCurrency = Dictionary(grouping: transactions, by: { $0.currency })
        var result: [CurrencyType: (Double, Double)] = [:]
        
        for (currency, txs) in groupedByCurrency {
            let totalIncome = txs
                .filter { $0.type == .income }
                .reduce(0) { $0 + $1.amount }
            let totalExpense = txs
                .filter { $0.type == .expense }
                .reduce(0) { $0 + $1.amount }
            result[currency] = (totalIncome, totalExpense)
        }
        return result
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 8) {
                
                // ---- Сводка по всем валютам ----
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(currencyTotals.keys.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { currency in
                            if let sums = currencyTotals[currency] {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(currency.rawValue)
                                        .font(.headline)
                                    
                                    // Блок дохода
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
                                    
                                    // Блок расхода
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
                
                // ---- Список всех транзакций ----
                List {
                    ForEach(transactions) { transaction in
                        TransactionRow(transaction: transaction)
                            .environmentObject(colorManager)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
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
                // Шестеренка — слева
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                            .padding(8)
                            .background(Color(UIColor.secondarySystemBackground))
                            .clipShape(Circle())
                    }
                }
                // Плюс — справа
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddTransactionView()) {
                        Image(systemName: "plus")
                            .padding(8)
                            .background(Color(UIColor.secondarySystemBackground))
                            .clipShape(Circle())
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
