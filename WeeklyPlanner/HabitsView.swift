import SwiftUI

struct HabitsView: View {
    @State private var habits: [Habit] = HabitStorage.load()
    @State private var showingAddHabit = false
    @State private var habitToEdit: Habit? = nil
    @State private var habitToDelete: Habit? = nil
    @State private var showDeleteAlert = false
    @State private var monthOffset = 0

    var currentDate: Date {
        Calendar.current.date(byAdding: .month, value: monthOffset, to: Date())!
    }

    var currentYear: Int { Calendar.current.component(.year, from: currentDate) }
    var currentMonth: Int { Calendar.current.component(.month, from: currentDate) }

    var daysInMonth: Int {
        let range = Calendar.current.range(of: .day, in: .month, for: currentDate)!
        return range.count
    }

    var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentDate).capitalized
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {

                        // Ay gezgini
                        HStack {
                            Button {
                                withAnimation(.spring(response: 0.3)) { monthOffset -= 1 }
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .frame(width: 36, height: 36)
                                    .background(Color(.secondarySystemGroupedBackground))
                                    .clipShape(Circle())
                            }

                            Spacer()

                            Text(monthTitle)
                                .font(.headline)

                            Spacer()

                            Button {
                                withAnimation(.spring(response: 0.3)) { monthOffset += 1 }
                            } label: {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(monthOffset >= 0 ? .secondary : .primary)
                                    .frame(width: 36, height: 36)
                                    .background(Color(.secondarySystemGroupedBackground))
                                    .clipShape(Circle())
                            }
                            .disabled(monthOffset >= 0)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                        if habits.isEmpty {
                            VStack(spacing: 12) {
                                Text("🌱")
                                    .font(.system(size: 48))
                                Text("Henüz alışkanlık yok")
                                    .font(.headline)
                                Text("+ butonuyla ilk alışkanlığını ekle")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        } else {
                            ForEach($habits) { $habit in
                                HabitCardView(
                                    habit: $habit,
                                    daysInMonth: daysInMonth,
                                    year: currentYear,
                                    month: currentMonth,
                                    onEdit: { habitToEdit = habit },
                                    onDelete: {
                                        habitToDelete = habit
                                        showDeleteAlert = true
                                    },
                                    onChange: { HabitStorage.save(habits) }
                                )
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Alışkanlıklar")
            .toolbar {
                Button {
                    showingAddHabit = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView { newHabit in
                    habits.append(newHabit)
                    HabitStorage.save(habits)
                }
            }
            .sheet(item: $habitToEdit) { habit in
                AddHabitView(habitToEdit: habit) { updated in
                    if let i = habits.firstIndex(where: { $0.id == updated.id }) {
                        habits[i] = updated
                        HabitStorage.save(habits)
                    }
                }
            }
            .alert("Alışkanlığı Sil", isPresented: $showDeleteAlert) {
                Button("Sil", role: .destructive) {
                    if let h = habitToDelete {
                        habits.removeAll { $0.id == h.id }
                        HabitStorage.save(habits)
                    }
                }
                Button("İptal", role: .cancel) {}
            } message: {
                Text("Bu alışkanlık ve tüm geçmişi silinecek.")
            }
        }
    }
}

struct HabitCardView: View {
    @Binding var habit: Habit
    let daysInMonth: Int
    let year: Int
    let month: Int
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onChange: () -> Void

    let columns = Array(repeating: GridItem(.flexible(), spacing: 5), count: 7)

    var completionCount: Int { habit.completionCount(year: year, month: month) }
    var completionPercent: Int { Int(Double(completionCount) / Double(daysInMonth) * 100) }
    var streak: Int { habit.currentStreak() }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            // Başlık satırı
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(habit.color.opacity(0.18))
                        .frame(width: 44, height: 44)
                    Text(habit.emoji)
                        .font(.title3)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(habit.title)
                        .font(.headline)
                        .foregroundColor(habit.color)
                    HStack(spacing: 10) {
                        Label("\(streak) gün seri", systemImage: "flame.fill")
                            .font(.caption)
                            .foregroundColor(streak > 0 ? .orange : .secondary)
                        Text("•")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        Text("%\(completionPercent)")
                            .font(.caption.bold())
                            .foregroundColor(habit.color)
                        Text("tamamlandı")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Menu {
                    Button {
                        onEdit()
                    } label: {
                        Label("Düzenle", systemImage: "pencil")
                    }
                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        Label("Sil", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 32, height: 32)
                        .background(Color(.tertiarySystemFill))
                        .clipShape(Circle())
                }
            }

            // İlerleme çubuğu
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.tertiarySystemFill))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(habit.color)
                        .frame(width: geo.size.width * CGFloat(completionPercent) / 100, height: 6)
                        .animation(.spring(response: 0.4), value: completionPercent)
                }
            }
            .frame(height: 6)

            // Gün kutucukları
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(1...daysInMonth, id: \.self) { day in
                    let date = dateFor(day: day)
                    let done = habit.isCompleted(on: date)
                    let isToday = Calendar.current.isDateInToday(date)
                    let isFuture = date > Date()

                    Button {
                        if !isFuture {
                            let key = habit.dateKey(for: date)
                            withAnimation(.spring(response: 0.2)) {
                                if done {
                                    habit.completedDates.removeAll { $0 == key }
                                } else {
                                    habit.completedDates.append(key)
                                }
                            }
                            onChange()
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(done ? habit.color : Color(.tertiarySystemFill))
                                .frame(height: 30)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .strokeBorder(
                                            isToday ? habit.color : .clear,
                                            lineWidth: 2
                                        )
                                )

                            Text("\(day)")
                                .font(.system(size: 11, weight: done ? .bold : .regular))
                                .foregroundColor(
                                    done ? .white :
                                    isFuture ? Color(.quaternaryLabel) :
                                    isToday ? habit.color :
                                    .secondary
                                )
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(isFuture)
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 18).fill(Color(.secondarySystemGroupedBackground)))
    }

    func dateFor(day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components) ?? Date()
    }
}

