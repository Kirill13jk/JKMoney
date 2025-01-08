import SwiftUI
import Charts
import SwiftData

enum AnalyticsMode: String, CaseIterable {
    case category = "Категории"
    case currency = "Валюта"
}

struct AnalyticsView: View {
    @EnvironmentObject var colorManager: ColorManager
    @Query(sort: \Transaction.date, order: .reverse) var transactions: [Transaction]
    
    @State private var analyticsMode: AnalyticsMode = .category
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Переключатель режима
                Picker("Режим", selection: $analyticsMode) {
                    ForEach(AnalyticsMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Доходы
                incomeBlock
                
                // Расходы
                expenseBlock
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Блок доходов
    private var incomeBlock: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Доходы")
                .font(.headline)
                .padding(.top, 8)

            HStack(alignment: .center, spacing: 16) {
                // Пирог
                Chart {
                    ForEach(incomeSegments, id: \.label) { segment in
                        SectorMark(
                            angle: .value("Value", segment.value),
                            innerRadius: .ratio(0.618),
                            angularInset: 1.5
                        )
                        .cornerRadius(5)
                        .foregroundStyle(colorManager.color(for: segment.label))
                    }
                }
                .frame(width: 140, height: 140)
                .chartLegend(.hidden)
                
                Spacer()
                
                // Легенда
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(incomeSegments, id: \.label) { segment in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(colorManager.color(for: segment.label))
                                .frame(width: 10, height: 10)
                            
                            Text(segment.label)
                                .font(.caption)
                            
                            Spacer()
                     
                            
                            if analyticsMode == .category {
                                Text("\(Int(segment.value)) шт")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            } else {
                                Text("\(segment.value, specifier: "%.2f")")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
        }
    }
    
    // MARK: - Блок расходов
    private var expenseBlock: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Расходы")
                .font(.headline)
                .padding(.top, 8)

            HStack(alignment: .center, spacing: 16) {
                // Пирог
                Chart {
                    ForEach(expenseSegments, id: \.label) { segment in
                        SectorMark(
                            angle: .value("Value", segment.value),
                            innerRadius: .ratio(0.618),
                            angularInset: 1.5
                        )
                        .cornerRadius(5)
                        .foregroundStyle(colorManager.color(for: segment.label))
                    }
                }
                .frame(width: 140, height: 140)
                .chartLegend(.hidden)
                
                Spacer()
                
                // Легенда
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(expenseSegments, id: \.label) { segment in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(colorManager.color(for: segment.label))
                                .frame(width: 10, height: 10)
                            
                            Text(segment.label)
                                .font(.caption)
                            
                            Spacer()
                            
                            if analyticsMode == .category {
                                Text("\(Int(segment.value)) шт")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            } else {
                                Text("\(segment.value, specifier: "%.2f")")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
        }
    }
    
    // MARK: - Фильтруем транзакции по текущему пользователю
    private var userFilteredTransactions: [Transaction] {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else { return [] }
        return transactions.filter { $0.userId == userId }
    }
    
    // MARK: - Сегменты доходов (value = count или sum)
    private var incomeSegments: [(label: String, value: Double)] {
        let incomes = userFilteredTransactions.filter { $0.type == .income }
        
        switch analyticsMode {
        case .category:
            // Группируем по category и берём count
            let dict = Dictionary(grouping: incomes, by: { $0.category })
                .mapValues { Double($0.count) }
            return dict.map { (label, value) in (label, value) }
            
        case .currency:
            // Группируем по currency и суммируем amount
            let dict = Dictionary(grouping: incomes, by: { $0.currency.rawValue })
                .mapValues { $0.reduce(0) { $0 + $1.amount } }
            return dict.map { (label, value) in (label, value) }
        }
    }
    
    // MARK: - Сегменты расходов (value = count или sum)
    private var expenseSegments: [(label: String, value: Double)] {
        let expenses = userFilteredTransactions.filter { $0.type == .expense }
        
        switch analyticsMode {
        case .category:
            let dict = Dictionary(grouping: expenses, by: { $0.category })
                .mapValues { Double($0.count) }
            return dict.map { (label, value) in (label, value) }
            
        case .currency:
            let dict = Dictionary(grouping: expenses, by: { $0.currency.rawValue })
                .mapValues { $0.reduce(0) { $0 + $1.amount } }
            return dict.map { (label, value) in (label, value) }
        }
    }
}
