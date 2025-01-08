import SwiftUI

/// Управляет цветами для категорий, обеспечивая консистентность между запусками приложения
final class ColorManager: ObservableObject {
    // Палитра цветов (можно расширить по желанию)
    private let colorPalette: [Color] = [
        .blue, .green, .red, .orange, .purple,
        .pink, .teal, .brown, .mint, .cyan
    ]
    
    /// Словарь: ключ = название категории, значение = индекс в colorPalette
    @Published private(set) var colorMap: [String: Int] = [:]
    
    private let userDefaultsKey = "LabelColorMap"
    
    init() {
        loadFromUserDefaults()
    }
    
    /// Возвращает цвет для заданной категории, создавая новый, если его ещё нет
    func color(for label: String) -> Color {
        if let index = colorMap[label] {
            return colorPalette[safe: index] ?? .gray
        }
        
        let newIndex = nextColorIndex()
        colorMap[label] = newIndex
        saveToUserDefaults()
        return colorPalette[newIndex]
    }
    
    // MARK: - Private
    
    private func nextColorIndex() -> Int {
        let usedCount = colorMap.count
        return usedCount % colorPalette.count
    }
    
    private func loadFromUserDefaults() {
        let ud = UserDefaults.standard
        if let dict = ud.dictionary(forKey: userDefaultsKey) as? [String: Int] {
            self.colorMap = dict
        }
    }
    
    private func saveToUserDefaults() {
        let ud = UserDefaults.standard
        ud.set(colorMap, forKey: userDefaultsKey)
    }
}

fileprivate extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }
        return self[index]
    }
}

