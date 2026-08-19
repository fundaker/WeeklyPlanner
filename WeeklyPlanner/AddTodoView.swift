import SwiftUI

struct AddTodoView: View {

    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var deadline = Date()
    @State private var selectedCategory: TodoCategory = .general
    @State private var titleShake = false

    var addTodo: (Todo) -> Void

    var isValid: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    var accentColor: Color { selectedCategory.color }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {

                        // Header
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(accentColor.opacity(0.15))
                                    .frame(width: 72, height: 72)
                                Image(systemName: selectedCategory.icon)
                                    .font(.system(size: 32))
                                    .foregroundColor(accentColor)
                            }
                            .animation(.spring(response: 0.3), value: selectedCategory)

                            Text("Yeni Yapılacak")
                                .font(.title2.bold())
                            Text("Ne yapmayı planlıyorsun?")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 8)

                        // Başlık
                        cardSection(title: "Yapılacak", icon: "pencil") {
                            TextField("Buraya yaz...", text: $title)
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

                        // Kategori
                        cardSection(title: "Kategori", icon: "tag") {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ForEach(TodoCategory.allCases, id: \.self) { cat in
                                    let isSelected = selectedCategory == cat
                                    Button {
                                        withAnimation(.spring(response: 0.25)) {
                                            selectedCategory = cat
                                        }
                                    } label: {
                                        VStack(spacing: 4) {
                                            Text(cat.emoji)
                                                .font(.title2)
                                            Text(cat.label)
                                                .font(.caption.bold())
                                                .foregroundColor(isSelected ? .white : cat.color)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(isSelected ? cat.color : cat.color.opacity(0.12))
                                        )
                                        .scaleEffect(isSelected ? 1.04 : 1.0)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        // Son Tarih
                        cardSection(title: "Son Tarih", icon: "calendar") {
                            DatePicker(
                                "",
                                selection: $deadline,
                                in: Date()...,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                            .tint(accentColor)
                        }

                        // Kaydet
                        Button {
                            if isValid {
                                let newTodo = Todo(
                                    title: title.trimmingCharacters(in: .whitespaces),
                                    deadline: deadline,
                                    category: selectedCategory
                                )
                                addTodo(newTodo)
                                dismiss()
                            } else {
                                titleShake = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    titleShake = false
                                }
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Kaydet")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(isValid ? accentColor : Color.secondary.opacity(0.4))
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
                    Button("İptal") { dismiss() }
                        .foregroundColor(.secondary)
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
                    .foregroundColor(accentColor)
                Text(title.uppercased())
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
                    .kerning(0.8)
            }
            content()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}
