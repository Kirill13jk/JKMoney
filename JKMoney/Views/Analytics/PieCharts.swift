import SwiftUI
import Charts

extension AnalyticsView {
    var combinedPieCharts: some View {
        VStack {
            HStack(alignment: .top, spacing: 16) {
                VStack {
                    Text("Доходы")
                        .font(.headline)
                        .padding(.bottom, 8)
                    
                    Chart(incomeSegments) { segment in
                        SectorMark(
                            angle: .value("Количество", segment.value),
                            innerRadius: .ratio(0.618),
                            angularInset: 1.5
                        )
                        .cornerRadius(5)
                        .foregroundStyle(by: .value("Категория", segment.label))
                    }
                    .chartLegend(.visible)
                    .chartLegend(.automatic)
                    .frame(height: 120)
                }
                
                VStack {
                    Text("Расходы")
                        .font(.headline)
                        .padding(.bottom, 8)
                    
                    Chart(expenseSegments) { segment in
                        SectorMark(
                            angle: .value("Количество", segment.value),
                            innerRadius: .ratio(0.618),
                            angularInset: 1.5
                        )
                        .cornerRadius(5)
                        .foregroundStyle(by: .value("Категория", segment.label))
                    }
                    .chartLegend(.visible)
                    .chartLegend(.automatic)
                    .frame(height: 120)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
        }
    }
    
    var incomeSegments: [CategorySegment] {
        let list = userFilteredTransactions.filter { $0.type == .income }
        let grouped = Dictionary(grouping: list, by: \.category)
            .mapValues { Double($0.count) }
        let total = grouped.values.reduce(0, +)
        
        return grouped.map { (category, count) in
            let percentage = total > 0 ? (count / total) * 100 : 0
            return CategorySegment(label: category, value: count, percentage: percentage)
        }
        .sorted { $0.value > $1.value }
    }
    
    var expenseSegments: [CategorySegment] {
        let list = userFilteredTransactions.filter { $0.type == .expense }
        let grouped = Dictionary(grouping: list, by: \.category)
            .mapValues { Double($0.count) }
        let total = grouped.values.reduce(0, +)
        
        return grouped.map { (category, count) in
            let percentage = total > 0 ? (count / total) * 100 : 0
            return CategorySegment(label: category, value: count, percentage: percentage)
        }
        .sorted { $0.value > $1.value }
    }
}
