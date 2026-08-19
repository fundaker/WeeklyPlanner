//
//  EditTodoView.swift
//  WeeklyPlanner
//
//  Created by Funda Aker on 13.03.2026.
//

import SwiftUI
import SwiftData

struct EditTodoView: View {

    @Environment(\.dismiss) var dismiss

    let todo: Todo

    @State private var title: String
    @State private var deadline: Date

    init(todo: Todo) {
        self.todo = todo
        _title = State(initialValue: todo.title)
        _deadline = State(initialValue: todo.deadline)
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

                        todo.title = title
                        todo.deadline = deadline
                        dismiss()

                    }

                }

            }

        }

    }

}
