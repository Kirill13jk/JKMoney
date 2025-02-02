import SwiftUI

struct DateRangePickerView: View {
    @Binding var selectedPeriod: DatePeriod
    @Binding var customStartDate: Date
    @Binding var customEndDate: Date
    
    var onApply: () -> Void
    var onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section("Предопределенные периоды") {
                        ForEach(DatePeriod.predefinedCases, id: \.self) { period in
                            Button {
                                selectedPeriod = period
                            } label: {
                                HStack {
                                    Text(period.displayName)
                                    Spacer()
                                    if selectedPeriod == period {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                    
                    Section("Пользовательский период") {
                        Button {
                            selectedPeriod = .custom
                        } label: {
                            HStack {
                                Text("Пользовательский")
                                Spacer()
                                if selectedPeriod == .custom {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        
                        if selectedPeriod == .custom {
                            VStack(alignment: .leading, spacing: 16) {
                                DatePicker("С", selection: $customStartDate, displayedComponents: .date)
                                DatePicker("По", selection: $customEndDate, displayedComponents: .date)
                            }
                            .padding(.vertical)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                Spacer()
            }
            .navigationTitle("Выберите период")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Применить") {
                        onApply()
                    }
                    .disabled(selectedPeriod == .custom && customStartDate > customEndDate)
                }
            }
        }
    }
}
