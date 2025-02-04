import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var viewModel = SettingsViewModel()
    @AppStorage("defaultCurrency") private var defaultCurrency: CurrencyType = .usd
    
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
            
            // Новая секция: выбор основной валюты
            Section("Валюта по умолчанию") {
                Picker("Основная валюта", selection: $defaultCurrency) {
                    ForEach(CurrencyType.allCases, id: \.self) { currency in
                        Text(currency.rawValue).tag(currency)
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
