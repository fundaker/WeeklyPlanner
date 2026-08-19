import Foundation
import SwiftData

enum Priority: String, Codable, CaseIterable {
    case low = "Düşük"
    case medium = "Orta"
    case high = "Yüksek"

    var icon: String {
        switch self {
        case .low: return "⬇️"
        case .medium: return "➡️"
        case .high: return "⬆️"
        }
    }

    var color: String {
        switch self {
        case .low: return "priorityLow"
        case .medium: return "priorityMedium"
        case .high: return "priorityHigh"
        }
    }
}

/// Haftalık plandaki tek bir görev.
/// Not: Swift Concurrency'nin `Task` tipiyle çakışmaması için `WeeklyTask` adını taşır.
@Model
final class WeeklyTask {
    var title: String = ""
    var day: String = ""
    var totalHours: Int = 1
    var completedHours: Int = 0
    var streak: Int = 0
    var completionDates: [Date] = []
    var priority: Priority = Priority.medium
    /// Listede kararlı bir sıralama için kullanılır.
    var createdAt: Date = Date()

    init(
        title: String,
        day: String,
        totalHours: Int,
        completedHours: Int = 0,
        streak: Int = 0,
        completionDates: [Date] = [],
        priority: Priority = .medium,
        createdAt: Date = Date()
    ) {
        self.title = title
        self.day = day
        self.totalHours = totalHours
        self.completedHours = completedHours
        self.streak = streak
        self.completionDates = completionDates
        self.priority = priority
        self.createdAt = createdAt
    }

    var isCompleted: Bool { totalHours > 0 && completedHours >= totalHours }
}
