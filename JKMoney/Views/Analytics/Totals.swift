import SwiftUI
import Charts

extension AnalyticsView {
    struct TotalBarData: Identifiable {
        let id = UUID()
        let label: String
        let value: Double
    }
    
    var totalHorizontalBarChart: some View {
        Chart {
            ForEach(totalBars) { bar in
                BarMark(
                    x: .value("Сумма", bar.value),
                    y: .value("Категория", bar.label)
                )
                .cornerRadius(12)
                .annotation(position: .trailing) {
                    if bar.value > 0 {
                        Text("\(bar.value, format: .number.precision(.fractionLength(2)))")
                            .font(.caption)
                    }
                }
                .foregroundStyle(colorForCategory(bar.label))
            }
        }
        .chartXAxis { AxisMarks(position: .bottom) }
        .chartYAxis { AxisMarks(position: .leading) }
    }
    
    var totalBars: [TotalBarData] {
        let (income, expense) = totalIncomeExpense
        return [
            TotalBarData(label: "Доход",  value: income),
            TotalBarData(label: "Расход", value: expense),
            TotalBarData(label: "Бюджет", value: totalBudget),
        ]
    }
    
    var totalIncomeExpense: (Double, Double) {
        let filtered = userFilteredTransactions.filter { $0.currency == selectedCurrency }
        let sumIncome = filtered.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        let sumExpense = filtered.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        return (sumIncome, sumExpense)
    }
    
    var totalBudget: Double {
        userFilteredBudgets
            .filter { $0.currency == selectedCurrency }
            .reduce(0) { $0 + $1.amount }
    }
    
    func colorForCategory(_ category: String) -> Color {
        switch category {
        case "Доход":  return .green.opacity(0.5)
        case "Расход": return .red.opacity(0.5)
        default:       return .blue.opacity(0.5)
        }
    }
}
