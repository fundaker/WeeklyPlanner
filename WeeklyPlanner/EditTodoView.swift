//
//  EditTodoView.swift
//  WeeklyPlanner
//
//  Created by Funda Aker on 13.03.2026.
//

import SwiftUI
import SwiftData

struct EditTodoView: View {

    let todo: Todo

    var body: some View {
        TodoFormView(
            heading: "Yapılacağı Düzenle",
            subheading: "Neyi değiştirmek istiyorsun?",
            title: todo.title,
            deadline: todo.deadline,
            category: todo.category
        ) { title, deadline, category in
            todo.title = title
            todo.deadline = deadline
            todo.category = category
        }
    }
}
