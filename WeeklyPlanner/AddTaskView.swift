import SwiftUI

struct AddTaskView: View {

    let todayIndex: Int
    let days: [String]
    var onAdd: (WeeklyTask) -> Void

    @State private var title = ""
    @State private var selectedDay: String
    @State private var hours = 1
    @State private var selectedPriority: Priority = .medium
    @State private var titleShake = false

    @Environment(\.dismiss) var dismiss

    init(todayIndex: Int, days: [String], onAdd: @escaping (WeeklyTask) -> Void) {
        self.todayIndex = todayIndex
        self.days = days
        self.onAdd = onAdd
        // Varsayılan gün: bugün
        _selectedDay = State(initialValue: days[min(todayIndex, days.count - 1)])
    }

    func isPast(_ day: String) -> Bool {
        guard let idx = days.firstIndex(of: day) else { return false }
        return idx < todayIndex
    }

    var priorityColor: Color {
        switch selectedPriority {
        case .low:    return Color(red: 0.27, green: 0.73, blue: 0.53)
        case .medium: return Color(red: 0.98, green: 0.72, blue: 0.20)
        case .high:   return Color(red: 0.96, green: 0.35, blue: 0.35)
        }
    }

    var isValid: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {

                        // Header
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(priorityColor.opacity(0.15))
                                    .frame(width: 72, height: 72)
                                Image(systemName: "checklist.checked")
                                    .font(.system(size: 32))
                                    .foregroundColor(priorityColor)
                            }
                            .animation(.spring(response: 0.3), value: selectedPriority)
                            Text("Yeni Görev").font(.title2.bold())
                            Text("Hadi bir şeyler planlayalım")
                                .font(.subheadline).foregroundColor(.secondary)
                        }
                        .padding(.top, 8)

                        // Görev adı
                        cardSection(title: "Görev Adı", icon: "pencil") {
                            TextField("Görevi buraya yaz...", text: $title)
                                .font(.body).padding(.horizontal, 4)
                                .offset(x: titleShake ? -6 : 0)
                                .animation(
                                    titleShake
                                        ? .easeInOut(duration: 0.06).repeatCount(4, autoreverses: true)
                                        : .default,
                                    value: titleShake
                                )
                        }

                        // Gün seçici — geçmiş günler kilitli
                        cardSection(title: "Gün", icon: "calendar") {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(days, id: \.self) { day in
                                        let isSelected = selectedDay == day
                                        let past = isPast(day)

                                        Button {
                                            if !past {
                                                withAnimation(.spring(response: 0.25)) {
                                                    selectedDay = day
                                                }
                                            }
                                        } label: {
                                            HStack(spacing: 4) {
                                                Text(String(day.prefix(3)))
                                                    .font(.system(size: 13, weight: isSelected ? .bold : .regular))
                                                if past {
                                                    Image(systemName: "lock.fill")
                                                        .font(.system(size: 9))
                                                }
                                            }
                                            .foregroundColor(
                                                past ? Color(.quaternaryLabel) :
                                                isSelected ? .white : .primary
                                            )
                                            .padding(.horizontal, 14).padding(.vertical, 8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(
                                                        past ? Color(.tertiarySystemFill) :
                                                        isSelected ? priorityColor : Color(.tertiarySystemFill)
                                                    )
                                            )
                                        }
                                        .buttonStyle(.plain)
                                        .disabled(past)
                                    }
                                }
                                .padding(.horizontal, 2).padding(.vertical, 2)
                            }

                            if isPast(selectedDay) {
                                HStack(spacing: 4) {
                                    Image(systemName: "info.circle").font(.caption)
                                    Text("Geçmiş günlere görev eklenemez")
                                        .font(.caption)
                                }
                                .foregroundColor(.secondary)
                            }
                        }

                        // Saat seçici
                        cardSection(title: "Süre", icon: "clock") {
                            VStack(spacing: 12) {
                                HStack {
                                    Text("\(hours) saat")
                                        .font(.system(size: 28, weight: .bold, design: .rounded))
                                        .foregroundColor(priorityColor)
                                        .animation(.spring(response: 0.2), value: hours)
                                    Spacer()
                                    HStack(spacing: 0) {
                                        Button {
                                            if hours > 1 { withAnimation { hours -= 1 } }
                                        } label: {
                                            Image(systemName: "minus.circle.fill")
                                                .font(.system(size: 32))
                                                .foregroundColor(hours > 1 ? priorityColor : .secondary)
                                        }
                                        .buttonStyle(.plain)

                                        Text("\(hours)")
                                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                                            .frame(width: 40)

                                        Button {
                                            if hours < 12 { withAnimation { hours += 1 } }
                                        } label: {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.system(size: 32))
                                                .foregroundColor(hours < 12 ? priorityColor : .secondary)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }

                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color(.tertiarySystemFill)).frame(height: 8)
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(priorityColor)
                                            .frame(width: geo.size.width * CGFloat(hours) / 12.0, height: 8)
                                            .animation(.spring(response: 0.3), value: hours)
                                    }
                                }
                                .frame(height: 8)
                            }
                        }

                        // Öncelik
                        cardSection(title: "Öncelik", icon: "flag") {
                            HStack(spacing: 10) {
                                ForEach(Priority.allCases, id: \.self) { p in
                                    let isSelected = selectedPriority == p
                                    let pColor: Color = {
                                        switch p {
                                        case .low:    return Color(red: 0.27, green: 0.73, blue: 0.53)
                                        case .medium: return Color(red: 0.98, green: 0.72, blue: 0.20)
                                        case .high:   return Color(red: 0.96, green: 0.35, blue: 0.35)
                                        }
                                    }()
                                    Button {
                                        withAnimation(.spring(response: 0.25)) { selectedPriority = p }
                                    } label: {
                                        VStack(spacing: 4) {
                                            Text(p.icon).font(.title2)
                                            Text(p.rawValue)
                                                .font(.caption.bold())
                                                .foregroundColor(isSelected ? .white : pColor)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(RoundedRectangle(cornerRadius: 12).fill(isSelected ? pColor : pColor.opacity(0.12)))
                                        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(isSelected ? pColor : .clear, lineWidth: 2))
                                        .scaleEffect(isSelected ? 1.04 : 1.0)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        // Kaydet
                        Button {
                            if isValid {
                                let newTask = WeeklyTask(
                                    title: title.trimmingCharacters(in: .whitespaces),
                                    day: selectedDay,
                                    totalHours: hours,
                                    priority: selectedPriority
                                )
                                onAdd(newTask)
                                dismiss()
                            } else {
                                titleShake = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { titleShake = false }
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Kaydet").fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(isValid ? priorityColor : Color.secondary.opacity(0.4))
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.bottom, 8)
                        .animation(.spring(response: 0.3), value: isValid)
                    }
                    .padding(.horizontal, 20).padding(.top, 8)
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

    @ViewBuilder
    func cardSection<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.caption.bold()).foregroundColor(priorityColor)
                Text(title.uppercased()).font(.caption.bold()).foregroundColor(.secondary).kerning(0.8)
            }
            content()
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
    }
}
