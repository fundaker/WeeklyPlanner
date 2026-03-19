import Foundation

struct Task: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var day: String
    var totalHours: Int
    var completedHours: Int = 0
    var streak: Int = 0
    var completionDates: [Date] = []
}
