import SwiftUI
import SwiftData

struct BudgetsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Budget.date, order: .reverse) var budgets: [Budget]
    
    var body: some View {
        VStack {
            if budgets.isEmpty {
                Spacer()
                Text("Нет бюджетов. Нажмите «+» чтобы добавить.")
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            } else {
                List {
                    ForEach(budgets) { budget in
                        NavigationLink(destination: BudgetDetailView(budget: budget)) {
                            BudgetRow(budget: budget)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                modelContext.delete(budget)
                                try? modelContext.save()
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)) // Настройка отступов
                    }
                }
                .padding(.top, 8)
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Бюджет")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: AddBudgetView()) {
                    Image(systemName: "plus")
                        .padding(10)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(Circle())
                }
            }
        }
    }
}
