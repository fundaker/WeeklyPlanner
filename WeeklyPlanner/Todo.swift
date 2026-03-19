import Foundation

struct Todo: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var deadline: Date

    init(id: UUID = UUID(), title: String, deadline: Date) {
        self.id = id
        self.title = title
        self.deadline = deadline
    }
}
