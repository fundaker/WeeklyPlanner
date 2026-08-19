import SwiftUI
import SwiftData

struct TodosView: View {

    @Environment(\.modelContext) private var context
    @Query(sort: \Todo.deadline) private var todos: [Todo]

    @State private var showingAddTodo = false
    @State private var todoToDelete: Todo?
    @State private var showDeleteAlert = false
    @State private var todoToEdit: Todo?

    func deleteTodo(todo: Todo) {
        context.delete(todo)
    }

    var body: some View {
        NavigationStack {
            List {
                if todos.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("Yapılacak yok")
                            .font(.headline)
                        Text("+ butonuna basarak ekleyebilirsin")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    ForEach(todos) { todo in
                        HStack(spacing: 14) {
                            // Kategori ikonu
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(todo.category.color.opacity(0.15))
                                    .frame(width: 44, height: 44)
                                Text(todo.category.emoji)
                                    .font(.title3)
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                Text(todo.title)
                                    .font(.headline)

                                HStack(spacing: 4) {
                                    Image(systemName: "calendar")
                                        .font(.caption2)
                                        .foregroundColor(todo.category.color)
                                    Text(todo.deadline.formatted(date: .long, time: .omitted))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }

                            Spacer()

                            // Kategori etiketi
                            Text(todo.category.label)
                                .font(.caption2.bold())
                                .foregroundColor(todo.category.color)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(todo.category.color.opacity(0.12))
                                )
                        }
                        .padding(.vertical, 4)
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
                    context.insert(newTodo)
                }
            }
            .sheet(item: $todoToEdit) { todo in
                EditTodoView(todo: todo)
            }
            .alert("Silmek istiyor musunuz?", isPresented: $showDeleteAlert) {
                Button("Sil", role: .destructive) {
                    if let todo = todoToDelete {
                        deleteTodo(todo: todo)
                    }
                }
                Button("İptal", role: .cancel) {}
            }
        }
    }
}
