import SwiftUI

struct RootView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        Group {
            if appViewModel.isSignedIn {
                // Основное приложение (TabView с Home, Analytics, Settings)
                ContentView()
            } else {
                // Экран авторизации (email/password)
                AuthView()
            }
        }
    }
}
