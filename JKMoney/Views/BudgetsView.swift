import SwiftUI
import SwiftData

struct BudgetsView: View {
    @Environment(\.modelContext) private var modelContext
    
    // Все бюджеты, отсортированные по дате
    @Query(sort: \Budget.date, order: .reverse) var budgets: [Budget]
    
    var body: some View {
        NavigationView {
            VStack {
                // Список всех бюджетов
                List {
                    ForEach(budgets) { budget in
                        BudgetRow(budget: budget)
                            .listRowSeparator(.hidden) // Скрываем разделитель
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    // Удаляем из базы
                                    modelContext.delete(budget)
                                    try? modelContext.save()
                                } label: {
                                    Label("Удалить", systemImage: "trash")
                                }
                                .tint(.red)
                            }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Бюджеты")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddBudgetView()) {
                        Image(systemName: "plus")
                            .padding(8)
                            .background(Color(UIColor.secondarySystemBackground))
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
}
