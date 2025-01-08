import SwiftUI
import SwiftData

@main
struct JKMoneyApp: App {
    @StateObject private var appViewModel = AppViewModel()
    @StateObject private var colorManager = ColorManager()

    // Храним выбранную тему (системная / светлая / тёмная)
    @AppStorage("selectedTheme") private var selectedTheme: String = ThemeMode.system.rawValue

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(colorManager)
                .environmentObject(appViewModel)
                .modelContainer(for: [Transaction.self, UserProfile.self, Budget.self])
                .preferredColorScheme(colorSchemeFromTheme(selectedTheme))
        }
    }
    
    // MARK: - Поддержка трёх тем
    private func colorSchemeFromTheme(_ theme: String) -> ColorScheme? {
        guard let mode = ThemeMode(rawValue: theme) else { return nil }
        switch mode {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

enum ThemeMode: String, CaseIterable {
    case system = "Системная"
    case light  = "Светлая"
    case dark   = "Тёмная"
}
