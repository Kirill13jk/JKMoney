import SwiftUI
import SwiftData
import AVFoundation

enum TransactionSegment: String, CaseIterable {
    case actual = "Сделка"
    case planned = "Запланировано"
}

struct TransactionView: View {
    // MARK: - Environment
    @Environment(\.modelContext) private var modelContext
    // MARK: - State
    @State private var selectedSegment: TransactionSegment = .actual
    @State private var showSettingsSheet = false
    @State private var showQRScanner = false
    @State private var selectedTransaction: Transaction? = nil
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
                    segmentedPicker
                    contentForSelectedSegment
                }
            }
            .navigationTitle("Сделка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { settingsButton }
            .sheet(isPresented: $showSettingsSheet) { settingsSheet }
            .sheet(isPresented: $showQRScanner) { qrScannerSheet }
            .sheet(item: $selectedTransaction) { TransactionDetailView(transaction: $0) }
            .sheet(item: $selectedPlan) { planSheet(for: $0) }
        }
    }
}

// MARK: - Subviews & Helpers (TransactionView)
private extension TransactionView {
    var segmentedPicker: some View {
        Picker("Раздел", selection: $selectedSegment) {
            ForEach(TransactionSegment.allCases, id: \.self) { segment in
                Text(segment.rawValue).tag(segment)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }
    
    @ViewBuilder
    var contentForSelectedSegment: some View {
        switch selectedSegment {
        case .actual:
            actualTransactionsContent
        case .planned:
            plannedExpensesContent
        }
    }
    
    var settingsButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                showSettingsSheet = true
            } label: {
                Image(systemName: "gear")
                    .padding(10)
                    .background(Color(UIColor.tertiarySystemBackground))
                    .clipShape(Circle())
            }
        }
    }
    
    var settingsSheet: some View {
        NavigationStack {
            SettingsView()
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Закрыть") {
                            showSettingsSheet = false
                        }
                    }
                }
        }
    }
    
    var qrScannerSheet: some View {
        QRScannerView { scannedText in
            handleScannedQR(scannedText)
            showQRScanner = false
        }
    }
    
    func planSheet(for plan: PlannedExpense) -> some View {
        NavigationStack {
            PlanDetailView(plan: plan)
                .navigationBarTitle("Детали плана", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Закрыть") { selectedPlan = nil }
                    }
                }
        }
    }
    
    // Обработка QR
    func handleScannedQR(_ text: String) {
        guard let uid = userId else { return }
        var amount = 0.0
        var comment = ""
        text.components(separatedBy: "\n").forEach { line in
            let parts = line.components(separatedBy: "=")
            if parts.count == 2 {
                let key = parts[0].uppercased()
                let value = parts[1]
                if key == "AMOUNT", let parsed = Double(value) {
                    amount = parsed
                } else if key == "COMMENT" {
                    comment = value
                }
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
        Dictionary(grouping: items, by: { $0.currency })
            .mapValues { txs in
                let inc = txs.filter { $0.type == .income }.reduce(0, { $0 + $1.amount })
                let exp = txs.filter { $0.type == .expense }.reduce(0, { $0 + $1.amount })
                return (inc, exp)
            }
    }
    
    func formatInt(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        f.groupingSeparator = " "
        return f.string(from: NSNumber(value: value)) ?? "\(Int(value))"
    }
}

// MARK: - Контент транзакций и расходов
private extension TransactionView {
    @ViewBuilder
    var actualTransactionsContent: some View {
        if transactions.isEmpty {
            EmptyStateView(message: "Нет транзакций.\nНажмите «+» чтобы добавить.")
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
                        CurrencySummaryView(currency: currency, income: sums.income, expense: sums.expense)
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
    
    @ViewBuilder
    var plannedExpensesContent: some View {
        if plans.isEmpty {
            EmptyStateView(message: "Нет запланированных расходов.\nНажмите «+» чтобы добавить.")
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

// MARK: - Дополнительные вспомогательные вью

struct EmptyStateView: View {
    let message: String
    var body: some View {
        VStack {
            Spacer()
            Text(message)
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
        }
    }
}

struct CurrencySummaryView: View {
    let currency: CurrencyType
    let income: Double
    let expense: Double
    
    var body: some View {
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
    
    private func formatInt(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        f.groupingSeparator = " "
        return f.string(from: NSNumber(value: value)) ?? "\(Int(value))"
    }
}
