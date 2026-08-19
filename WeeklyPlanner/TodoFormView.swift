import SwiftUI

/// Yapılacak ekleme ve düzenleme ekranlarının ortak formu.
/// İki ekran da aynı alanları aynı görünümde sunsun diye tek yerde duruyor.
struct TodoFormView: View {

    @Environment(\.dismiss) private var dismiss

    let heading: String
    let subheading: String
    let onSave: (_ title: String, _ deadline: Date, _ category: TodoCategory) -> Void

    @State private var title: String
    @State private var deadline: Date
    @State private var category: TodoCategory
    @State private var titleShake = false

    /// Düzenlemede son tarih geçmişte kalmış olabilir; takvim onu da kapsasın.
    private let earliestDate: Date

    init(
        heading: String,
        subheading: String,
        title: String = "",
        deadline: Date = Date(),
        category: TodoCategory = .general,
        onSave: @escaping (String, Date, TodoCategory) -> Void
    ) {
        self.heading = heading
        self.subheading = subheading
        self.onSave = onSave
        _title = State(initialValue: title)
        _deadline = State(initialValue: deadline)
        _category = State(initialValue: category)
        self.earliestDate = min(Calendar.current.startOfDay(for: Date()), deadline)
    }

    private var isValid: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    private var accentColor: Color { category.color }

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
                                Image(systemName: category.icon)
                                    .font(.system(size: 32))
                                    .foregroundColor(accentColor)
                            }
                            .animation(.spring(response: 0.3), value: category)

                            Text(heading)
                                .font(.title2.bold())
                            Text(subheading)
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
                                    let isSelected = category == cat
                                    Button {
                                        withAnimation(.spring(response: 0.25)) {
                                            category = cat
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
                                in: earliestDate...,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                            .tint(accentColor)
                        }

                        // Kaydet
                        Button {
                            guard isValid else {
                                titleShake = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    titleShake = false
                                }
                                return
                            }
                            onSave(title.trimmingCharacters(in: .whitespaces), deadline, category)
                            dismiss()
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
    private func cardSection<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
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
