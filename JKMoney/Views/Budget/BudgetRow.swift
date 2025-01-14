import SwiftUI

struct BudgetRow: View {
    let budget: Budget
    
    var body: some View {
        VStack {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: currencyIcon)
                        .foregroundColor(currencyColor)
                        .font(.title3)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(budget.type == .income ? "Доход" : "Расход")
                            .font(.headline)
                        Text(budget.currency.rawValue.uppercased())
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(String(format: "%.2f", budget.amount))
                        .fontWeight(.bold)
                        .foregroundColor(budget.type == .income ? .green : .red)
                    Text(budget.date, style: .date)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.secondarySystemBackground))
        )
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
}
