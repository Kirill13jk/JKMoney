import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        Form {
            Section("Тема") {
                Picker("Выберите тему", selection: $viewModel.selectedThemeMode) {
                    ForEach(ThemeMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Section {
                Button("Выйти") {
                    appViewModel.signOut()
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Настройки")
    }
}
