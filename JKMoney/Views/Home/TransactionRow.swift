import SwiftUI
import SwiftData

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        let categoryItem = findCategory(for: transaction.category)
        
        HStack {
            if let catItem = categoryItem {
                Image(systemName: catItem.icon)
                    .foregroundColor(categoryItem?.color ?? .primary)
                    .padding(6)

            } else {
                Image(systemName: "questionmark.circle")
                    .foregroundColor(.gray)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.category)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(transaction.type == .income ? "Доход" : "Расход")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(transaction.amount, specifier: "%.2f") \(transaction.currency.rawValue)")
                    .fontWeight(.bold)
                    .foregroundColor(transaction.type == .income ? .green : .red)
                
                Text(transaction.date, style: .date)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
    
    private func findCategory(for title: String) -> CategoryItem? {
        if let found = incomeCategories.first(where: { $0.title == title }) {
            return found
        }
        if let found = expenseCategories.first(where: { $0.title == title }) {
            return found
        }
        return nil
    }
}
