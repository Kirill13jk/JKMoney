import SwiftUI
import SwiftData

struct PlannedExpensesView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var plans: [PlannedExpense]
    
    @State private var showAddPlanSheet = false
    @State private var selectedPlan: PlannedExpense? = nil
    
    private var totalPlanned: Double {
        plans.reduce(0) { $0 + $1.amount }
    }
    
    init() {
        let uid = UserDefaults.standard.string(forKey: "userId") ?? "NOUSER"
        _plans = Query(
            filter: #Predicate { $0.userId == uid },
            sort: [SortDescriptor(\.dateCreated, order: .reverse)]
        )
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            if plans.isEmpty {
                emptyStateView
            } else {
                VStack(spacing: 0) {
                    Text("Общий расход: \(formatInt(totalPlanned))")
                        .font(.headline)
                        .foregroundColor(.orange)
                        .padding(.vertical, 4) // уменьшенный отступ
                    listView
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddPlanSheet = true
                } label: {
                    Image(systemName: "plus")
                        .padding(10)
                        .background(Color(UIColor.tertiarySystemBackground))
                        .clipShape(Circle())
                }
            }
        }
        .sheet(isPresented: $showAddPlanSheet) {
            NavigationStack {
                AddPlanView()
                    .navigationBarTitle("Новый план", displayMode: .inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Отмена") {
                                showAddPlanSheet = false
                            }
                        }
                    }
            }
        }
        .sheet(item: $selectedPlan) { plan in
            NavigationStack {
                PlanDetailView(plan: plan)
                    .navigationBarTitle("Детали плана", displayMode: .inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Закрыть") {
                                selectedPlan = nil
                            }
                        }
                    }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack {
            Spacer()
            Text("Нет запланированных расходов.\nНажмите «+» чтобы добавить.")
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
        }
    }
    
    private var listView: some View {
        List {
            ForEach(plans) { plan in
                Button {
                    selectedPlan = plan
                } label: {
                    PlanRow(plan: plan)
                        .contentShape(Rectangle())
                }
                .swipeActions {
                    Button(role: .destructive) {
                        modelContext.delete(plan)
                        try? modelContext.save()
                    } label: {
                        Label("Удалить", systemImage: "trash")
                    }
                    .tint(.red)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private func formatInt(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        f.groupingSeparator = " "
        return f.string(from: NSNumber(value: value)) ?? "\(Int(value))"
    }
}
