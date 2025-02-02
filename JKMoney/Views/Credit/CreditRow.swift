import SwiftUI

struct CreditRow: View {
    let credit: Credit
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "building.columns.fill")
                .foregroundColor(.blue)
                .font(.title3)
            
            VStack(alignment: .leading) {
                Text(credit.title)
                    .font(.headline)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("\(formatted(credit.paidAmount)) / \(formatted(credit.totalAmount)) \(credit.currency?.rawValue ?? "")")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                if credit.totalAmount > 0 {
                    ProgressView(value: clamp(credit.paidAmount, max: credit.totalAmount),
                                 total: credit.totalAmount)
                    .frame(width: 100)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func clamp(_ value: Double, max: Double) -> Double {
        Swift.max(0, Swift.min(value, max))
    }
    
    private func formatted(_ val: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 2
        f.groupingSeparator = " "
        return f.string(from: NSNumber(value: val)) ?? "\(val)"
    }
}
