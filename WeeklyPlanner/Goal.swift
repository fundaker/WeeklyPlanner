import Foundation
import SwiftData

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

@Model
final class SubTask {
    var title: String = ""
    var isDone: Bool = false
    /// Kullanıcının girdiği sırayı korumak için — SwiftData ilişki dizilerinin sırası garanti değildir.
    var order: Int = 0
    var goal: Goal?

    init(title: String, isDone: Bool = false, order: Int = 0) {
        self.title = title
        self.isDone = isDone
        self.order = order
    }
}

@Model
final class Goal {
    var title: String = ""
    var deadline: Date = Date()
    var type: GoalType = GoalType.midTerm
    var emoji: String = "🎯"
    var colorHex: String = "7B5EA7"
    var createdAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \SubTask.goal)
    var subTasks: [SubTask] = []

    init(
        title: String,
        deadline: Date,
        type: GoalType,
        emoji: String = "🎯",
        colorHex: String = "7B5EA7",
        subTasks: [SubTask] = [],
        createdAt: Date = Date()
    ) {
        self.title = title
        self.deadline = deadline
        self.type = type
        self.emoji = emoji
        self.colorHex = colorHex
        self.subTasks = subTasks
        self.createdAt = createdAt
    }

    var orderedSubTasks: [SubTask] { subTasks.sorted { $0.order < $1.order } }
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

// MARK: - Taslak tipleri
// Add/Edit ekranları hedef kaydedilene kadar SwiftData'ya dokunmasın diye
// düzenleme sırasında bu değer tipleriyle çalışılır.

struct SubTaskDraft: Identifiable, Equatable {
    var id = UUID()
    var title: String
    var isDone: Bool = false
}

struct GoalDraft {
    var title: String
    var deadline: Date
    var type: GoalType
    var emoji: String
    var colorHex: String
    var subTasks: [SubTaskDraft]
}

extension Goal {
    convenience init(draft: GoalDraft) {
        self.init(
            title: draft.title,
            deadline: draft.deadline,
            type: draft.type,
            emoji: draft.emoji,
            colorHex: draft.colorHex,
            subTasks: draft.subTasks.enumerated().map {
                SubTask(title: $0.element.title, isDone: $0.element.isDone, order: $0.offset)
            }
        )
    }

    var draft: GoalDraft {
        GoalDraft(
            title: title,
            deadline: deadline,
            type: type,
            emoji: emoji,
            colorHex: colorHex,
            subTasks: orderedSubTasks.map { SubTaskDraft(title: $0.title, isDone: $0.isDone) }
        )
    }

    /// Taslaktaki değerleri hedefe uygular; alt görevler baştan kurulur.
    func apply(_ draft: GoalDraft, in context: ModelContext) {
        title = draft.title
        deadline = draft.deadline
        type = draft.type
        emoji = draft.emoji
        colorHex = draft.colorHex

        let previous = subTasks
        subTasks = draft.subTasks.enumerated().map {
            SubTask(title: $0.element.title, isDone: $0.element.isDone, order: $0.offset)
        }
        previous.forEach { context.delete($0) }
    }
}
