import SwiftUI
import SwiftData

enum CreditFilter: String, CaseIterable {
    case onlyCredits = "Кредиты"
    case onlyLoans   = "Займы"
    case completed   = "Исполнено" // новый пункт
}

struct CreditView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allCredits: [Credit]
    
    @State private var showAddCreditSheet = false
    @State private var selectedCredit: Credit? = nil
    @State private var selectedFilter: CreditFilter = .onlyCredits
    
    init() {
        let uid = UserDefaults.standard.string(forKey: "userId") ?? "NOUSER"
        _allCredits = Query(
            filter: #Predicate { $0.userId == uid },
            sort: [SortDescriptor(\.dateCreated, order: .reverse)]
        )
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all)
            
            VStack {
                Picker("Фильтр", selection: $selectedFilter) {
                    ForEach(CreditFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)
                
                if filteredCredits.isEmpty {
                    Spacer()
                    Text("Нет записей.\nНажмите «+» чтобы добавить.")
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                } else {
                    List {
                        ForEach(filteredCredits) { credit in
                            Button {
                                selectedCredit = credit
                            } label: {
                                CreditRow(credit: credit)
                                    .contentShape(Rectangle())
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    modelContext.delete(credit)
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
        }
        .navigationTitle("Финансы")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddCreditSheet = true
                } label: {
                    Image(systemName: "plus")
                        .padding(10)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(Circle())
                }
            }
        }
        .sheet(isPresented: $showAddCreditSheet) {
            NavigationStack {
                AddCreditView()
                    .navigationBarTitle("Новый", displayMode: .inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Отмена") {
                                showAddCreditSheet = false
                            }
                        }
                    }
            }
        }
        .sheet(item: $selectedCredit) { credit in
            NavigationStack {
                CreditDetailView(credit: credit)
                    .navigationBarTitle("Детали", displayMode: .inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Закрыть") {
                                selectedCredit = nil
                            }
                        }
                    }
            }
        }
    }
    
    /// Список, в зависимости от выбранного фильтра
    private var filteredCredits: [Credit] {
        switch selectedFilter {
        case .onlyCredits:
            // Не показываем кредиты, у которых выплачено уже >= totalAmount
            return allCredits.filter {
                $0.creditKind == .credit &&
                $0.paidAmount < $0.totalAmount
            }
        case .onlyLoans:
            // Не показываем займы, у которых выплачено уже >= totalAmount
            return allCredits.filter {
                $0.creditKind == .loan &&
                $0.paidAmount < $0.totalAmount
            }
        case .completed:
            // Исполненные — выплачено >= общей суммы (и сама сумма > 0)
            return allCredits.filter {
                $0.paidAmount >= $0.totalAmount && $0.totalAmount > 0
            }
        }
    }
}
