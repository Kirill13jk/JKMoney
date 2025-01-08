import SwiftUI
import SwiftData

struct TransactionRow: View {
    let transaction: Transaction
    @EnvironmentObject var colorManager: ColorManager

    var body: some View {
        VStack {
            HStack {
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
            
            // Комментарий, если есть
            if let comment = transaction.comment, !comment.isEmpty {
                Text(comment)
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(transaction.category), \(transaction.type == .income ? "Доход" : "Расход"), сумма \(transaction.amount) \(transaction.currency.rawValue), дата \(formattedDate), комментарий: \(commentText)")
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: transaction.date)
    }
    
    private var commentText: String {
        transaction.comment ?? "Без комментария"
    }
}

