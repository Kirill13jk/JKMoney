import SwiftUI
import Combine

class SettingsViewModel: ObservableObject {
    @AppStorage("selectedTheme") var selectedTheme: String = ThemeMode.system.rawValue
    @Published var selectedThemeMode: ThemeMode = .system
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        selectedThemeMode = ThemeMode(rawValue: selectedTheme) ?? .system
        
        $selectedThemeMode
            .sink { [weak self] mode in
                self?.selectedTheme = mode.rawValue
            }
            .store(in: &cancellables)
    }
}
