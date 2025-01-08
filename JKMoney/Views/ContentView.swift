import SwiftUI
import SwiftData

struct ContentView: View {
    // Получаем текущий ModelContext из окружения
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Главная", systemImage: "house.fill")
                }

            AnalyticsView()
                .tabItem {
                    Label("Аналитика", systemImage: "chart.pie")
                }

            BudgetsView()
                .tabItem {
                    Label("Бюджет", systemImage: "dollarsign.circle")
                }
        }
        .accentColor(.blue)
    }
}

