import SwiftUI
import SwiftData

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        let catItem = findCategory(for: transaction.category)
        
        HStack {
            if let cat = catItem {
                Image(systemName: cat.icon)
                    .foregroundColor(cat.color)
            } else {
                Image(systemName: "questionmark.circle")
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.category)
                    .font(.headline)
                
                // Комментарий убрали — теперь он будет только в Detail
                
                Text(transaction.type == .income ? "Доход" : "Расход")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                // Используем formatInt(...) вместо "%.2f"
                Text("\(formatInt(transaction.amount)) \(transaction.currency.rawValue)")
                    .fontWeight(.bold)
                    .foregroundColor(transaction.type == .income ? .green : .red)
                
                Text(transaction.date, style: .date)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
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
