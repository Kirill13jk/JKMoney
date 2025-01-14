import Foundation

struct CategorySegment: Identifiable {
    let id: String
    let label: String
    let value: Double
    let percentage: Double
    
    init(label: String, value: Double, percentage: Double) {
        self.id = label
        self.label = label
        self.value = value
        self.percentage = percentage
    }
}
