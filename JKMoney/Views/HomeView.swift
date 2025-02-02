import SwiftUI

enum HomeTab: String, CaseIterable {
    case transaction = "Транзакции"
    case budget      = "Бюджеты"
    case credit      = "Кредиты"
    case goals       = "Цели"
}

/// Объединяет 4 экрана в одном с помощью сегментированного Picker
struct HomeView: View {
    @State private var selectedTab: HomeTab = .transaction
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Фон, такой же как в TransactionView
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack {
                    // Сегментированный контрол
                    Picker("Главная", selection: $selectedTab) {
                        ForEach(HomeTab.allCases, id: \.self) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    Divider()
                    
                    // Переключаемся по выбранному пункту
                    switch selectedTab {
                    case .transaction:
                        TransactionView()
                    case .budget:
                        BudgetsView()
                    case .credit:
                        CreditView()
                    case .goals:
                        GoalsView()
                    }
                }
            }
            
        }
    }
}
