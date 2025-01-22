import SwiftUI
import SwiftData

struct CreditSubView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allCredits: [Credit]
    
    @State private var showAddCreditSheet = false
    @State private var selectedCredit: Credit? = nil
    
    init() {
        let uid = UserDefaults.standard.string(forKey: "userId") ?? "NOUSER"
        _allCredits = Query(
            filter: #Predicate { $0.userId == uid },
            sort: [SortDescriptor(\.dateCreated, order: .reverse)]
        )
    }
    
    var body: some View {
        VStack {
            if allCredits.isEmpty {
                Spacer()
                Text("Нет кредитов.\nНажмите «+» чтобы добавить.")
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            } else {
                List {
                    ForEach(allCredits) { credit in
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
                    .navigationBarTitle("Новый кредит", displayMode: .inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Отмена") {
                                showAddCreditSheet = false
                            }
                        }
                    }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $selectedCredit) { credit in
            NavigationStack {
                CreditDetailView(credit: credit)
                    .navigationBarTitle("Детали кредита", displayMode: .inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Закрыть") {
                                selectedCredit = nil
                            }
                        }
                    }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}
