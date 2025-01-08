import SwiftUI
import Combine

class SettingsViewModel: ObservableObject {
    @AppStorage("selectedTheme") var selectedTheme: String = ThemeMode.system.rawValue
    @Published var selectedThemeMode: ThemeMode = .system
    
    private var cancellables = Set<AnyCancellable>()
    
    // Если вам действительно нужен EnvironmentObject — лучше прокинуть appViewModel извне
    // Иначе можно добавить метод signOut() с логикой
    // и вызвать его в SettingsView.
    var appViewModel: AppViewModel?

    init() {
        selectedThemeMode = ThemeMode(rawValue: selectedTheme) ?? .system
        
        // Обновление selectedTheme при изменении selectedThemeMode
        $selectedThemeMode
            .sink { [weak self] mode in
                self?.selectedTheme = mode.rawValue
            }
            .store(in: &cancellables)
    }
    
    func signOut() {
        appViewModel?.signOut()
    }
}
