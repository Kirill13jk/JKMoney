import SwiftUI
import SwiftData
import AVFoundation

enum TransactionSegment: String, CaseIterable {
    case actual   = "Транзакции"
    case planned  = "Запланировано"
}

struct TransactionView: View {
    // MARK: - Environment
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - State
    @State private var selectedSegment: TransactionSegment = .actual
    
    // Транзакции
    @State private var showQRScanner = false
    @State private var showAddTransactionSheet = false
    @State private var selectedTransaction: Transaction? = nil
    
    // Запланированные расходы
    @State private var showAddPlanSheet = false
    @State private var selectedPlan: PlannedExpense? = nil
    
    // MARK: - User ID
    private var userId: String? {
        UserDefaults.standard.string(forKey: "userId")
    }
    
    // MARK: - Queries
    @Query private var transactions: [Transaction]
    @Query private var plans: [PlannedExpense]
    
    // MARK: - Init
    init() {
        let uid = UserDefaults.standard.string(forKey: "userId") ?? "NOUSER"
        _transactions = Query(
            filter: #Predicate { $0.userId == uid },
            sort: [SortDescriptor(\.date, order: .reverse)]
        )
        _plans = Query(
            filter: #Predicate { $0.userId == uid },
            sort: [SortDescriptor(\.dateCreated, order: .reverse)]
        )
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack {
                    // Сегментированный контрол
                    Picker("Раздел", selection: $selectedSegment) {
                        ForEach(TransactionSegment.allCases, id: \.self) { segment in
                            Text(segment.rawValue).tag(segment)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    // Контент по выбранному сегменту
                    switch selectedSegment {
                    case .actual:
                        actualTransactionsContent
                    case .planned:
                        plannedExpensesContent
                    }
                }
            }
            .navigationTitle("Транзакции")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if selectedSegment == .actual {
                        Button {
                            showQRScanner = true
                        } label: {
                            Image(systemName: "qrcode.viewfinder")
                                .padding(10)
                                .background(Color(UIColor.tertiarySystemBackground))
                                .clipShape(Circle())
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if selectedSegment == .actual {
                        Button {
                            showAddTransactionSheet = true
                        } label: {
                            Image(systemName: "plus")
                                .padding(10)
                                .background(Color(UIColor.tertiarySystemBackground))
                                .clipShape(Circle())
                        }
                    } else {
                        Button {
                            showAddPlanSheet = true
                        } label: {
                            Image(systemName: "plus")
                                .padding(10)
                                .background(Color(UIColor.tertiarySystemBackground))
                                .clipShape(Circle())
                        }
                    }
                }
            }
            // Sheets для транзакций
            .sheet(isPresented: $showQRScanner) {
                QRScannerView { scannedText in
                    handleScannedQR(scannedText)
                    showQRScanner = false
                }
            }
            .sheet(isPresented: $showAddTransactionSheet) {
                NavigationStack {
                    AddTransactionView()
                        .navigationBarTitle("Новая транзакция", displayMode: .inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Отмена") {
                                    showAddTransactionSheet = false
                                }
                            }
                        }
                }
            }
            .sheet(item: $selectedTransaction) { transaction in
                TransactionDetailView(transaction: transaction)
            }
            // Sheets для планов
            .sheet(isPresented: $showAddPlanSheet) {
                NavigationStack {
                    AddPlanView()
                        .navigationBarTitle("Новый план", displayMode: .inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Отмена") {
                                    showAddPlanSheet = false
                                }
                            }
                        }
                }
            }
            .sheet(item: $selectedPlan) { plan in
                NavigationStack {
                    PlanDetailView(plan: plan)
                        .navigationBarTitle("Детали плана", displayMode: .inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Закрыть") {
                                    selectedPlan = nil
                                }
                            }
                        }
                }
            }
        }
    }
}

