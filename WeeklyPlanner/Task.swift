import Foundation

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

struct Task: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var day: String
    var totalHours: Int
    var completedHours: Int = 0
    var streak: Int = 0
    var completionDates: [Date] = []
    var priority: Priority = .medium
}
