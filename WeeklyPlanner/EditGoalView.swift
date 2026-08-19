import SwiftUI

struct EditGoalView: View {
    @Environment(\.dismiss) var dismiss

    let goal: Goal
    var onSave: (GoalDraft) -> Void

    @State private var title = ""
    @State private var deadline = Date()
    @State private var type: GoalType = .midTerm
    @State private var selectedEmoji = "🎯"
    @State private var selectedColorHex = "7B5EA7"
    @State private var subTasks: [SubTaskDraft] = []
    @State private var subTaskText = ""
    @State private var titleShake = false

    let presetEmojis = ["🎯","🏆","💡","📚","💪","🚀","🌟","❤️","🎨","🧘","✈️","💰","🏡","🎓","🌱","⚡️","🔥","🎵","🏅","🤝"]
    let presetColors: [(String, Color)] = [
        ("7B5EA7", Color(red: 0.48, green: 0.37, blue: 0.65)),
        ("4A90D9", Color(red: 0.29, green: 0.56, blue: 0.85)),
        ("E8534A", Color(red: 0.91, green: 0.33, blue: 0.29)),
        ("F5A623", Color(red: 0.96, green: 0.65, blue: 0.14)),
        ("27AE7A", Color(red: 0.15, green: 0.68, blue: 0.48)),
        ("E91E8C", Color(red: 0.91, green: 0.12, blue: 0.55)),
        ("1ABCB0", Color(red: 0.10, green: 0.74, blue: 0.69)),
        ("FF6B35", Color(red: 1.00, green: 0.42, blue: 0.21)),
    ]

    var accentColor: Color { Color(hex: selectedColorHex) ?? .purple }
    var isValid: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {

                        // Header önizleme
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(accentColor.opacity(0.18))
                                    .frame(width: 80, height: 80)
                                Text(selectedEmoji).font(.system(size: 38))
                            }
                            .animation(.spring(response: 0.3), value: selectedColorHex)

                            Text(title.isEmpty ? "Hedef Düzenle" : title)
                                .font(.title2.bold())
                                .foregroundColor(title.isEmpty ? .secondary : .primary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 8)

                        // Başlık
                        cardSection(title: "Hedef Adı", icon: "pencil") {
                            TextField("Hedefinizi yazın...", text: $title)
                                .font(.body).padding(.horizontal, 4)
                                .offset(x: titleShake ? -6 : 0)
                                .animation(
                                    titleShake
                                        ? .easeInOut(duration: 0.06).repeatCount(4, autoreverses: true)
                                        : .default,
                                    value: titleShake
                                )
                        }

                        // Tür
                        cardSection(title: "Hedef Türü", icon: "tag") {
                            HStack(spacing: 10) {
                                ForEach(GoalType.allCases, id: \.self) { t in
                                    let isSelected = type == t
                                    Button {
                                        withAnimation(.spring(response: 0.25)) { type = t }
                                    } label: {
                                        VStack(spacing: 4) {
                                            Text(t.icon).font(.title2)
                                            Text(t.rawValue)
                                                .font(.caption.bold())
                                                .foregroundColor(isSelected ? .white : accentColor)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(RoundedRectangle(cornerRadius: 12).fill(isSelected ? accentColor : accentColor.opacity(0.1)))
                                        .scaleEffect(isSelected ? 1.03 : 1.0)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        // Emoji
                        cardSection(title: "Emoji", icon: "face.smiling") {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 10), spacing: 8) {
                                ForEach(presetEmojis, id: \.self) { e in
                                    Button {
                                        withAnimation(.spring(response: 0.2)) { selectedEmoji = e }
                                    } label: {
                                        Text(e).font(.title3)
                                            .frame(width: 36, height: 36)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(selectedEmoji == e ? accentColor.opacity(0.25) : Color(.tertiarySystemFill))
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .strokeBorder(selectedEmoji == e ? accentColor : .clear, lineWidth: 2)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        // Renk
                        cardSection(title: "Renk", icon: "paintpalette") {
                            HStack(spacing: 10) {
                                ForEach(presetColors, id: \.0) { hex, color in
                                    let isSelected = selectedColorHex == hex
                                    Button {
                                        withAnimation(.spring(response: 0.25)) { selectedColorHex = hex }
                                    } label: {
                                        ZStack {
                                            Circle().fill(color).frame(width: 32, height: 32)
                                            if isSelected {
                                                Image(systemName: "checkmark")
                                                    .font(.caption.bold()).foregroundColor(.white)
                                            }
                                        }
                                        .scaleEffect(isSelected ? 1.15 : 1.0)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        // Deadline
                        cardSection(title: "Hedef Tarihi", icon: "calendar") {
                            DatePicker("", selection: $deadline, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .tint(accentColor)
                        }

                        // Alt görevler
                        cardSection(title: "Alt Görevler", icon: "checklist") {
                            VStack(spacing: 10) {
                                ForEach(subTasks.indices, id: \.self) { i in
                                    HStack(spacing: 10) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 5)
                                                .fill(subTasks[i].isDone ? accentColor : Color(.tertiarySystemFill))
                                                .frame(width: 20, height: 20)
                                            if subTasks[i].isDone {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 10, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        .onTapGesture { subTasks[i].isDone.toggle() }

                                        Text(subTasks[i].title)
                                            .font(.subheadline)
                                            .strikethrough(subTasks[i].isDone, color: .secondary)
                                            .foregroundColor(subTasks[i].isDone ? .secondary : .primary)
                                        Spacer()
                                        Button {
                                            subTasks.remove(at: i)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding(.vertical, 4)
                                    Divider()
                                }

                                HStack(spacing: 8) {
                                    TextField("Alt görev ekle...", text: $subTaskText).font(.subheadline)
                                    Button {
                                        let trimmed = subTaskText.trimmingCharacters(in: .whitespaces)
                                        if !trimmed.isEmpty {
                                            subTasks.append(SubTaskDraft(title: trimmed))
                                            subTaskText = ""
                                        }
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title3)
                                            .foregroundColor(subTaskText.isEmpty ? .secondary : accentColor)
                                    }
                                    .buttonStyle(.plain)
                                    .disabled(subTaskText.isEmpty)
                                }
                            }
                        }

                        // Kaydet
                        Button {
                            if isValid {
                                onSave(
                                    GoalDraft(
                                        title: title.trimmingCharacters(in: .whitespaces),
                                        deadline: deadline,
                                        type: type,
                                        emoji: selectedEmoji,
                                        colorHex: selectedColorHex,
                                        subTasks: subTasks
                                    )
                                )
                                dismiss()
                            } else {
                                titleShake = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { titleShake = false }
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Güncelle").fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(RoundedRectangle(cornerRadius: 16).fill(isValid ? accentColor : Color.secondary.opacity(0.4)))
                        }
                        .buttonStyle(.plain)
                        .padding(.bottom, 8)
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
            .onAppear {
                title = goal.title
                deadline = goal.deadline
                type = goal.type
                selectedEmoji = goal.emoji
                selectedColorHex = goal.colorHex
                subTasks = goal.orderedSubTasks.map {
                    SubTaskDraft(title: $0.title, isDone: $0.isDone)
                }
            }
        }
    }

    @ViewBuilder
    func cardSection<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.caption.bold()).foregroundColor(accentColor)
                Text(title.uppercased()).font(.caption.bold()).foregroundColor(.secondary).kerning(0.8)
            }
            content()
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
    }
}
