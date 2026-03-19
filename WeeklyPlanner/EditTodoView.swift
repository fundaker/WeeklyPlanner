//
//  EditTodoView.swift
//  WeeklyPlanner
//
//  Created by Funda Aker on 13.03.2026.
//

import SwiftUI

struct EditTodoView: View {

    @Environment(\.dismiss) var dismiss

    @State var title: String
    @State var deadline: Date

    var todoID: UUID
    var updateTodo: (Todo) -> Void

    init(todo: Todo, updateTodo: @escaping (Todo) -> Void) {
        _title = State(initialValue: todo.title)
        _deadline = State(initialValue: todo.deadline)
        todoID = todo.id
        self.updateTodo = updateTodo
    }

    var body: some View {

        NavigationStack {

            Form {

                TextField("Yapılacak şey", text: $title)

                DatePicker(
                    "Son Tarih",
                    selection: $deadline,
                    displayedComponents: .date
                )

            }

            .navigationTitle("Düzenle")

            .toolbar {

                ToolbarItem(placement: .confirmationAction) {

                    Button("Kaydet") {

                        let updatedTodo = Todo(
                            id: todoID,
                            title: title,
                            deadline: deadline
                        )

                        updateTodo(updatedTodo)
                        dismiss()

                    }

                }

            }

        }

    }

}
