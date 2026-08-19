import SwiftUI
import SwiftData

struct TasksView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \WeeklyTask.createdAt) private var tasks: [WeeklyTask]

    @State private var showingAddTask = false
    @State private var alertMessage = ""
    @State private var showConfetti = false
    @State private var taskToDelete: WeeklyTask?
    @State private var activeAlert: AlertType?
    @State private var editingTaskID: PersistentIdentifier?
    @State private var showPostponeSheet: WeeklyTask? = nil

    let days = ["Pazartesi","Salı","Çarşamba","Perşembe","Cuma","Cumartesi","Pazar"]

    var todayName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "EEEE"
        let raw = formatter.string(from: Date())
        let map: [String: String] = [
            "pazartesi": "Pazartesi", "salı": "Salı", "çarşamba": "Çarşamba",
            "perşembe": "Perşembe", "cuma": "Cuma", "cumartesi": "Cumartesi", "pazar": "Pazar"
        ]
        return map[raw.lowercased()] ?? raw
    }

    var todayIndex: Int { days.firstIndex(of: todayName) ?? 0 }

    func isPast(day: String) -> Bool {
        guard let idx = days.firstIndex(of: day) else { return false }
        return idx < todayIndex
    }

    func futureDays(from day: String) -> [String] {
        guard let idx = days.firstIndex(of: day) else { return [] }
        return Array(days[(idx + 1)...])
    }

    func allDone(for day: String) -> Bool {
        let dayTasks = tasks.filter { $0.day == day }
        guard !dayTasks.isEmpty else { return false }
        return dayTasks.allSatisfy { $0.isCompleted }
    }

    func deleteTask(task: WeeklyTask) {
        if editingTaskID == task.persistentModelID { editingTaskID = nil }
        context.delete(task)
    }

    func triggerHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    // Bugün en üstte, sonra diğer günler sırayla
    var orderedDays: [String] {
        let before = Array(days[..<todayIndex])
        let todayAndAfter = Array(days[todayIndex...])
        return todayAndAfter + before
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(orderedDays, id: \.self) { day in
                        let dayTasks = tasks.filter { $0.day == day }
                        let isToday = day == todayName
                        let past = isPast(day: day)

                        if !dayTasks.isEmpty || isToday {
                            DaySectionView(
                                day: day,
                                isToday: isToday,
                                isPast: past,
                                isDone: allDone(for: day),
                                dayTasks: dayTasks,
                                editingTaskID: $editingTaskID,
                                taskToDelete: $taskToDelete,
                                activeAlert: $activeAlert,
                                alertMessage: $alertMessage,
                                showConfetti: $showConfetti,
                                showPostponeSheet: $showPostponeSheet,
                                days: days,
                                futureDays: futureDays(from: day),
                                onTriggerHaptic: triggerHaptic
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Haftalık Plan")
        .toolbar {
            Button { showingAddTask = true } label: {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView(todayIndex: todayIndex, days: days) { newTask in
                context.insert(newTask)
            }
        }
        .sheet(item: $showPostponeSheet) { task in
            PostponeSheetView(
                task: task,
                futureDays: futureDays(from: task.day)
            ) { newDay in
                task.day = newDay
            }
        }
        .overlay {
            if showConfetti { ConfettiView().allowsHitTesting(false) }
        }
        .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 80) }
        .alert(item: $activeAlert) { type in
            switch type {
            case .success:
                return Alert(
                    title: Text("🥳 Tebrikler"),
                    message: Text(alertMessage),
                    dismissButton: .cancel(Text("Tamam")) { triggerHaptic() }
                )
            case .delete:
                return Alert(
                    title: Text("Görev Sil"),
                    message: Text("Bu görevi silmek istediğinize emin misiniz?"),
                    primaryButton: .destructive(Text("Sil")) {
                        if let task = taskToDelete { deleteTask(task: task) }
                        taskToDelete = nil
                    },
                    secondaryButton: .cancel(Text("İptal")) { taskToDelete = nil }
                )
            }
        }
    }
}

// MARK: - Gün Bölümü
struct DaySectionView: View {
    let day: String
    let isToday: Bool
    let isPast: Bool
    let isDone: Bool
    let dayTasks: [WeeklyTask]
    @Binding var editingTaskID: PersistentIdentifier?
    @Binding var taskToDelete: WeeklyTask?
    @Binding var activeAlert: AlertType?
    @Binding var alertMessage: String
    @Binding var showConfetti: Bool
    @Binding var showPostponeSheet: WeeklyTask?
    let days: [String]
    let futureDays: [String]
    let onTriggerHaptic: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Gün başlığı
            HStack(spacing: 8) {
                Text(day)
                    .font(.system(size: 15, weight: isToday ? .bold : .semibold))
                    .foregroundColor(isToday ? .blue : (isPast ? .secondary : .primary))

                if isToday {
                    Text("BUGÜN")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Capsule().fill(Color.blue))
                }

                if isDone && !dayTasks.isEmpty {
                    Text("✅ Tamamlandı")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Capsule().fill(Color.green))
                }

                Spacer()

                if !dayTasks.isEmpty {
                    let total = dayTasks.reduce(0) { $0 + $1.totalHours }
                    let completed = dayTasks.reduce(0) { $0 + $1.completedHours }
                    Text("\(completed)/\(total) saat")
                        .font(.caption2).foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 4)

            if dayTasks.isEmpty && isToday {
                HStack {
                    Spacer()
                    VStack(spacing: 6) {
                        Image(systemName: "sun.max").font(.title2).foregroundColor(.yellow)
                        Text("Bugün için görev yok").font(.caption).foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 20)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemGroupedBackground)))
            } else {
                ForEach(dayTasks) { task in
                    TaskCardView(
                        task: task,
                        editingTaskID: $editingTaskID,
                        taskToDelete: $taskToDelete,
                        activeAlert: $activeAlert,
                        alertMessage: $alertMessage,
                        showConfetti: $showConfetti,
                        showPostponeSheet: $showPostponeSheet,
                        isPast: isPast,
                        isToday: isToday,
                        canPostpone: !futureDays.isEmpty,
                        days: days,
                        onTriggerHaptic: onTriggerHaptic
                    )
                }
            }
        }
    }
}

