import SwiftUI

struct BudgetRow: View {
    let budget: Budget
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: currencyIcon)
                .foregroundColor(currencyColor)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Бюджет")
                    .font(.headline)
                
                Text(budget.currency.rawValue.uppercased())
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(formatted(budget.amount))")
                    .fontWeight(.bold)
                    .foregroundColor(budget.type == .income ? .green : .red)
                Text(budget.date, style: .date)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8) 
    }
    
    private var currencyIcon: String {
        switch budget.currency {
        case .usd: return "dollarsign.circle.fill"
        case .eur: return "eurosign.circle.fill"
        case .uzs: return "circle.fill"
        case .rub: return "rublesign.circle.fill"
        }
    }
    
    private var currencyColor: Color {
        switch budget.currency {
        case .usd: return .green
        case .eur: return .blue
        case .uzs: return .pink
        case .rub: return .purple
        }
    }
    
    private func formatted(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = " "
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
