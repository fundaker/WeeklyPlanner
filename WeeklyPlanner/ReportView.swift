import SwiftUI
import Charts

struct ReportView: View {
    var tasks: [Task]

    @State private var habits: [Habit] = HabitStorage.load()
    @State private var goals: [Goal] = GoalStorage.load()
    @State private var selectedReportType: ReportType = .weekly
    @State private var selectedWeekOffset = 0
    @State private var selectedMonthOffset = 0

    // MARK: - Tarih aralıkları
    func weekRange(offset: Int) -> (start: Date, end: Date) {
        let cal = Calendar.current
        let currentWeek = cal.dateInterval(of: .weekOfYear, for: Date())!
        let start = cal.date(byAdding: .weekOfYear, value: offset, to: currentWeek.start)!
        let end = cal.date(byAdding: .day, value: 6, to: start)!
        return (start, end)
    }

    func monthRange(offset: Int) -> (start: Date, end: Date) {
        let cal = Calendar.current
        let currentMonth = cal.dateInterval(of: .month, for: Date())!
        let start = cal.date(byAdding: .month, value: offset, to: currentMonth.start)!
        let end = cal.date(byAdding: .day, value: -1, to: cal.date(byAdding: .month, value: 1, to: start)!)!
        return (start, end)
    }

    func weekTitle() -> String {
        let range = weekRange(offset: selectedWeekOffset)
        let f = DateFormatter(); f.dateFormat = "d MMM"
        return "\(f.string(from: range.start)) – \(f.string(from: range.end))"
    }

    func monthTitle() -> String {
        let range = monthRange(offset: selectedMonthOffset)
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "MMMM yyyy"
        return f.string(from: range.start).capitalized
    }

    var periodTitle: String {
        selectedReportType == .weekly ? weekTitle() : monthTitle()
    }

    // MARK: - Görev verileri
    var taskReportData: [String: Int] {
        let range = selectedReportType == .weekly
            ? weekRange(offset: selectedWeekOffset)
            : monthRange(offset: selectedMonthOffset)
        var result: [String: Int] = [:]
        for task in tasks {
            let count = task.completionDates.filter { $0 >= range.start && $0 <= range.end }.count
            if count > 0 { result[task.title, default: 0] += count }
        }
        return result
    }

    var totalTaskHours: Int { taskReportData.values.reduce(0, +) }

    // MARK: - Alışkanlık verileri
    func habitCount(for habit: Habit) -> Int {
        if selectedReportType == .weekly {
            let range = weekRange(offset: selectedWeekOffset)
            return habit.completedDates.filter { key in
                let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
                if let d = f.date(from: key) { return d >= range.start && d <= range.end }
                return false
            }.count
        } else {
            let cal = Calendar.current
            let start = monthRange(offset: selectedMonthOffset).start
            return habit.completionCount(
                year: cal.component(.year, from: start),
                month: cal.component(.month, from: start)
            )
        }
    }

    var daysInPeriod: Int {
        if selectedReportType == .weekly { return 7 }
        let cal = Calendar.current
        let start = monthRange(offset: selectedMonthOffset).start
        return cal.range(of: .day, in: .month, for: start)?.count ?? 30
    }

    var activeHabitCount: Int {
        habits.filter { habitCount(for: $0) > 0 }.count
    }

