import SwiftUI

struct TasksView: View {
    @Binding var tasks: [Task]

    @State private var showingAddTask = false
    @State private var alertMessage = ""
    @State private var showConfetti = false

    @State private var taskToDelete: Task?
    @State private var activeAlert: AlertType?
    @State private var draggedTask: Task?

    @State private var editingTaskIndex: Int?

    let days = ["Pazartesi","Salı","Çarşamba","Perşembe","Cuma","Cumartesi","Pazar"]

    func deleteTask(task: Task) {
        tasks.removeAll { $0.id == task.id }
    }

    func triggerHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    var body: some View {
        NavigationStack {

            List {

                if tasks.isEmpty {

                    VStack(spacing: 12) {
                        Image(systemName: "list.bullet.clipboard")
                            .font(.largeTitle)
                            .foregroundColor(.gray)

                        Text("Henüz görev yok")
                            .font(.headline)

                        Text("+ butonuna basarak ekleyebilirsin")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)

                } else {

                    ForEach(days, id: \.self) { day in

                        Section(day) {

                            ForEach(tasks.indices.filter { tasks[$0].day == day }, id: \.self) { index in

                                let task = tasks[index]

                                VStack(alignment: .leading, spacing: 8) {

                                    HStack {

                                        VStack(alignment: .leading) {

                                            Text(task.title)

                                            HStack {

                                                ForEach(0..<task.totalHours, id: \.self) { i in

                                                    VStack {

                                                        Text("\(i + 1)")
                                                            .font(.caption)
                                                            .foregroundColor(.gray)

                                                        Image(systemName: i < task.completedHours ? "checkmark.circle.fill" : "circle")
                                                            .onTapGesture {

                                                                if i < tasks[index].completedHours {
                                                                    tasks[index].completedHours -= 1
                                                                } else if tasks[index].completedHours < tasks[index].totalHours {

                                                                    tasks[index].completedHours += 1
                                                                    tasks[index].completionDates.append(Date())

                                                                    if tasks[index].completedHours == tasks[index].totalHours {

                                                                        alertMessage = "Harika!\n\n\(task.title) tamamlandı!"
                                                                        activeAlert = .success

                                                                        showConfetti = true
                                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                                            showConfetti = false
                                                                        }

                                                                    } else {

                                                                        alertMessage = "Tebrikler!\n\n\(tasks[index].completedHours) saat tamamlandı."
                                                                        activeAlert = .success
                                                                    }
                                                                }
                                                              
                                                            }
                                                    }
                                                }

                                                Text(task.day)
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                        }

                                        Spacer()

                                    VStack(spacing: 8) {

                                                                Button {
                                                                    activeAlert = nil
                                                                    taskToDelete = nil
                                                                    withAnimation {
                                                                        editingTaskIndex = index
                                                                    }
                                                                } label: {
                                                                    Image(systemName: "pencil.circle.fill")
                                                                        .foregroundColor(.blue)
                                                                }

                                                                Button {
                                                                    editingTaskIndex = nil
                                                                    taskToDelete = task
                                                                    activeAlert = .delete
                                                                } label: {
                                                                    Image(systemName: "trash.circle.fill")
                                                                        .foregroundColor(.red)
                                                                }
                                                            }
                                                            .buttonStyle(.borderless)
                                    }

                                    // 🔥 EDIT PANEL
                                    if editingTaskIndex == index {

                                        VStack(spacing: 10) {

                                            TextField("Görev adı", text: $tasks[index].title)
                                                .textFieldStyle(.roundedBorder)

                                            Stepper(
                                                "Saat: \(tasks[index].totalHours)",
                                                value: $tasks[index].totalHours,
                                                in: 1...12
                                            )

                                            Button("Kapat") {
                                                withAnimation {
                                                    editingTaskIndex = nil
                                                }
                                            }
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                        }
                                        .padding(.top, 8)
                                    }
                                }

                                // 🔥 DRAG
                                .onDrag {
                                    draggedTask = task
                                    return NSItemProvider(object: task.id.uuidString as NSString)
                                }

                                // 🔥 DROP
                                .onDrop(of: ["public.text"], isTargeted: nil) { _ in

                                    if let dragged = draggedTask,
                                       let draggedIndex = tasks.firstIndex(where: { $0.id == dragged.id }) {

                                        tasks[draggedIndex].day = day
                                    }

                                    return true
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Haftalık Plan")

            .toolbar {
                Button {
                    showingAddTask = true
                } label: {
                    Image(systemName: "plus")
                }
            }

            .sheet(isPresented: $showingAddTask) {
                AddTaskView { newTask in
                    tasks.append(newTask)
                }
            }

            .overlay {
                if showConfetti {
                    ConfettiView()
                        .allowsHitTesting(false)
                }
            }

            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 80)
            }

            .alert(item: $activeAlert) { type in

                switch type {

                case .success:
                    return Alert(
                        title: Text("🥳 Tebrikler"),
                        message: Text(alertMessage),
                        dismissButton: .cancel(Text("Tamam")) {
                            triggerHaptic()
                        }
                    )

                case .delete:
                    return Alert(
                        title: Text("Görev Sil"),
                        message: Text("Bu görevi silmek istediğinize emin misiniz?"),
                        primaryButton: .destructive(Text("Sil")) {
                            if let task = taskToDelete {
                                deleteTask(task: task)
                            }
                            taskToDelete = nil
                        },
                        secondaryButton: .cancel(Text("İptal")) {
                            taskToDelete = nil
                        }
                    )
                }
            }
        }
    }
}

enum AlertType: Identifiable {
    case success
    case delete

    var id: Int { hashValue }
}
