import Foundation

/// Форматирование числа без дробных частей, с разделителем тысяч
func formatInt(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 0
    formatter.groupingSeparator = " "
    return formatter.string(from: NSNumber(value: value)) ?? "\(Int(value))"
}
