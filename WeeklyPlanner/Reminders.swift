import Foundation
import SwiftData
import UserNotifications

/// Son tarihi gelen yapılacaklar ve hedefler için o sabah hatırlatma kurar.
///
/// Kayıt başına bildirim takip etmek yerine, bekleyen tüm istekler silinip
/// güncel veriden yeniden kuruluyor. Böylece bir kayıt silindiğinde, tarihi
/// değiştiğinde ya da tamamlandığında ayrıca bir şey yapmak gerekmiyor —
/// yeniden kurma sırasında zaten listeye girmiyor.
@MainActor
enum Reminders {

    /// Hatırlatmanın gönderileceği saat.
    static let hour = 9

    /// iOS uygulama başına en fazla 64 bekleyen bildirim tutuyor.
    /// Fazlası sessizce düşer, o yüzden en yakın tarihliler önceliklendiriliyor.
    private static let limit = 64

    /// Sistem iznini ister. İlk açılışta bir kez sorulur; sonraki
    /// çağrılarda kullanıcının verdiği yanıt neyse o döner.
    static func requestAuthorization() async {
        do {
            _ = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound])
        } catch {
            print("Bildirim izni istenemedi:", error)
        }
    }

    /// Bekleyen bildirimleri güncel veriye göre baştan kurar.
    static func refresh(context: ModelContext) async {
        let center = UNUserNotificationCenter.current()

        let status = await center.notificationSettings().authorizationStatus
        guard status == .authorized || status == .provisional else { return }

        center.removeAllPendingNotificationRequests()

        for reminder in pending(in: context).prefix(limit) {
            let content = UNMutableNotificationContent()
            content.title = reminder.title
            content.body = reminder.body
            content.sound = .default

            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: reminder.date
            )
            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            )

            do {
                try await center.add(request)
            } catch {
                print("Hatırlatma kurulamadı (\(reminder.title)):", error)
            }
        }
    }

    // MARK: - Kurulacak hatırlatmalar

    private struct Reminder {
        let date: Date
        let title: String
        let body: String
    }

    private static func pending(in context: ModelContext) -> [Reminder] {
        var reminders: [Reminder] = []

        let todos = (try? context.fetch(FetchDescriptor<Todo>())) ?? []
        for todo in todos where !todo.isCompleted {
            guard let date = morning(of: todo.deadline) else { continue }
            reminders.append(
                Reminder(
                    date: date,
                    title: "Bugün son gün",
                    body: "\(todo.category.emoji) \(todo.title)"
                )
            )
        }

        let goals = (try? context.fetch(FetchDescriptor<Goal>())) ?? []
        for goal in goals where goal.progress < 1 {
            guard let date = morning(of: goal.deadline) else { continue }
            reminders.append(
                Reminder(
                    date: date,
                    title: "Hedefin bugün doluyor",
                    body: "\(goal.emoji) \(goal.title)"
                )
            )
        }

        return reminders.sorted { $0.date < $1.date }
    }

    /// Son tarihin sabahı. O an çoktan geçtiyse hatırlatma kurulmaz.
    private static func morning(of deadline: Date) -> Date? {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: deadline)
        components.hour = hour
        components.minute = 0

        guard let date = calendar.date(from: components), date > Date() else { return nil }
        return date
    }
}
