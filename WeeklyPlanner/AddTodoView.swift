import SwiftUI

struct AddTodoView: View {

    var addTodo: (Todo) -> Void

    var body: some View {
        TodoFormView(
            heading: "Yeni Yapılacak",
            subheading: "Ne yapmayı planlıyorsun?"
        ) { title, deadline, category in
            addTodo(Todo(title: title, deadline: deadline, category: category))
        }
    }
}

#Preview {
    AddTodoView { _ in }
}
