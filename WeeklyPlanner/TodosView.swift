import SwiftUI
import SwiftData

struct TodosView: View {

    @Environment(\.modelContext) private var context
    @Query(sort: \Todo.deadline) private var todos: [Todo]

    @State private var showingAddTodo = false
    @State private var todoToDelete: Todo?
    @State private var showDeleteAlert = false
    @State private var todoToEdit: Todo?

    private var openTodos: [Todo] { todos.filter { !$0.isCompleted } }
    private var completedTodos: [Todo] { todos.filter(\.isCompleted) }

    func deleteTodo(todo: Todo) {
        context.delete(todo)
    }

    func toggleCompletion(_ todo: Todo) {
        withAnimation(.spring(response: 0.35)) {
            todo.isCompleted.toggle()
        }
        UIImpactFeedbackGenerator(style: todo.isCompleted ? .medium : .light)
            .impactOccurred()
    }

    var body: some View {
        NavigationStack {
            List {
                if todos.isEmpty {
                    emptyState
                } else {
                    if !openTodos.isEmpty {
                        Section {
                            ForEach(openTodos) { todo in
                                row(for: todo)
                            }
                        } header: {
                            Text("Yapılacaklar (\(openTodos.count))")
                        }
                    }

                    if !completedTodos.isEmpty {
                        Section {
                            ForEach(completedTodos) { todo in
                                row(for: todo)
                            }
                        } header: {
                            Text("Tamamlananlar (\(completedTodos.count))")
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

    private var emptyState: some View {
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
    }

    @ViewBuilder
    private func row(for todo: Todo) -> some View {
        HStack(spacing: 14) {
            // Tamamlama kutusu
            Button {
                toggleCompletion(todo)
            } label: {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(todo.isCompleted ? todo.category.color : .secondary.opacity(0.5))
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            // Satırın tamamı düzenlemeye gitmesin diye dokunma alanı kutuyla sınırlı.
            .accessibilityLabel(todo.isCompleted ? "Tamamlandı olarak işaretlendi" : "Tamamlandı olarak işaretle")

            VStack(alignment: .leading, spacing: 3) {
                Text(todo.title)
                    .font(.headline)
                    .strikethrough(todo.isCompleted, color: .secondary)
                    .foregroundColor(todo.isCompleted ? .secondary : .primary)

                HStack(spacing: 4) {
                    Image(systemName: todo.isOverdue ? "exclamationmark.triangle.fill" : "calendar")
                        .font(.caption2)
                        .foregroundColor(todo.isOverdue ? .red : todo.category.color)
                    Text(todo.deadline.formatted(date: .long, time: .omitted))
                        .font(.caption)
                        .foregroundColor(todo.isOverdue ? .red : .secondary)
                }
            }

            Spacer()

            // Kategori etiketi
            HStack(spacing: 4) {
                Text(todo.category.emoji)
                    .font(.caption2)
                Text(todo.category.label)
                    .font(.caption2.bold())
                    .foregroundColor(todo.category.color)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(todo.category.color.opacity(0.12))
            )
        }
        .padding(.vertical, 4)
        .opacity(todo.isCompleted ? 0.6 : 1)
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

#Preview {
    TodosView()
        .modelContainer(Persistence.previewContainer)
}
