import SwiftUI

/// Пункты меню
enum SidebarItem {
    case home
    case add
    case qr
    case analytics
}

@available(iOS 16.0, *)
struct AdaptiveContainer: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    /// Текущая выбранная вкладка
    @State private var selectedItem: SidebarItem = .home
    
    /// Флаги для отображения sheet
    @State private var showAddSheet = false
    @State private var showQRSheet = false
    
    var body: some View {
        Group {
            if horizontalSizeClass == .compact {
                iPhoneContent
            } else {
                iPadContent
            }
        }
        .sheet(isPresented: $showAddSheet) {
            NavigationStack {
                AddTransactionView()
            }
        }
        // Второй sheet для «QR»
        .sheet(isPresented: $showQRSheet) {
            QRScannerView { scannedText in
                print("Scanned text: \(scannedText)")
                showQRSheet = false
            }
        }
    }
    
    // MARK: - iPhone: TabView (4 вкладки)
    private var iPhoneContent: some View {
        TabView(selection: $selectedItem) {
            
            // 1. Главная (TransactionView)
            NavigationView {
                TransactionView()
            }
            .tabItem {
                Label("Главная", systemImage: "house")
            }
            .tag(SidebarItem.home)
            
            // 2. Добавить – используем Color.clear вместо EmptyView()
            Color.clear
                .tabItem {
                    Label("Добавить", systemImage: "plus.circle.fill")
                }
                .tag(SidebarItem.add)
            
            // 3. QR – используем Color.clear вместо EmptyView()
            Color.clear
                .tabItem {
                    Label("QR", systemImage: "qrcode.viewfinder")
                }
                .tag(SidebarItem.qr)
            
            // 4. Аналитика
            NavigationView {
                AnalyticsView()
            }
            .tabItem {
                Label("Аналитика", systemImage: "chart.pie")
            }
            .tag(SidebarItem.analytics)
        }
        .onChange(of: selectedItem) { newValue in
            switch newValue {
            case .home:
                break
            case .add:
                showAddSheet = true
                selectedItem = .home
            case .qr:
                showQRSheet = true
                selectedItem = .home
            case .analytics:
                break
            }
        }
        .accentColor(.blue)
    }
    
    // MARK: - iPad: NavigationSplitView (4 пункта)
    private var iPadContent: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            sidebar
        } detail: {
            switch selectedItem {
            case .home:
                TransactionView()
            case .add:
                // iPad: при выборе «Добавить» тоже можем открыть sheet
                EmptyView()
            case .qr:
                // iPad: при выборе «QR» открываем sheet
                EmptyView()
            case .analytics:
                AnalyticsView()
            }
        }
        .navigationSplitViewStyle(.balanced)
        .onChange(of: selectedItem) { newValue in
            switch newValue {
            case .home:
                break
            case .add:
                showAddSheet = true
                selectedItem = .home
            case .qr:
                showQRSheet = true
                selectedItem = .home
            case .analytics:
                break
            }
        }
    }
    
    // MARK: - Боковая панель для iPad
    private var sidebar: some View {
        List {
            Text("Меню")
                .font(.headline)
                .padding(.vertical, 8)
            
            row(.home, label: "Главная", icon: "house")
            row(.add, label: "Добавить", icon: "plus.circle.fill")
            row(.qr, label: "QR", icon: "qrcode.viewfinder")
            row(.analytics, label: "Аналитика", icon: "chart.pie")
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.automatic)
    }
    
    // MARK: - Генерация пунктов списка (iPad)
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
