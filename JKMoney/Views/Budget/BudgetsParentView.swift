import SwiftUI
import SwiftData

enum BudgetsTab: String, CaseIterable {
    case accounts = "Счета"
    case credits = "Кредиты"
    case plans = "Планы"
}

struct BudgetsParentView: View {
    @State private var selectedTab: BudgetsTab = .accounts
    
    var body: some View {
        VStack {
            Picker("Раздел", selection: $selectedTab) {
                ForEach(BudgetsTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, 8)
            
            Divider()
            
            // В зависимости от выбранного сегмента
            switch selectedTab {
            case .accounts:
                // Показываем старый BudgetsView
                AccountsSubView()
            case .credits:
                // Показываем CreditView
                CreditSubView()
            case .plans:
                // Показываем GoalsView
                GoalsView()
            }
        }
        .navigationTitle("Финансы") // или "Бюджет"
    }
}
