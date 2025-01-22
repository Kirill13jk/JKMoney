import SwiftUI
import SwiftData

enum GoalFilter: String, CaseIterable {
    case all = "План"
    case completed = "Исполненные"
}

struct GoalsView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var allGoals: [Goal]
    
    @State private var selectedFilter: GoalFilter = .all
    
    /// Шторка для AddGoalView
    @State private var showAddGoalSheet = false
    
    /// Шторка для деталей
    @State private var selectedGoal: Goal? = nil
    
    init() {
        let uid = UserDefaults.standard.string(forKey: "userId") ?? "NOUSER"
        _allGoals = Query(
            filter: #Predicate { $0.userId == uid },
            sort: [SortDescriptor(\.dateCreated, order: .reverse)]
        )
    }
    
    private var filteredGoals: [Goal] {
        switch selectedFilter {
        case .all:
            return allGoals.filter { $0.currentAmount < $0.targetAmount }
        case .completed:
            return allGoals.filter { $0.currentAmount >= $0.targetAmount }
        }
    }
    
    var body: some View {
        VStack {
            Picker("Фильтр", selection: $selectedFilter) {
                ForEach(GoalFilter.allCases, id: \.self) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, 8)
            
            if filteredGoals.isEmpty {
                Spacer()
                Text(selectedFilter == .completed
                     ? "Нет исполненных целей"
                     : "Нет целей. \nНажмите «+» чтобы добавить.")
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            } else {
                List {
                    ForEach(filteredGoals) { goal in
                        Button {
                            selectedGoal = goal
                        } label: {
                            GoalRow(goal: goal)
                                .contentShape(Rectangle())
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                modelContext.delete(goal)
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
        .navigationTitle("Цели")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddGoalSheet = true
                } label: {
                    Image(systemName: "plus")
                        .padding(10)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(Circle())
                }
            }
        }
        // Шторка для AddGoalView
        .sheet(isPresented: $showAddGoalSheet) {
            NavigationStack {
                AddGoalView()
                    .navigationBarTitle("Новая цель", displayMode: .inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Отмена") {
                                showAddGoalSheet = false
                            }
                        }
                    }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        // Шторка для деталей
        .sheet(item: $selectedGoal) { goal in
            NavigationStack {
                GoalDetailView(goal: goal)
                    .navigationBarTitle("Детали цели", displayMode: .inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Закрыть") {
                                selectedGoal = nil
                            }
                        }
                    }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}
