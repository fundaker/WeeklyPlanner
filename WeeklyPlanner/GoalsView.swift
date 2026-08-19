import SwiftUI
import SwiftData

struct GoalsView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Goal.deadline) private var goals: [Goal]

    @State private var selectedType: GoalType = .midTerm
    @State private var showingAddGoal = false
    @State private var goalToDelete: Goal?
    @State private var showDeleteAlert = false
    @State private var goalToEdit: Goal?

    func deleteGoal(goal: Goal) {
        context.delete(goal)
    }

    var filteredGoals: [Goal] {
        goals.filter { $0.type == selectedType }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                VStack(spacing: 0) {
                    // Segment picker
                    Picker("Hedef Türü", selection: $selectedType) {
                        ForEach(GoalType.allCases, id: \.self) { type in
                            Text("\(type.icon) \(type.rawValue)").tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                    if filteredGoals.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Text(selectedType.icon).font(.system(size: 48))
                            Text("Henüz \(selectedType.rawValue.lowercased()) hedef yok")
                                .font(.headline)
                            Text("+ butonuyla yeni hedef ekle")
                                .font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 14) {
                                ForEach(filteredGoals) { goal in
                                    GoalCardView(
                                        goal: goal,
                                        onEdit: { goalToEdit = goal },
                                        onDelete: {
                                            goalToDelete = goal
                                            showDeleteAlert = true
                                        },
                                        onToggleSubTask: { subTask in
                                            subTask.isDone.toggle()
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 4)
                            .padding(.bottom, 100)
                        }
                    }
                }
            }
            .navigationTitle("Hedefler")
            .toolbar {
                Button { showingAddGoal = true } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView(defaultType: selectedType) { draft in
                    context.insert(Goal(draft: draft))
                }
            }
            .sheet(item: $goalToEdit) { goal in
                EditGoalView(goal: goal) { draft in
                    goal.apply(draft, in: context)
                }
            }
            .alert("Hedef Sil", isPresented: $showDeleteAlert) {
                Button("Sil", role: .destructive) {
                    if let goal = goalToDelete { deleteGoal(goal: goal) }
                }
                Button("İptal", role: .cancel) {}
            } message: {
                Text("Bu hedef ve tüm alt görevleri silinecek.")
            }
        }
    }
}

// MARK: - Hedef Kartı
struct GoalCardView: View {
    let goal: Goal
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onToggleSubTask: (SubTask) -> Void

    @State private var expanded = false

    var accentColor: Color { Color(hex: goal.colorHex) ?? .purple }

    var deadlineLabel: some View {
        Group {
            if goal.isOverdue {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill").font(.caption2)
                    Text("Süresi geçti").font(.caption2.bold())
                }
                .foregroundColor(.white)
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background(Capsule().fill(Color.red))
            } else if goal.isUrgent {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill").font(.caption2)
                    Text("\(goal.daysLeft) gün kaldı").font(.caption2.bold())
                }
                .foregroundColor(.white)
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background(Capsule().fill(Color.orange))
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "calendar").font(.caption2)
                    Text("\(goal.daysLeft) gün kaldı").font(.caption2.bold())
                }
                .foregroundColor(accentColor)
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background(Capsule().fill(accentColor.opacity(0.12)))
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Başlık satırı
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Text(goal.emoji).font(.title3)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(goal.title)
                        .font(.system(size: 15, weight: .semibold))
                        .strikethrough(goal.progress >= 1.0, color: .secondary)
                        .foregroundColor(goal.progress >= 1.0 ? .secondary : .primary)

                    Text(goal.deadline.formatted(date: .long, time: .omitted))
                        .font(.caption).foregroundColor(.secondary)
                }

                Spacer()

                Menu {
                    Button { onEdit() } label: { Label("Düzenle", systemImage: "pencil") }
                    Button(role: .destructive) { onDelete() } label: { Label("Sil", systemImage: "trash") }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 28, height: 28)
                        .background(Color(.tertiarySystemFill))
                        .clipShape(Circle())
                }
            }

            // Deadline etiketi
            deadlineLabel

            // İlerleme çubuğu (alt görev varsa)
            if goal.totalSubTasks > 0 {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Alt Görevler")
                            .font(.caption.bold()).foregroundColor(.secondary)
                        Spacer()
                        Text("\(goal.completedSubTasks)/\(goal.totalSubTasks)")
                            .font(.caption.bold()).foregroundColor(accentColor)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.tertiarySystemFill)).frame(height: 6)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(goal.progress >= 1.0 ? Color.green : accentColor)
                                .frame(width: geo.size.width * goal.progress, height: 6)
                                .animation(.spring(response: 0.4), value: goal.progress)
                        }
                    }
                    .frame(height: 6)
                }

                // Alt görev listesi (aç/kapat)
                Button {
                    withAnimation(.spring(response: 0.3)) { expanded.toggle() }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: expanded ? "chevron.up" : "chevron.down")
                            .font(.caption2.bold())
                        Text(expanded ? "Gizle" : "Alt görevleri göster")
                            .font(.caption.bold())
                    }
                    .foregroundColor(accentColor)
                }
                .buttonStyle(.plain)

                if expanded {
                    VStack(spacing: 8) {
                        ForEach(goal.orderedSubTasks) { sub in
                            Button {
                                onToggleSubTask(sub)
                            } label: {
                                HStack(spacing: 10) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(sub.isDone ? accentColor : Color(.tertiarySystemFill))
                                            .frame(width: 20, height: 20)
                                        if sub.isDone {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    Text(sub.title)
                                        .font(.subheadline)
                                        .strikethrough(sub.isDone, color: .secondary)
                                        .foregroundColor(sub.isDone ? .secondary : .primary)
                                    Spacer()
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 4)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }

            // Tamamlandı rozeti
            if goal.progress >= 1.0 {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.seal.fill")
                    Text("Tamamlandı!")
                        .font(.caption.bold())
                }
                .foregroundColor(.green)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            goal.isOverdue ? Color.red.opacity(0.3) :
                            goal.isUrgent ? Color.orange.opacity(0.3) : .clear,
                            lineWidth: 1.5
                        )
                )
        )
    }
}
