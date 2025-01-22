import SwiftUI
import SwiftData

struct AccountsSubView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Budget.date, order: .reverse) var budgets: [Budget]
    
    @State private var showAddBudgetSheet = false
    @State private var selectedBudget: Budget? = nil
    
    var body: some View {
        VStack {
            if budgets.isEmpty {
                Spacer()
                Text("Нет счетов. \nНажмите «+» чтобы добавить.")
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            } else {
                List {
                    ForEach(budgets) { budget in
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
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
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
        .sheet(isPresented: $showAddBudgetSheet) {
            NavigationStack {
                AddBudgetView()
                    .navigationBarTitle("Новый счёт", displayMode: .inline)
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
        .sheet(item: $selectedBudget) { budget in
            NavigationStack {
                BudgetDetailView(budget: budget)
                    .navigationBarTitle("Детали счёта", displayMode: .inline)
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
