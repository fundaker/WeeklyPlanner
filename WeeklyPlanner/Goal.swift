import Foundation

enum GoalType: String, CaseIterable, Codable {
    case midTerm = "Orta Vadeli"
    case longTerm = "Uzun Vadeli"

    var icon: String {
        switch self {
        case .midTerm:  return "🗓"
        case .longTerm: return "🎯"
        }
    }

    var colorHex: String {
        switch self {
        case .midTerm:  return "4A90D9"
        case .longTerm: return "7B5EA7"
        }
    }
}

struct SubTask: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var isDone: Bool = false
}

struct Goal: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var deadline: Date
    var type: GoalType
    var emoji: String = "🎯"
    var colorHex: String = "7B5EA7"
    var subTasks: [SubTask] = []

    var completedSubTasks: Int { subTasks.filter { $0.isDone }.count }
    var totalSubTasks: Int { subTasks.count }
    var progress: Double {
        guard totalSubTasks > 0 else { return 0 }
        return Double(completedSubTasks) / Double(totalSubTasks)
    }

    var daysLeft: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.startOfDay(for: deadline)
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }

    var isOverdue: Bool { daysLeft < 0 }
    var isUrgent: Bool { daysLeft >= 0 && daysLeft <= 7 }
}
