//
//  AddTodoView.swift
//  WeeklyPlanner
//
//  Created by Funda Aker on 13.03.2026.
//

import SwiftUI

struct AddTodoView: View {

    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var deadline = Date()

    var addTodo: (Todo) -> Void

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

            .navigationTitle("Yeni Yapılacak")

            .toolbar {

                ToolbarItem(placement: .confirmationAction) {

                    Button("Kaydet") {

                        let newTodo = Todo(
                            title: title,
                            deadline: deadline
                        )

                        addTodo(newTodo)
                        dismiss()

                    }

                }

            }

        }

    }

}
