//
//  TodosView.swift
//  WeeklyPlanner
//
//  Created by Funda Aker on 13.03.2026.
//

import SwiftUI

struct TodosView: View {

  
    @State private var showingAddTodo = false
    @State private var todoToDelete: Todo?
    @State private var showDeleteAlert = false
    @State private var todoToEdit: Todo?
    @State private var todos: [Todo] = TodoStorage.load()

    func deleteTodo(todo: Todo) {
        todos.removeAll { $0.id == todo.id }
    }
    var sortedTodos: [Todo] {
        todos.sorted { $0.deadline < $1.deadline }
    }

    var body: some View {

        NavigationStack {

            List {

                ForEach(sortedTodos) { todo in

                    VStack(alignment: .leading) {

                        Text(todo.title)
                            .font(.headline)

                        Text(todo.deadline.formatted(date: .long, time: .omitted))
                            .font(.caption)
                            .foregroundColor(.gray)

                    }

                    .swipeActions {

                        Button(role: .destructive) {

                            todoToDelete = todo
                            showDeleteAlert = true

                        } label: {
                            Label("Sil", systemImage: "trash")
                        }

                        Button {

                            todoToEdit = todo

                        } label: {
                            Label("Düzenle", systemImage: "pencil")
                        }
                        .tint(.blue)

                    }

                }

            }

            .navigationTitle("Yapılacaklar")

            .toolbar {

                Button {

                    showingAddTodo = true

                } label: {

                    Image(systemName: "plus")

                }

            }

            .sheet(isPresented: $showingAddTodo) {

                AddTodoView { newTodo in
                    todos.append(newTodo)
                }

            }
            .sheet(item: $todoToEdit) { todo in

                EditTodoView(todo: todo) { updatedTodo in
                    
                    if let index = todos.firstIndex(where: { $0.id == updatedTodo.id }) {
                        todos[index] = updatedTodo
                    }

                }

            }

            .alert("Silmek istiyor musunuz?", isPresented: $showDeleteAlert) {

                Button("Sil", role: .destructive) {
                    if let todo = todoToDelete {
                        deleteTodo(todo: todo)
                    }
                }

                Button("İptal", role: .cancel) {}

            }
            .onChange(of: todos) {
                TodoStorage.save(todos)
            }

        }

    }

}
