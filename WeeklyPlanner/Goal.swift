import Foundation

enum GoalType: String, CaseIterable, Codable {
    case longTerm = "Uzun Vadeli"
    case midTerm = "Orta Vadeli"
}

struct Goal: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var deadline: Date
    var type: GoalType
}
