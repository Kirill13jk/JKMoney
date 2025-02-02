import SwiftUI

@available(iOS 16.0, *)
struct AdaptiveContainer: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var selectedItem: SidebarItem = .home
    
    var body: some View {
        if horizontalSizeClass == .compact {
            iPhoneContent
        } else {
            iPadContent
        }
    }
    
    // MARK: - iPhone: TabView c тремя вкладками
    private var iPhoneContent: some View {
        TabView(selection: $selectedItem) {
            // 1. Home
            NavigationView {
                HomeView() // новый главный экран с Picker
            }
            .tabItem {
                Label("Главная", systemImage: "house")
            }
            .tag(SidebarItem.home)
            
            // 2. Analytics
            NavigationView {
                AnalyticsView()
            }
            .tabItem {
                Label("Аналитика", systemImage: "chart.pie")
            }
            .tag(SidebarItem.analytics)
            
            // 3. Settings
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Label("Настройки", systemImage: "gear")
            }
            .tag(SidebarItem.settings)
        }
        .accentColor(.blue)
    }
    
    // MARK: - iPad: NavigationSplitView
    private var iPadContent: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            sidebar
        } detail: {
            switch selectedItem {
            case .home:
                HomeView()
            case .analytics:
                AnalyticsView()
            case .settings:
                SettingsView()
            }
        }
        .navigationSplitViewStyle(.balanced)
        .navigationSplitViewColumnWidth(min: 240, ideal: 280, max: 320)
    }
    
    // MARK: - Боковая панель для iPad
    private var sidebar: some View {
        List {
            Text("Меню")
                .font(.headline)
                .padding(.vertical, 8)
            
            row(.home, label: "Главная", icon: "house")
            row(.analytics, label: "Аналитика", icon: "chart.pie")
            row(.settings, label: "Настройки", icon: "gear")
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.automatic)
    }
    
    // MARK: - Вспомогательная вью для ячейки в sidebar
    private func row(_ item: SidebarItem, label: String, icon: String) -> some View {
        Button {
            selectedItem = item
        } label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(label)
            }
            .foregroundColor(selectedItem == item ? .white : .primary)
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(selectedItem == item ? Color.blue : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Перечисление пунктов бокового меню
enum SidebarItem {
    case home
    case analytics
    case settings
}
