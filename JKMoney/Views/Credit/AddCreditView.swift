import SwiftUI
import SwiftData

struct AddCreditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var totalAmount: String = ""
    @State private var selectedCategory: String = creditCategories.first?.title ?? "Другое"
    @State private var selectedCurrency: CurrencyType = .usd
    @State private var customTitle: String = ""
    @State private var comment: String = ""
    @State private var kind: CreditKind = .credit

    var body: some View {
        Form {
            Section("Тип") {
                Picker("Тип долгового обязательства", selection: $kind) {
                    ForEach(CreditKind.allCases, id: \.self) { k in
                        Text(k.rawValue).tag(k)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Section("Категория") {
                Picker("Категория", selection: $selectedCategory) {
                    ForEach(creditCategories, id: \.title) { category in
                        Text(category.title).tag(category.title)
                    }
                }
                if selectedCategory == "Другое" {
                    TextField("Название", text: $customTitle)
                }
            }
            
            Section("Параметры") {
                Picker("Валюта", selection: $selectedCurrency) {
                    ForEach(CurrencyType.allCases, id: \.self) { currency in
                        Text(currency.rawValue).tag(currency)
                    }
                }
                TextField("Общая сумма", text: $totalAmount)
                    .keyboardType(.decimalPad)
                    .onChange(of: totalAmount) { _, newValue in
                        let fmt = formatInput(newValue)
                        if fmt != newValue { totalAmount = fmt }
                    }
            }
            
            Section("Комментарий (необязательно)") {
                TextField("Оставьте комментарий", text: $comment, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
            }
        }
        .navigationTitle("Новый")
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
            comment: comment.isEmpty ? nil : comment,
            creditKind: kind
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
