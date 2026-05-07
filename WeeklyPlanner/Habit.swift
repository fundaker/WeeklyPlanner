import Foundation
import SwiftUI

struct Habit: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var emoji: String
    var colorHex: String
    var completedDates: [String] = [] // "yyyy-MM-dd" formatında
    var createdDate: Date = Date()

    // Belirtilen yıl/ay, habit'in başladığı aydan önce mi?
    func isBeforeCreation(year: Int, month: Int) -> Bool {
        let calendar = Calendar.current
        let createdYear = calendar.component(.year, from: createdDate)
        let createdMonth = calendar.component(.month, from: createdDate)
        return (year, month) < (createdYear, createdMonth)
    }

    // Belirli bir tarihin tamamlanıp tamamlanmadığı
    func isCompleted(on date: Date) -> Bool {
        completedDates.contains(dateKey(for: date))
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
        var streak = 0
        var date = Date()

        while true {
            let key = dateKey(for: date)
            if completedDates.contains(key) {
                streak += 1
                date = calendar.date(byAdding: .day, value: -1, to: date)!
            } else {
                break
            }
        }
        return streak
    }

    func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
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
