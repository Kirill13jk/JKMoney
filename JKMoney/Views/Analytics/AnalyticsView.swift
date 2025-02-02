import SwiftUI
import Charts
import SwiftData

struct AnalyticsView: View {
    @EnvironmentObject var colorManager: ColorManager
    
    @Query(sort: \Transaction.date, order: .reverse)
    var transactions: [Transaction]
    
    @Query(sort: \Budget.date, order: .reverse)
    var budgets: [Budget]
    
    @State var showDateRangePicker: Bool = false
    @State var selectedPeriod: DatePeriod = .allTime
    @State var customStartDate: Date = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
    @State var customEndDate: Date = Date()
    @State var selectedCurrency: CurrencyType = .usd
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Button {
                    showDateRangePicker.toggle()
                } label: {
                    HStack {
                        Image(systemName: "calendar")
                        Text("Выбрать период")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.3))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                }
                .sheet(isPresented: $showDateRangePicker) {
                    DateRangePickerView(
                        selectedPeriod: $selectedPeriod,
                        customStartDate: $customStartDate,
                        customEndDate: $customEndDate,
                        onApply: { showDateRangePicker = false },
                        onCancel: { showDateRangePicker = false }
                    )
                }
                
                Text("Сравнение по категориям")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.top, 8)
                
                combinedPieCharts
                
                Text("Общая аналитика по валюте")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.top, 16)
                
                Picker("Валюта", selection: $selectedCurrency) {
                    ForEach(CurrencyType.allCases, id: \.self) {
                        Text($0.rawValue).tag($0)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                totalHorizontalBarChart
                    .frame(height: 200)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Аналитика")
        .navigationBarTitleDisplayMode(.inline)
    }
}
