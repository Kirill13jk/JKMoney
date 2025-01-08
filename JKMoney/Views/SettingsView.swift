import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Тема")) {
                    Picker("Выберите тему", selection: $viewModel.selectedThemeMode) {
                        ForEach(ThemeMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityLabel("Выбор темы приложения")
                }
                
                Section {
                    Button("Выйти") {
                        viewModel.appViewModel = appViewModel
                        viewModel.signOut()
                    }
                    .foregroundColor(.red)
                    .accessibilityLabel("Выйти из аккаунта")
                }
            }
            .navigationTitle("Настройки")
        }
    }
}
