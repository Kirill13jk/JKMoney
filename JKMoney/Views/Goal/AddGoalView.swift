import SwiftUI
import SwiftData

struct AddGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var targetAmount: String = ""
    @State private var selectedCategory: String = goalCategories.first?.title ?? ""
    @State private var selectedCurrency: CurrencyType = .usd
    @State private var customTitle: String = ""
    @State private var comment: String = ""
    
    var body: some View {
        Form {
            Picker("Категория", selection: $selectedCategory) {
                ForEach(goalCategories, id: \.title) { category in
                    Text(category.title).tag(category.title)
                }
            }
            
            if selectedCategory == "Другое" {
                TextField("На что копите?", text: $customTitle)
            }
            
            Picker("Валюта", selection: $selectedCurrency) {
                ForEach(CurrencyType.allCases, id: \.self) { currency in
                    Text(currency.rawValue).tag(currency)
                }
            }
            
            TextField("Сумма, которую хотите накопить", text: $targetAmount)
                .keyboardType(.decimalPad)
                .onChange(of: targetAmount) { oldValue, newValue in
                    DispatchQueue.main.async {
                        let formatted = formatInput(newValue)
                        if formatted != newValue {
                            targetAmount = formatted
                        }
                    }
                }
            
            Section("Комментарий (необязательно)") {
                TextField("Оставьте комментарий", text: $comment, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
            }
        }
        .navigationTitle("Новая цель")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Отмена") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Сохранить") {
                    saveGoal()
                }
                .disabled(!isFormValid)
            }
        }
    }
    
    private var isFormValid: Bool {
        guard let parsedValue = doubleFromFormattedString(targetAmount), parsedValue > 0 else {
            return false
        }
        if selectedCategory == "Другое", customTitle.trimmingCharacters(in: .whitespaces).isEmpty {
            return false
        }
        return true
    }
    
    private func saveGoal() {
        guard let uid = UserDefaults.standard.string(forKey: "userId") else { return }
        guard let amount = doubleFromFormattedString(targetAmount) else { return }
        
        let finalTitle = (selectedCategory == "Другое")
            ? customTitle
            : selectedCategory
        
        let newGoal = Goal(
            title: finalTitle,
            categoryTitle: selectedCategory,
            targetAmount: amount,
            currentAmount: 0.0,
            userId: uid,
            currency: selectedCurrency,
            comment: comment.isEmpty ? nil : comment
        )
        
        modelContext.insert(newGoal)
        try? modelContext.save()
        
        dismiss()
    }
    
    private func doubleFromFormattedString(_ input: String) -> Double? {
        let raw = input.replacingOccurrences(of: " ", with: "")
        return Double(raw)
    }
    
    private func formatInput(_ input: String) -> String {
        let rawString = input.replacingOccurrences(of: " ", with: "")
        guard let rawNumber = Double(rawString) else {
            return input
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = " "
        
        if let result = formatter.string(from: NSNumber(value: rawNumber)) {
            return result
        } else {
            return input
        }
    }
}
