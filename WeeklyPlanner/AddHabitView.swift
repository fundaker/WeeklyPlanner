import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) var dismiss

    var habitToEdit: Habit? = nil
    var onSave: (Habit) -> Void

    @State private var title = ""
    @State private var emoji = "⭐"
    @State private var selectedColor = Color(red: 0.45, green: 0.45, blue: 0.90)
    @State private var titleShake = false
    @State private var showEmojiPicker = false

    let presetEmojis = [
        "⭐","📚","🏃","💧","🧘","🎸","✍️","🎨","💪","🥗",
        "😴","🧹","🐾","🌿","🎯","🧠","🎵","🏋️","🚴","🌅"
    ]

    let presetColors: [Color] = [
        Color(red: 0.45, green: 0.45, blue: 0.90),
        Color(red: 0.20, green: 0.60, blue: 0.90),
        Color(red: 0.27, green: 0.73, blue: 0.53),
        Color(red: 0.96, green: 0.35, blue: 0.35),
        Color(red: 0.98, green: 0.60, blue: 0.20),
        Color(red: 0.98, green: 0.72, blue: 0.20),
        Color(red: 0.60, green: 0.40, blue: 0.90),
        Color(red: 0.90, green: 0.40, blue: 0.70),
        Color(red: 0.20, green: 0.78, blue: 0.78),
        Color(red: 0.55, green: 0.76, blue: 0.29),
    ]

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
                                    .fill(selectedColor.opacity(0.18))
                                    .frame(width: 80, height: 80)
                                Text(emoji)
                                    .font(.system(size: 38))
                            }
                            .animation(.spring(response: 0.3), value: selectedColor)

                            Text(title.isEmpty ? "Yeni Alışkanlık" : title)
                                .font(.title2.bold())
                                .foregroundColor(title.isEmpty ? .secondary : .primary)
                                .animation(.easeInOut, value: title)
                        }
                        .padding(.top, 8)

                        // İsim
                        cardSection(title: "Alışkanlık Adı", icon: "pencil") {
                            TextField("Örn: Kitap Oku, Su İç...", text: $title)
                                .font(.body)
                                .padding(.horizontal, 4)
                                .offset(x: titleShake ? -6 : 0)
                                .animation(
                                    titleShake
                                        ? .easeInOut(duration: 0.06).repeatCount(4, autoreverses: true)
                                        : .default,
                                    value: titleShake
                                )
                        }

                        // Emoji seçici
                        cardSection(title: "Emoji", icon: "face.smiling") {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 10), spacing: 8) {
                                ForEach(presetEmojis, id: \.self) { e in
                                    Button {
                                        withAnimation(.spring(response: 0.2)) { emoji = e }
                                    } label: {
                                        Text(e)
                                            .font(.title3)
                                            .frame(width: 36, height: 36)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(emoji == e ? selectedColor.opacity(0.25) : Color(.tertiarySystemFill))
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .strokeBorder(emoji == e ? selectedColor : .clear, lineWidth: 2)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        // Renk seçici
                        cardSection(title: "Renk", icon: "paintpalette") {
                            HStack(spacing: 10) {
                                ForEach(presetColors.indices, id: \.self) { i in
                                    let color = presetColors[i]
                                    let isSelected = color.toHex() == selectedColor.toHex()
                                    Button {
                                        withAnimation(.spring(response: 0.25)) { selectedColor = color }
                                    } label: {
                                        ZStack {
                                            Circle()
                                                .fill(color)
                                                .frame(width: 32, height: 32)
                                            if isSelected {
                                                Image(systemName: "checkmark")
                                                    .font(.caption.bold())
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        .scaleEffect(isSelected ? 1.15 : 1.0)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        // Kaydet
                        Button {
                            if isValid {
                                var habit = habitToEdit ?? Habit(
                                    title: "",
                                    emoji: "",
                                    colorHex: ""
                                )
                                habit.title = title.trimmingCharacters(in: .whitespaces)
                                habit.emoji = emoji
                                habit.colorHex = selectedColor.toHex()
                                onSave(habit)
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
                                    .fill(isValid ? selectedColor : Color.secondary.opacity(0.4))
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.bottom, 8)
                        .animation(.spring(response: 0.3), value: isValid)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") { dismiss() }.foregroundColor(.secondary)
                }
            }
            .onAppear {
                if let h = habitToEdit {
                    title = h.title
                    emoji = h.emoji
                    selectedColor = h.color
                }
            }
        }
    }

    @ViewBuilder
    func cardSection<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption.bold())
                    .foregroundColor(selectedColor)
                Text(title.uppercased())
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
                    .kerning(0.8)
            }
            content()
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
    }
}