// MARK: - Транзакции
private extension TransactionView {
    @ViewBuilder
    var actualTransactionsContent: some View {
        if transactions.isEmpty {
            VStack {
                Spacer()
                Text("Нет транзакций.\nНажмите «+» чтобы добавить.")
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            }
        } else {
            VStack(spacing: 0) {
                scrollTotals
                transactionsList
            }
        }
    }
    
    var scrollTotals: some View {
        let currencyTotals = groupByCurrency(transactions)
        
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(currencyTotals.keys.sorted { $0.rawValue < $1.rawValue }, id: \.self) { currency in
                    if let sums = currencyTotals[currency] {
                        currencySummaryView(currency: currency,
                                            income: sums.income,
                                            expense: sums.expense)
                    }
                }
            }
            .padding([.horizontal, .top])
        }
    }
    
    var transactionsList: some View {
        List {
            ForEach(transactions) { transaction in
                Button {
                    selectedTransaction = transaction
                } label: {
                    TransactionRow(transaction: transaction)
                        .contentShape(Rectangle())
                }
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
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }
    
    func handleScannedQR(_ text: String) {
        guard let uid = userId else { return }
        
        var amount = 0.0
        var comment = ""
        let lines = text.components(separatedBy: "\n")
        for line in lines {
            let parts = line.components(separatedBy: "=")
            guard parts.count == 2 else { continue }
            let key = parts[0].uppercased()
            let val = parts[1]
            if key == "AMOUNT" {
                amount = Double(val) ?? 0
            } else if key == "COMMENT" {
                comment = val
            }
        }
        guard amount > 0 else { return }
        
        let newTransaction = Transaction(
            title: "QR",
            amount: amount,
            date: Date(),
            category: "Другое",
            type: .expense,
            currency: .usd,
            userId: uid,
            comment: comment.isEmpty ? nil : comment
        )
        
        modelContext.insert(newTransaction)
        try? modelContext.save()
    }
    
    func groupByCurrency(_ items: [Transaction]) -> [CurrencyType: (income: Double, expense: Double)] {
        Dictionary(grouping: items) { $0.currency }
            .mapValues { txs in
                let inc = txs.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
                let exp = txs.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
                return (inc, exp)
            }
    }
    
    func currencySummaryView(currency: CurrencyType, income: Double, expense: Double) -> some View {
        let net = income - expense
        
        return VStack(alignment: .leading, spacing: 10) {
            Text(currency.rawValue)
                .font(.headline)
            
            if income > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.right")
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color.green)
                        .cornerRadius(6)
                    Text(formatInt(income))
                        .foregroundColor(.green)
                }
            }
            if expense > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.down.left")
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color.red)
                        .cornerRadius(6)
                    Text(formatInt(expense))
                        .foregroundColor(.red)
                }
            }
            HStack(spacing: 6) {
                Image(systemName: "scalemass")
                    .foregroundColor(.white)
                    .padding(6)
                    .background(Color.blue)
                    .cornerRadius(6)
                Text(formatInt(net))
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
            }
        }
        .padding()
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(10)
    }
    
    func formatInt(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        f.groupingSeparator = " "
        return f.string(from: NSNumber(value: value)) ?? "\(Int(value))"
    }
}

// MARK: - Запланированные расходы
private extension TransactionView {
    @ViewBuilder
    var plannedExpensesContent: some View {
        if plans.isEmpty {
            VStack {
                Spacer()
                Text("Нет запланированных расходов.\nНажмите «+» чтобы добавить.")
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            }
        } else {
            let totalPlans = plans.reduce(0) { $0 + $1.amount }
            VStack(spacing: 0) {
                Text("Общий расход: \(formatInt(totalPlans))")
                    .font(.headline)
                    .foregroundColor(.orange)
                    .padding(.vertical, 4)
                
                List {
                    ForEach(plans) { plan in
                        Button {
                            selectedPlan = plan
                        } label: {
                            PlanRow(plan: plan)
                                .contentShape(Rectangle())
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                modelContext.delete(plan)
                                try? modelContext.save()
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                            .tint(.red)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
    }
}
