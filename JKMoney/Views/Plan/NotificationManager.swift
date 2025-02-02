import UserNotifications
import SwiftUI

final class NotificationManager {
    static let shared = NotificationManager()
    
    private init() { }
    
    /// Запрашиваем разрешение на уведомления
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Ошибка при запросе разрешений: \(error.localizedDescription)")
            }
            print(granted ? "Разрешение получено." : "Разрешение отклонено.")
        }
    }
    
    /// Удаляет уведомление по идентификатору
    func removeNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    /// Планирует ежемесячное уведомление для заданного плана
    func scheduleMonthlyNotification(for plan: PlannedExpense, hour: Int = 9, minute: Int = 0) {
        removeNotification(id: plan.id.uuidString)
        
        let content = UNMutableNotificationContent()
        content.title = "Напоминание"
        content.body = "Пора оплатить: \(plan.title). Сумма: \(Int(plan.amount))"
        content.sound = .default
        
        let calendar = Calendar.current
        let dayOfMonth = calendar.component(.day, from: plan.reminderDate)
        
        var dateComponents = DateComponents()
        dateComponents.day = dayOfMonth
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: plan.id.uuidString,
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Ошибка при добавлении уведомления: \(error.localizedDescription)")
            } else {
                print("Уведомление запланировано на \(dayOfMonth) число месяца.")
            }
        }
    }
}
