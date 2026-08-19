import Foundation
import SwiftData
import SwiftUI

@Model
final class Todo {
    var title: String = ""
    var deadline: Date = Date()
    var category: TodoCategory = TodoCategory.general
    var isCompleted: Bool = false
    var createdAt: Date = Date()

    init(
        title: String,
        deadline: Date,
        category: TodoCategory = .general,
        isCompleted: Bool = false,
        createdAt: Date = Date()
    ) {
        self.title = title
        self.deadline = deadline
        self.category = category
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }

    /// Tamamlanmamış ve son tarihi geçmiş.
    var isOverdue: Bool {
        guard !isCompleted else { return false }
        let calendar = Calendar.current
        return calendar.startOfDay(for: deadline) < calendar.startOfDay(for: Date())
    }
}

enum TodoCategory: String, Codable, CaseIterable {
    case general = "Genel"
    case work = "İş"
    case shopping = "Alışveriş"
    case health = "Sağlık"
    case personal = "Kişisel"
    case study = "Eğitim"

    var label: String { rawValue }

    var emoji: String {
        switch self {
        case .general:  return "📌"
        case .work:     return "💼"
        case .shopping: return "🛒"
        case .health:   return "🏃"
        case .personal: return "🌟"
        case .study:    return "📚"
        }
    }

    var icon: String {
        switch self {
        case .general:  return "pin.fill"
        case .work:     return "briefcase.fill"
        case .shopping: return "cart.fill"
        case .health:   return "heart.fill"
        case .personal: return "star.fill"
        case .study:    return "book.fill"
        }
    }

    var color: Color {
        switch self {
        case .general:  return Color(red: 0.45, green: 0.45, blue: 0.90)
        case .work:     return Color(red: 0.20, green: 0.60, blue: 0.90)
        case .shopping: return Color(red: 0.96, green: 0.55, blue: 0.20)
        case .health:   return Color(red: 0.96, green: 0.35, blue: 0.35)
        case .personal: return Color(red: 0.60, green: 0.40, blue: 0.90)
        case .study:    return Color(red: 0.27, green: 0.73, blue: 0.53)
        }
    }
}
