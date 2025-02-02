import SwiftData
import Foundation

@Model
class PlannedExpense {
    @Attribute(.unique) var id: UUID
    var userId: String
    var dateCreated: Date
    
    var title: String
    var categoryTitle: String
    var amount: Double
    var reminderDate: Date
    var comment: String?
    
    init(
        id: UUID = UUID(),
        userId: String,
        dateCreated: Date = Date(),
        title: String,
        categoryTitle: String,
        amount: Double,
        reminderDate: Date,
        comment: String? = nil
    ) {
        self.id = id
        self.userId = userId
        self.dateCreated = dateCreated
        self.title = title
        self.categoryTitle = categoryTitle
        self.amount = amount
        self.reminderDate = reminderDate
        self.comment = comment
    }
}
