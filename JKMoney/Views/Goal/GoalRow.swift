import SwiftUI
import SwiftData

struct GoalRow: View {
    let goal: Goal
    
    var body: some View {
        HStack(spacing: 16) {
            let categoryItem = goalCategories.first(where: { $0.title == goal.categoryTitle })
            
            if let iconName = categoryItem?.icon {
                Image(systemName: iconName)
                    .foregroundColor(categoryItem?.color ?? .primary)
                    .font(.title3)
            }
            
            VStack(alignment: .leading) {
                Text(goal.title)
                    .font(.headline)
                
                if let comment = goal.comment, !comment.isEmpty {
                    Text(comment)
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text(goal.categoryTitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                 Text("\(formatted(goal.currentAmount)) / \(formatted(goal.targetAmount)) \(goal.currency?.rawValue ?? "")")
                    .font(.footnote)
                    .foregroundColor(.blue)
                    .fontWeight(.bold)
                
                if goal.targetAmount > 0 {
                    ProgressView(value: clamped(goal.currentAmount, max: goal.targetAmount), total: goal.targetAmount)
                        .frame(width: 100)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func clamped(_ value: Double, max: Double) -> Double {
        Swift.max(0, Swift.min(value, max))
    }
    
    private func formatted(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = " "
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
