import SwiftUI
import SwiftData

struct AddCreditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var totalAmount: String = ""
    @State private var selectedCategory: String = "Другое"
    @State private var selectedCurrency: CurrencyType = .usd
    @State private var customTitle: String = ""
    @State private var comment: String = ""

    var body: some View {
        Form {
            Picker("Категория", selection: $selectedCategory) {
                // Можете завести свой массив категорий для кредитов
                // или использовать goalCategories
                ForEach(goalCategories, id: \.title) { category in
                    Text(category.title).tag(category.title)
                }
            }
            if selectedCategory == "Другое" {
                TextField("Название кредита", text: $customTitle)
            }
            Picker("Валюта", selection: $selectedCurrency) {
                ForEach(CurrencyType.allCases, id: \.self) { currency in
                    Text(currency.rawValue).tag(currency)
                }
            }
            TextField("Общая сумма кредита", text: $totalAmount)
                .keyboardType(.decimalPad)
                .onChange(of: totalAmount) { oldValue, newValue in
                    let fmt = formatInput(newValue)
                    if fmt != newValue { totalAmount = fmt }
                }
            Section("Комментарий (необязательно)") {
                TextField("Оставьте комментарий", text: $comment, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
            }
        }
        .navigationTitle("Новый кредит")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Сохранить") { saveCredit() }
                    .disabled(!isFormValid)
            }
        }
    }
    
    private var isFormValid: Bool {
        guard let val = parseFormatted(totalAmount), val > 0 else { return false }
        if selectedCategory == "Другое", customTitle.trimmingCharacters(in: .whitespaces).isEmpty {
            return false
        }
        return true
    }
    
    private func saveCredit() {
        guard let uid = UserDefaults.standard.string(forKey: "userId") else { return }
        guard let val = parseFormatted(totalAmount) else { return }
        
        let finalTitle = (selectedCategory == "Другое") ? customTitle : selectedCategory
        
        let newCredit = Credit(
            title: finalTitle,
            categoryTitle: selectedCategory,
            totalAmount: val,
            paidAmount: 0.0,
            userId: uid,
            currency: selectedCurrency,
            comment: comment.isEmpty ? nil : comment
        )
        modelContext.insert(newCredit)
        try? modelContext.save()
        dismiss()
    }
    
    private func parseFormatted(_ input: String) -> Double? {
        let raw = input.replacingOccurrences(of: " ", with: "")
        return Double(raw)
    }
    
    private func formatInput(_ input: String) -> String {
        let rawString = input.replacingOccurrences(of: " ", with: "")
        guard let rawNumber = Double(rawString) else { return input }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = " "
        return formatter.string(from: NSNumber(value: rawNumber)) ?? input
    }
}
