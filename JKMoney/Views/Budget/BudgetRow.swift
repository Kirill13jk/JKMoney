import SwiftUI

struct BudgetRow: View {
    let budget: Budget
    
    var body: some View {
        let catItem = budgetCategories.first(where: { $0.title == budget.categoryTitle })
        
        HStack(spacing: 16) {
            if let item = catItem {
                Image(systemName: item.icon)
                    .foregroundColor(.blue)
                    .font(.title3)
            } else {
                Image(systemName: "questionmark.circle")
                    .foregroundColor(.blue)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(budget.categoryTitle)")
                    .font(.headline)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                // Добавляем валюту:
                Text("\(formatted(budget.amount)) \(budget.currency.rawValue)")
                    .fontWeight(.bold)
                    .foregroundColor(budget.type == .income ? .green : .red)
                
                Text(budget.date, style: .date)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatted(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = " "
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
