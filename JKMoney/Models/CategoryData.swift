import SwiftUI

struct CategoryItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
}

// Меняем universalCategoryColor на .blue
private let universalCategoryColor = Color.blue

let incomeCategories: [CategoryItem] = [
    CategoryItem(title: "Работа",   icon: "briefcase.fill", color: universalCategoryColor),
    CategoryItem(title: "Фриланс",  icon: "laptopcomputer", color: universalCategoryColor),
    CategoryItem(title: "Депозит",  icon: "banknote.fill",  color: universalCategoryColor),
    CategoryItem(title: "Другое",   icon: "square.and.pencil", color: universalCategoryColor)
]

let expenseCategories: [CategoryItem] = [
    CategoryItem(title: "Транспорт", icon: "car.fill",        color: universalCategoryColor),
    CategoryItem(title: "Здоровье",  icon: "heart.fill",      color: universalCategoryColor),
    CategoryItem(title: "Дом",       icon: "house.fill",      color: universalCategoryColor),
    CategoryItem(title: "Ремонт",    icon: "wrench.and.screwdriver.fill", color: universalCategoryColor),
    CategoryItem(title: "Еда",       icon: "fork.knife",      color: universalCategoryColor),
    CategoryItem(title: "Другое",    icon: "ellipsis.circle", color: universalCategoryColor)
]

let goalCategories: [CategoryItem] = [
    CategoryItem(title: "Путешествие",    icon: "airplane",         color: universalCategoryColor),
    CategoryItem(title: "Покупка авто",   icon: "car.fill",         color: universalCategoryColor),
    CategoryItem(title: "Образование",    icon: "book.fill",        color: universalCategoryColor),
    CategoryItem(title: "Недвижимость",   icon: "house.fill",       color: universalCategoryColor),
    CategoryItem(title: "Инвестиции",     icon: "chart.bar.fill",   color: universalCategoryColor),
    CategoryItem(title: "Другое",         icon: "ellipsis.circle",  color: universalCategoryColor)
]

let creditCategories: [CategoryItem] = [
    CategoryItem(title: "Банк",        icon: "building.columns.fill",  color: universalCategoryColor),
    CategoryItem(title: "Частное лицо", icon: "person.fill",           color: universalCategoryColor),
    CategoryItem(title: "МФО",         icon: "bag.fill.badge.plus",    color: universalCategoryColor),
    CategoryItem(title: "Другое",      icon: "ellipsis.circle",        color: universalCategoryColor)
]

let budgetCategories: [CategoryItem] = [
    CategoryItem(title: "Депозит", icon: "banknote.fill",  color: universalCategoryColor),
    CategoryItem(title: "Счет",    icon: "creditcard.fill", color: universalCategoryColor),
    CategoryItem(title: "Наличка", icon: "banknote",        color: universalCategoryColor)
]


