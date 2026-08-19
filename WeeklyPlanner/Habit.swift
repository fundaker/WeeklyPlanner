import Foundation
import SwiftData
import SwiftUI

@Model
final class Habit {
    var title: String = ""
    var emoji: String = "⭐"
    var colorHex: String = ""
    /// "yyyy-MM-dd" formatında tamamlanan günler
    var completedDates: [String] = []
    var createdDate: Date = Date()

    init(
        title: String,
        emoji: String,
        colorHex: String,
        completedDates: [String] = [],
        createdDate: Date = Date()
    ) {
        self.title = title
        self.emoji = emoji
        self.colorHex = colorHex
        self.completedDates = completedDates
        self.createdDate = createdDate
    }

    // Belirtilen yıl/ay, habit'in başladığı aydan önce mi?
    func isBeforeCreation(year: Int, month: Int) -> Bool {
        let calendar = Calendar.current
        let createdYear = calendar.component(.year, from: createdDate)
        let createdMonth = calendar.component(.month, from: createdDate)
        return (year, month) < (createdYear, createdMonth)
    }

    // Belirli bir tarihin tamamlanıp tamamlanmadığı
    func isCompleted(on date: Date) -> Bool {
        completedDates.contains(Habit.dateKey(for: date))
    }

    // Belirli bir aydaki tamamlanma sayısı
    func completionCount(year: Int, month: Int) -> Int {
        completedDates.filter { key in
            key.hasPrefix(String(format: "%04d-%02d", year, month))
        }.count
    }

    // Güncel streak
    func currentStreak() -> Int {
        let calendar = Calendar.current
        let done = Set(completedDates)
        var streak = 0
        var date = Date()

        while done.contains(Habit.dateKey(for: date)) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: date) else { break }
            date = previous
        }
        return streak
    }

    func dateKey(for date: Date) -> String { Habit.dateKey(for: date) }

    private static let keyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static func dateKey(for date: Date) -> String {
        keyFormatter.string(from: date)
    }

    var color: Color {
        Color(hex: colorHex) ?? .blue
    }
}

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }

    func toHex() -> String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "%02X%02X%02X",
                      Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