// MARK: - Görev Kartı
struct TaskCardView: View {
    @Bindable var task: WeeklyTask
    @Binding var editingTaskID: PersistentIdentifier?
    @Binding var taskToDelete: WeeklyTask?
    @Binding var activeAlert: AlertType?
    @Binding var alertMessage: String
    @Binding var showConfetti: Bool
    @Binding var showPostponeSheet: WeeklyTask?
    let isPast: Bool
    let isToday: Bool
    let canPostpone: Bool
    let days: [String]
    let onTriggerHaptic: () -> Void

    var isCompleted: Bool { task.isCompleted }
    var isOverdue: Bool { isPast && !isCompleted }
    var isEditing: Bool { editingTaskID == task.persistentModelID }

    var priorityColor: Color {
        switch task.priority {
        case .low:    return Color(red: 0.27, green: 0.73, blue: 0.53)
        case .medium: return Color(red: 0.98, green: 0.72, blue: 0.20)
        case .high:   return Color(red: 0.96, green: 0.35, blue: 0.35)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                // Öncelik çizgisi
                RoundedRectangle(cornerRadius: 3)
                    .fill(isOverdue ? Color.red : priorityColor)
                    .frame(width: 4, height: 70)

                VStack(alignment: .leading, spacing: 6) {
                    // Başlık + uyarı
                    HStack {
                        Text(task.title)
                            .font(.system(size: 15, weight: .semibold))
                            .strikethrough(isCompleted, color: .secondary)
                            .foregroundColor(isCompleted ? .secondary : .primary)

                        Spacer()

                        if isOverdue {
                            HStack(spacing: 3) {
                                Image(systemName: "exclamationmark.triangle.fill").font(.caption2)
                                Text("Yapılmadı").font(.caption2.bold())
                            }
                            .foregroundColor(.red)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Capsule().fill(Color.red.opacity(0.12)))
                        } else if isCompleted {
                            Image(systemName: "checkmark.seal.fill").foregroundColor(.green)
                        }
                    }

                    // İlerleme çubuğu
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.tertiarySystemFill)).frame(height: 6)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(isOverdue ? Color.red : priorityColor)
                                .frame(
                                    width: geo.size.width * CGFloat(task.completedHours) / CGFloat(max(task.totalHours, 1)),
                                    height: 6
                                )
                                .animation(.spring(response: 0.3), value: task.completedHours)
                        }
                    }
                    .frame(height: 6)

                    // Saat kutucukları
                    HStack(spacing: 6) {
                        ForEach(0..<task.totalHours, id: \.self) { i in
                            let done = i < task.completedHours
                            Button {
                                if i < task.completedHours {
                                    task.completedHours -= 1
                                    if !task.completionDates.isEmpty {
                                        task.completionDates.removeLast()
                                    }
                                } else if task.completedHours < task.totalHours {
                                    task.completedHours += 1
                                    task.completionDates.append(Date())
                                    if task.completedHours == task.totalHours {
                                        alertMessage = "Harika!\n\n\(task.title) tamamlandı! 🎉"
                                        activeAlert = .success
                                        showConfetti = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { showConfetti = false }
                                    } else {
                                        alertMessage = "Tebrikler!\n\n\(task.completedHours) saat tamamlandı."
                                        activeAlert = .success
                                    }
                                }
                            } label: {
                                VStack(spacing: 2) {
                                    Text("\(i + 1)").font(.system(size: 9)).foregroundColor(done ? priorityColor : .secondary)
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(done ? priorityColor : Color(.tertiarySystemFill))
                                        .frame(width: 22, height: 22)
                                        .overlay(
                                            Image(systemName: done ? "checkmark" : "")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(.white)
                                        )
                                }
                            }
                            .buttonStyle(.plain)
                        }

                        Spacer()
                        Text("\(task.completedHours)/\(task.totalHours) saat")
                            .font(.caption2).foregroundColor(.secondary)
                    }
                }
            }

            // Aksiyon butonları
            HStack(spacing: 8) {
                Button {
                    withAnimation { editingTaskID = isEditing ? nil : task.persistentModelID }
                } label: {
                    Label("Düzenle", systemImage: "pencil")
                        .font(.caption.bold()).foregroundColor(.blue)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Capsule().fill(Color.blue.opacity(0.1)))
                }
                .buttonStyle(.plain)

                if (isPast || isToday) && canPostpone && !isCompleted {
                    Button {
                        showPostponeSheet = task
                    } label: {
                        Label("Ertele", systemImage: "arrow.right.circle")
                            .font(.caption.bold()).foregroundColor(.orange)
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(Capsule().fill(Color.orange.opacity(0.1)))
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                Button {
                    editingTaskID = nil
                    taskToDelete = task
                    activeAlert = .delete
                } label: {
                    Image(systemName: "trash")
                        .font(.caption.bold()).foregroundColor(.red)
                        .padding(6)
                        .background(Circle().fill(Color.red.opacity(0.1)))
                }
                .buttonStyle(.plain)
            }

            // Düzenleme paneli
            if isEditing {
                VStack(spacing: 10) {
                    Divider()
                    TextField("Görev adı", text: $task.title).textFieldStyle(.roundedBorder)
                    Stepper("Saat: \(task.totalHours)", value: $task.totalHours, in: 1...12)
                        .onChange(of: task.totalHours) {
                            if task.completedHours > task.totalHours {
                                task.completedHours = task.totalHours
                            }
                        }
                    Picker("Gün", selection: $task.day) {
                        ForEach(days, id: \.self) { d in Text(d).tag(d) }
                    }
                    .pickerStyle(.menu)
                    Button("Kapat") { withAnimation { editingTaskID = nil } }
                        .font(.caption).foregroundColor(.blue)
                }
                .padding(.top, 4)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(isOverdue ? Color.red.opacity(0.3) : .clear, lineWidth: 1.5)
                )
        )
    }
}

// MARK: - Erteleme Sheet
struct PostponeSheetView: View {
    let task: WeeklyTask
    let futureDays: [String]
    let onPostpone: (String) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                VStack(spacing: 20) {
                    VStack(spacing: 6) {
                        ZStack {
                            Circle().fill(Color.orange.opacity(0.15)).frame(width: 64, height: 64)
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 30)).foregroundColor(.orange)
                        }
                        Text("Görevi Ertele").font(.title2.bold())
                        Text("\"\(task.title)\" hangi güne taşınsın?")
                            .font(.subheadline).foregroundColor(.secondary).multilineTextAlignment(.center)
                    }
                    .padding(.top, 16)

                    VStack(spacing: 10) {
                        ForEach(futureDays, id: \.self) { day in
                            Button {
                                onPostpone(day)
                                dismiss()
                            } label: {
                                HStack {
                                    Image(systemName: "calendar").foregroundColor(.orange)
                                    Text(day).font(.body.bold()).foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundColor(.secondary).font(.caption)
                                }
                                .padding(14)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") { dismiss() }.foregroundColor(.secondary)
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
