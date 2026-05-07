import Foundation

enum HabitStorage {
    private static let key = "habits"

    static func save(_ habits: [Habit]) {
        do {
            let data = try JSONEncoder().encode(habits)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Habit save error:", error)
        }
    }

    static func load() -> [Habit] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        do {
            return try JSONDecoder().decode([Habit].self, from: data)
        } catch {
            print("Habit load error:", error)
            return []
        }
    }
}
