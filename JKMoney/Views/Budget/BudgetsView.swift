import SwiftUI
import SwiftData

struct BudgetsView: View {
    // MARK: - Environment
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - Query
    @Query(sort: \Budget.date, order: .reverse) var budgets: [Budget]
    
    // MARK: - State
    @State private var showAddBudgetSheet = false
    @State private var selectedBudget: Budget? = nil
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                // Фон, как в TransactionView
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if budgets.isEmpty {
                    emptyStateView
                } else {
                    listView
                }
            }
            .navigationTitle("Бюджет")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddBudgetSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .padding(10)
                            .background(Color(UIColor.tertiarySystemBackground))
                            .clipShape(Circle())
                    }
                }
            }
            .sheet(isPresented: $showAddBudgetSheet) {
                NavigationStack {
                    AddBudgetView()
                        .navigationBarTitle("Новый", displayMode: .inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Отмена") {
                                    showAddBudgetSheet = false
                                }
                            }
                        }
                }
            }
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
            }
        }
    }
}

// MARK: - Private Views
private extension BudgetsView {
    /// Отображается, если бюджетов нет
    var emptyStateView: some View {
        VStack {
            Spacer()
            Text("Нет бюджетов. \nНажмите «+» чтобы добавить.")
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
        }
    }
    
    /// Список, если бюджеты существуют
    var listView: some View {
        List {
            ForEach(budgets) { budget in
                Button {
                    selectedBudget = budget
                } label: {
                    BudgetRow(budget: budget)
                        .contentShape(Rectangle()) // чтобы касание было по всей ячейке
                }
                .swipeActions {
                    Button(role: .destructive) {
                        modelContext.delete(budget)
                        try? modelContext.save()
                    } label: {
                        Label("Удалить", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden) // скрываем фон списка, чтобы был виден общий фон
    }
}