    var completedGoalCount: Int {
        goals.filter { $0.progress >= 1.0 }.count
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    periodPickerView
                    summaryCardsView
                    taskSectionView
                    habitSectionView
                    goalSectionView
                }
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Raporlar")
    }

    // MARK: - Dönem seçici
    var periodPickerView: some View {
        VStack(spacing: 12) {
            Picker("Rapor Türü", selection: $selectedReportType) {
                ForEach(ReportType.allCases, id: \.self) { Text($0.rawValue) }
            }
            .pickerStyle(.segmented)

            HStack {
                Button {
                    withAnimation {
                        if selectedReportType == .weekly { selectedWeekOffset -= 1 }
                        else { selectedMonthOffset -= 1 }
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(width: 32, height: 32)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(Circle())
                }

                Spacer()
                Text(periodTitle).font(.headline)
                Spacer()

                Button {
                    withAnimation {
                        if selectedReportType == .weekly { selectedWeekOffset += 1 }
                        else { selectedMonthOffset += 1 }
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(width: 32, height: 32)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    // MARK: - Özet kartları
    var summaryCardsView: some View {
        HStack(spacing: 12) {
            summaryCard(icon: "clock.fill", color: .blue, value: "\(totalTaskHours)", label: "Toplam Saat")
            summaryCard(icon: "checkmark.seal.fill", color: .green, value: "\(activeHabitCount)", label: "Aktif Alışkanlık")
            summaryCard(icon: "target", color: .purple, value: "\(completedGoalCount)/\(goals.count)", label: "Hedef")
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Görev bölümü
    var taskSectionView: some View {
        reportCard(title: "Görev Saatleri", icon: "checklist", color: .blue) {
            if taskReportData.isEmpty {
                emptyState(text: "Bu dönemde tamamlanan görev yok")
            } else {
                VStack(spacing: 12) {
                    taskChartView
                    taskRankingView
                }
            }
        }
    }

    @ViewBuilder
    var taskChartView: some View {
        if selectedReportType == .weekly {
            Chart {
                ForEach(taskReportData.keys.sorted(), id: \.self) { key in
                    if let value = taskReportData[key] {
                        SectorMark(angle: .value("Saat", value))
                            .foregroundStyle(by: .value("Görev", key))
                    }
                }
            }
            .frame(height: 220)
        } else {
            Chart {
                ForEach(taskReportData.keys.sorted(), id: \.self) { key in
                    if let value = taskReportData[key] {
                        BarMark(
                            x: .value("Görev", String(key.prefix(8))),
                            y: .value("Saat", value)
                        )
                        .foregroundStyle(by: .value("Görev", key))
                        .cornerRadius(6)
                    }
                }
            }
            .frame(height: 220)
        }
    }

    var taskRankingView: some View {
        let sorted = taskReportData.sorted { $0.value > $1.value }
        return VStack(spacing: 8) {
            ForEach(Array(sorted.enumerated()), id: \.element.key) { i, item in
                HStack {
                    Text(i == 0 ? "🥇" : i == 1 ? "🥈" : i == 2 ? "🥉" : "   ")
                    Text(item.key).font(.subheadline)
                    Spacer()
                    Text("\(item.value) saat")
                        .font(.subheadline.bold())
                        .foregroundColor(.blue)
                }
                if i < sorted.count - 1 { Divider() }
            }
        }
    }

    // MARK: - Alışkanlık bölümü
    var habitSectionView: some View {
        reportCard(title: "Alışkanlıklar", icon: "checkmark.seal", color: .green) {
            if habits.isEmpty {
                emptyState(text: "Henüz alışkanlık eklenmedi")
            } else {
                VStack(spacing: 12) {
                    ForEach(habits) { habit in
                        HabitRowView(
                            habit: habit,
                            count: habitCount(for: habit),
                            total: daysInPeriod
                        )
                    }
                }
            }
        }
    }

    // MARK: - Hedef bölümü
    var goalSectionView: some View {
        reportCard(title: "Hedefler", icon: "target", color: .purple) {
            if goals.isEmpty {
                emptyState(text: "Henüz hedef eklenmedi")
            } else {
                VStack(spacing: 12) {
                    ForEach(goals) { goal in
                        GoalRowView(goal: goal)
                    }
                }
            }
        }
    }

    // MARK: - Yardımcı bileşenler
    @ViewBuilder
    func summaryCard(icon: String, color: Color, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 20)).foregroundColor(color)
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemGroupedBackground)))
    }

    @ViewBuilder
    func reportCard<Content: View>(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.caption.bold()).foregroundColor(color)
                Text(title.uppercased()).font(.caption.bold()).foregroundColor(.secondary).kerning(0.8)
            }
            content()
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    func emptyState(text: String) -> some View {
        HStack {
            Spacer()
            Text(text).font(.caption).foregroundColor(.secondary)
            Spacer()
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Alışkanlık satırı
struct HabitRowView: View {
    let habit: Habit
    let count: Int
    let total: Int

    var percent: Double { total > 0 ? Double(count) / Double(total) : 0 }

    var body: some View {
        HStack(spacing: 10) {
            Text(habit.emoji).font(.title3)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(habit.title).font(.subheadline.bold())
                    Spacer()
                    Text("\(count)/\(total) gün")
                        .font(.caption).foregroundColor(.secondary)
                    Text("%\(Int(percent * 100))")
                        .font(.caption.bold())
                        .foregroundColor(habit.color)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.tertiarySystemFill)).frame(height: 6)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(habit.color)
                            .frame(width: geo.size.width * percent, height: 6)
                    }
                }
                .frame(height: 6)
            }
        }
    }
}

// MARK: - Hedef satırı
struct GoalRowView: View {
    let goal: Goal

    var accentColor: Color { Color(hex: goal.colorHex) ?? .purple }

    var body: some View {
        HStack(spacing: 10) {
            Text(goal.emoji).font(.title3)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(goal.title).font(.subheadline.bold()).lineLimit(1)
                    Spacer()
                    if goal.isOverdue {
                        Text("Süre geçti")
                            .font(.caption2.bold()).foregroundColor(.white)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Capsule().fill(Color.red))
                    } else {
                        Text("\(goal.daysLeft) gün")
                            .font(.caption2.bold())
                            .foregroundColor(goal.isUrgent ? .orange : .secondary)
                    }
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.tertiarySystemFill)).frame(height: 6)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(goal.progress >= 1 ? Color.green : accentColor)
                            .frame(width: geo.size.width * goal.progress, height: 6)
                    }
                }
                .frame(height: 6)
                HStack {
                    Text(goal.type.rawValue).font(.caption).foregroundColor(.secondary)
                    Spacer()
                    Text("%\(Int(goal.progress * 100))")
                        .font(.caption.bold()).foregroundColor(accentColor)
                }
            }
        }
    }
}

enum ReportType: String, CaseIterable {
    case weekly = "Haftalık"
    case monthly = "Aylık"
}
