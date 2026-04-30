import Foundation

struct Todo: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var deadline: Date
    var category: TodoCategory

    init(id: UUID = UUID(), title: String, deadline: Date, category: TodoCategory = .general) {
        self.id = id
        self.title = title
        self.deadline = deadline
        self.category = category
    }
}
