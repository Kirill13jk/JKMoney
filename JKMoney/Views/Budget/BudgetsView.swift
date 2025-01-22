import SwiftUI
import SwiftData

struct BudgetsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Budget.date, order: .reverse) var budgets: [Budget]
    
    /// Флаг для показа шторки "AddBudgetView"
    @State private var showAddBudgetSheet = false
    
    /// Для показа шторки "BudgetDetailView"
    @State private var selectedBudget: Budget? = nil
    
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
                        // Кликабельная строка
                        Button {
                            selectedBudget = budget
                        } label: {
                            BudgetRow(budget: budget)
                                .contentShape(Rectangle())
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                modelContext.delete(budget)
                                try? modelContext.save()
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    }
                }
                .padding(.top, 8)
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Бюджет")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                // Кнопка => открыть шторку AddBudgetView
                Button {
                    showAddBudgetSheet = true
                } label: {
                    Image(systemName: "plus")
                        .padding(10)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(Circle())
                }
            }
        }
        // Шторка для добавления нового бюджета
        .sheet(isPresented: $showAddBudgetSheet) {
            NavigationStack {
                AddBudgetView()
                    .navigationBarTitle("Новый бюджет", displayMode: .inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Отмена") {
                                showAddBudgetSheet = false
                            }
                        }
                    }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        
        // Шторка для детального просмотра бюджета
        .sheet(item: $selectedBudget) { budget in
            NavigationStack {
                BudgetDetailView(budget: budget)
                    .navigationBarTitle("Детали бюджета", displayMode: .inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Закрыть") {
                                selectedBudget = nil
                            }
                        }
                    }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}
