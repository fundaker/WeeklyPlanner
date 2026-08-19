import Foundation
import SwiftData

enum Persistence {
    static let schema = Schema([
        WeeklyTask.self,
        Todo.self,
        Goal.self,
        SubTask.self,
        Habit.self
    ])

    /// Uygulamanın gerçek (diske yazan) veri kabı.
    static func makeContainer() -> ModelContainer {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: configuration)
        } catch {
            fatalError("ModelContainer oluşturulamadı: \(error)")
        }
    }

    /// Preview'lar için belleğe yazan, diske dokunmayan kap.
    @MainActor
    static let previewContainer: ModelContainer = {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            return try ModelContainer(for: schema, configurations: configuration)
        } catch {
            fatalError("Preview ModelContainer oluşturulamadı: \(error)")
        }
    }()
}
