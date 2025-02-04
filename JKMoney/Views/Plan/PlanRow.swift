import SwiftUI

struct PlanRow: View {
    let plan: PlannedExpense
    
    var body: some View {
        HStack(spacing: 16) {
            // Иконка для плана
            Image(systemName: "calendar.badge.exclamationmark")
                .foregroundColor(.orange)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(plan.title)
                    .font(.headline)
                
                if let c = plan.comment, !c.isEmpty {
                    Text(c)
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text(plan.categoryTitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
               
                Text("\(formatInt(plan.amount)) \(plan.currency.rawValue)")
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                
                Text(plan.reminderDate, style: .date)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatInt(_ val: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = " "
        return formatter.string(from: NSNumber(value: val)) ?? "\(Int(val))"
    }
}
