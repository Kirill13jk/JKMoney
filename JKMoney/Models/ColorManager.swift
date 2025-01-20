import SwiftUI

final class ColorManager: ObservableObject {
    private let colorPalette: [Color] = [
        .blue, .green, .red, .orange, .purple,
        .pink, .teal, .brown, .mint, .cyan
    ]

    @Published private(set) var colorMap: [String: Int] = [:]

    private let userDefaultsKey = "LabelColorMap"

    init() {
        loadFromUserDefaults()
    }

    func color(for label: String) -> Color {
        if let index = colorMap[label] {
            return colorPalette[safe: index] ?? .gray
        }

        let newIndex = nextColorIndex()

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.colorMap[label] = newIndex
            self.saveToUserDefaults()
        }

        return colorPalette[newIndex]
    }

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
