import SwiftUI

struct BudgetRow: View {
    let budget: Budget
    
    var body: some View {
        VStack {
            HStack {
                // Левая часть — иконка валюты + тип (Доход/Расход)
                HStack(spacing: 8) {
                    // Иконка для выбранной валюты
                    Image(systemName: currencyIcon)
                        .foregroundColor(currencyColor)
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        // Отображаем текст типа операции
                        Text(budget.type == .income ? "Доход" : "Расход")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(budget.currency.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Правая часть — сумма и дата
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
    
    // Выбираем иконку в зависимости от валюты
    private var currencyIcon: String {
        switch budget.currency {
        case .usd: return "dollarsign.circle.fill"
        case .eur: return "eurosign.circle.fill"
        case .uzs: return "som" // в SF Symbols иконки "som" нет, придётся задать что-то другое
        case .rub: return "rublesign.circle.fill"
        }
    }
    
    // Цвет иконки в зависимости от валюты (пример)
    private var currencyColor: Color {
        switch budget.currency {
        case .usd: return .green
        case .eur: return .blue
        case .uzs: return .pink
        case .rub: return .purple
        }
    }
}
