import SwiftUI
import SwiftData

@main
struct JKMoneyApp: App {
    @StateObject private var appViewModel = AppViewModel()
    @StateObject private var colorManager = ColorManager()
    @AppStorage("selectedTheme") private var selectedTheme: String = ThemeMode.system.rawValue
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appViewModel)
                .environmentObject(colorManager)
                .modelContainer(for: [Transaction.self, Budget.self, BudgetHistory.self, Goal.self, UserProfile.self])
                .preferredColorScheme(colorSchemeFromTheme(selectedTheme))
        }
    }
    
    private func colorSchemeFromTheme(_ theme: String) -> ColorScheme? {
        guard let mode = ThemeMode(rawValue: theme) else { return nil }
        switch mode {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

enum ThemeMode: String, CaseIterable {
    case system = "Системная"
    case light  = "Светлая"
    case dark   = "Тёмная"
}
