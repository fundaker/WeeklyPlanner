import Foundation
import SwiftData

/// UserDefaults'ta JSON olarak duran eski verileri bir kereye mahsus SwiftData'ya taşır.
///
/// Eski kayıtlar silinmez; taşıma bittiğinde yalnızca bir bayrak yazılır.
/// Böylece bir sorun çıkarsa ham veri hâlâ elde olur.
enum LegacyMigration {

    private static let migratedFlagKey = "didMigrateToSwiftData"

    private enum LegacyKey {
        static let tasks  = "tasks"
        static let todos  = "todos"
        static let goals  = "goals"
        static let habits = "habits"
    }

    // MARK: - Eski JSON şemaları
    // Alanlar optional: bir özellik sonradan eklendiği için eski kayıtlarda
    // bulunmayabilir (ör. priority, category). Eksikse varsayılana düşülür.

    private struct LegacyTask: Decodable {
        var title: String?
        var day: String?
        var totalHours: Int?
        var completedHours: Int?
        var streak: Int?
        var completionDates: [Date]?
        var priority: Priority?
    }

    private struct LegacyTodo: Decodable {
        var title: String?
        var deadline: Date?
        var category: TodoCategory?
    }

    private struct LegacySubTask: Decodable {
        var title: String?
        var isDone: Bool?
    }

    private struct LegacyGoal: Decodable {
        var title: String?
        var deadline: Date?
        var type: GoalType?
        var emoji: String?
        var colorHex: String?
        var subTasks: [LegacySubTask]?
    }

    private struct LegacyHabit: Decodable {
        var title: String?
        var emoji: String?
        var colorHex: String?
        var completedDates: [String]?
        var createdDate: Date?
    }

    // MARK: - Taşıma

    @MainActor
    static func run(context: ModelContext) {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: migratedFlagKey) else { return }

        // Bayrak bir şekilde kaybolduysa verileri ikinci kez eklemeyelim.
        guard isStoreEmpty(context) else {
            defaults.set(true, forKey: migratedFlagKey)
            return
        }

        migrateTasks(from: defaults, into: context)
        migrateTodos(from: defaults, into: context)
        migrateGoals(from: defaults, into: context)
        migrateHabits(from: defaults, into: context)

        do {
            try context.save()
            defaults.set(true, forKey: migratedFlagKey)
        } catch {
            // Kaydedilemediyse bayrağı yazmıyoruz; uygulama bir sonraki açılışta yeniden dener.
            context.rollback()
            print("SwiftData taşıma hatası:", error)
        }
    }

    private static func isStoreEmpty(_ context: ModelContext) -> Bool {
        let counts = [
            (try? context.fetchCount(FetchDescriptor<WeeklyTask>())) ?? 0,
            (try? context.fetchCount(FetchDescriptor<Todo>())) ?? 0,
            (try? context.fetchCount(FetchDescriptor<Goal>())) ?? 0,
            (try? context.fetchCount(FetchDescriptor<Habit>())) ?? 0
        ]
        return counts.allSatisfy { $0 == 0 }
    }

    /// Eski dizideki sırayı korumak için sabit bir başlangıçtan itibaren artan tarih üretir.
    private static func orderDate(_ index: Int) -> Date {
        Date(timeIntervalSince1970: 0).addingTimeInterval(Double(index))
    }

    private static func decode<T: Decodable>(_ type: [T].Type, key: String, from defaults: UserDefaults) -> [T] {
        guard let data = defaults.data(forKey: key) else { return [] }
        do {
            return try JSONDecoder().decode([T].self, from: data)
        } catch {
            print("Eski '\(key)' verisi okunamadı:", error)
            return []
        }
    }

    private static func migrateTasks(from defaults: UserDefaults, into context: ModelContext) {
        for (index, old) in decode([LegacyTask].self, key: LegacyKey.tasks, from: defaults).enumerated() {
            let totalHours = max(old.totalHours ?? 1, 1)
            context.insert(
                WeeklyTask(
                    title: old.title ?? "",
                    day: old.day ?? "",
                    totalHours: totalHours,
                    completedHours: min(old.completedHours ?? 0, totalHours),
                    streak: old.streak ?? 0,
                    completionDates: old.completionDates ?? [],
                    priority: old.priority ?? .medium,
                    createdAt: orderDate(index)
                )
            )
        }
    }

    private static func migrateTodos(from defaults: UserDefaults, into context: ModelContext) {
        for (index, old) in decode([LegacyTodo].self, key: LegacyKey.todos, from: defaults).enumerated() {
            context.insert(
                Todo(
                    title: old.title ?? "",
                    deadline: old.deadline ?? Date(),
                    category: old.category ?? .general,
                    createdAt: orderDate(index)
                )
            )
        }
    }

    private static func migrateGoals(from defaults: UserDefaults, into context: ModelContext) {
        for (index, old) in decode([LegacyGoal].self, key: LegacyKey.goals, from: defaults).enumerated() {
            let subTasks = (old.subTasks ?? []).enumerated().map { position, sub in
                SubTask(title: sub.title ?? "", isDone: sub.isDone ?? false, order: position)
            }
            context.insert(
                Goal(
                    title: old.title ?? "",
                    deadline: old.deadline ?? Date(),
                    type: old.type ?? .midTerm,
                    emoji: old.emoji ?? "🎯",
                    colorHex: old.colorHex ?? "7B5EA7",
                    subTasks: subTasks,
                    createdAt: orderDate(index)
                )
            )
        }
    }

    private static func migrateHabits(from defaults: UserDefaults, into context: ModelContext) {
        for old in decode([LegacyHabit].self, key: LegacyKey.habits, from: defaults) {
            context.insert(
                Habit(
                    title: old.title ?? "",
                    emoji: old.emoji ?? "⭐",
                    colorHex: old.colorHex ?? "",
                    completedDates: old.completedDates ?? [],
                    // createdDate takvim ızgarasını etkilediği için orijinal değer korunur.
                    createdDate: old.createdDate ?? Date()
                )
            )
        }
    }
}
