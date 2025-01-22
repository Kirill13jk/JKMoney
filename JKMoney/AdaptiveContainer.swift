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
    
    // MARK: - iPhone
    private var iPhoneContent: some View {
        TabView(selection: $selectedItem) {
            NavigationView { TransactionView() }
                .tabItem {
                    Label("Транзакции", systemImage: "arrow.up.arrow.down.circle.fill")
                }
                .tag(SidebarItem.home)
            
            // BudgetsParentView со встроенным Picker [Счета, Кредиты, Планы]
            NavigationView { BudgetsParentView() }
                .tabItem {
                    Label("Бюджет", systemImage: "dollarsign.circle")
                }
                .tag(SidebarItem.budget)
            
            NavigationView { AnalyticsView() }
                .tabItem {
                    Label("Аналитика", systemImage: "chart.pie")
                }
                .tag(SidebarItem.analytics)
            
            NavigationView { SettingsView() }
                .tabItem {
                    Label("Настройки", systemImage: "gear")
                }
                .tag(SidebarItem.settings)
        }
        .accentColor(.blue)
    }
    
    // MARK: - iPad
    private var iPadContent: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            sidebar
        } detail: {
            switch selectedItem {
            case .home:
                TransactionView()
            case .budget:
                BudgetsParentView()
            case .analytics:
                AnalyticsView()
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
            
            row(.home, label: "Транзакции", icon: "arrow.up.arrow.down.circle.fill")
            row(.budget, label: "Бюджет", icon: "dollarsign.circle")
            row(.analytics, label: "Аналитика", icon: "chart.pie")
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
    case budget
    case analytics
    case settings
}
