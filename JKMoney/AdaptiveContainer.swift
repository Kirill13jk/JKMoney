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
    
    private var iPhoneContent: some View {
        TabView {
            NavigationView { HomeView() }
                .tabItem {
                    Label("Главная", systemImage: "house.fill")
                }
            NavigationView { AnalyticsView() }
                .tabItem {
                    Label("Аналитика", systemImage: "chart.pie")
                }
            NavigationView { BudgetsView() }
                .tabItem {
                    Label("Бюджет", systemImage: "dollarsign.circle")
                }
            NavigationView { SettingsView() }
                .tabItem {
                    Label("Настройки", systemImage: "gear")
                }
        }
        .accentColor(.blue)
    }
    
    private var iPadContent: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            sidebar
        } detail: {
            switch selectedItem {
            case .home:
                HomeView()
            case .analytics:
                AnalyticsView()
            case .budget:
                BudgetsView()
            case .settings:
                SettingsView()
            }
        }
        .navigationSplitViewStyle(.balanced)
        .navigationSplitViewColumnWidth(min: 240, ideal: 280, max: 320)
    }
    
    private var sidebar: some View {
        List {
            Text("Меню")
                .font(.headline)
                .padding(.vertical, 8)
            
            row(.home, label: "Главная", icon: "house.fill")
            row(.analytics, label: "Аналитика", icon: "chart.pie")
            row(.budget, label: "Бюджет", icon: "dollarsign.circle")
            row(.settings, label: "Настройки", icon: "gear")
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.automatic)
    }
    
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

enum SidebarItem {
    case home
    case analytics
    case budget
    case settings
}
