import SwiftUI
import SwiftData

// MARK: - 컬렉션 생성/편집 시트

struct CollectionFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    /// nil이면 신규 생성, 값이 있으면 편집
    var editTarget: PrayerCollection?

    @State private var name: String = ""
    @State private var selectedIcon: String = "folder.fill"
    @State private var selectedColorIndex: Int = 0

    @Query(sort: \PrayerCollection.sortOrder) private var existingCollections: [PrayerCollection]

    private var isEditing: Bool { editTarget != nil }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    previewCard
                    nameSection
                    iconSection
                    colorSection
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
                .padding(.vertical, DesignSystem.Spacing.lg)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle(isEditing ? L.Collection.editCollection : L.Collection.newCollection)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L.Button.cancel) { dismiss() }
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L.Button.save) { save() }
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.primary)
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear { loadEditTarget() }
    }

    // MARK: - Preview

    private var previewCard: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            ZStack {
                Circle()
                    .fill(PrayerCollection.colorPalette[selectedColorIndex % PrayerCollection.colorPalette.count].opacity(0.2))
                    .frame(width: 56, height: 56)
                Image(systemName: selectedIcon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(PrayerCollection.colorPalette[selectedColorIndex % PrayerCollection.colorPalette.count])
            }

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(name.isEmpty ? L.Collection.namePlaceholder : name)
                    .font(DesignSystem.Typography.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(name.isEmpty ? DesignSystem.Colors.tertiaryText : DesignSystem.Colors.primaryText)
                Text("0개의 기도")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
            Spacer()
        }
        .padding(DesignSystem.Spacing.lg)
        .background(DesignSystem.Colors.cardBackground)
        .cornerRadius(DesignSystem.CornerRadius.large)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    // MARK: - Name

    private var nameSection: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("이름")
                    .font(DesignSystem.Typography.callout)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.primaryText)

                TextField(L.Collection.namePlaceholder, text: $name)
                    .font(DesignSystem.Typography.body)
                    .padding(DesignSystem.Spacing.md)
                    .background(DesignSystem.Colors.secondaryBackground)
                    .cornerRadius(DesignSystem.CornerRadius.medium)
            }
            .padding(DesignSystem.Spacing.lg)
        }
    }

    // MARK: - Icon

    private var iconSection: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                Text(L.Collection.iconLabel)
                    .font(DesignSystem.Typography.callout)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.primaryText)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: DesignSystem.Spacing.sm) {
                    ForEach(PrayerCollection.iconOptions, id: \.self) { icon in
                        Button {
                            withAnimation(DesignSystem.Animation.quick) {
                                selectedIcon = icon
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                                    .fill(selectedIcon == icon
                                          ? PrayerCollection.colorPalette[selectedColorIndex % PrayerCollection.colorPalette.count].opacity(0.2)
                                          : DesignSystem.Colors.secondaryBackground)
                                Image(systemName: icon)
                                    .font(.system(size: 20))
                                    .foregroundColor(selectedIcon == icon
                                                     ? PrayerCollection.colorPalette[selectedColorIndex % PrayerCollection.colorPalette.count]
                                                     : DesignSystem.Colors.secondaryText)
                            }
                            .frame(height: 44)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }
    }

    // MARK: - Color

    private var colorSection: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                Text(L.Collection.colorLabel)
                    .font(DesignSystem.Typography.callout)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.primaryText)

                HStack(spacing: DesignSystem.Spacing.md) {
                    ForEach(Array(PrayerCollection.colorPalette.enumerated()), id: \.offset) { index, color in
                        Button {
                            withAnimation(DesignSystem.Animation.quick) {
                                selectedColorIndex = index
                            }
                        } label: {
                            ZStack {
                                Circle().fill(color).frame(width: 34, height: 34)
                                if selectedColorIndex == index {
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2.5)
                                        .frame(width: 34, height: 34)
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }
    }

    // MARK: - Actions

    private func loadEditTarget() {
        guard let target = editTarget else { return }
        name = target.name
        selectedIcon = target.icon
        selectedColorIndex = target.colorIndex
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if let target = editTarget {
            target.name = trimmed
            target.icon = selectedIcon
            target.colorIndex = selectedColorIndex
        } else {
            let newSortOrder = existingCollections.count
            let collection = PrayerCollection(
                name: trimmed,
                icon: selectedIcon,
                colorIndex: selectedColorIndex,
                sortOrder: newSortOrder
            )
            modelContext.insert(collection)
        }

        try? modelContext.save()
        dismiss()
    }
}

// MARK: - 컬렉션 선택 시트

struct CollectionPickerSheet: View {
    @Environment(\.dismiss) private var dismiss

    let collections: [PrayerCollection]
    @Binding var selected: PrayerCollection?

    var body: some View {
        NavigationView {
            List {
                // 없음 옵션
                Button {
                    selected = nil
                    dismiss()
                } label: {
                    HStack(spacing: DesignSystem.Spacing.md) {
                        Image(systemName: "folder")
                            .font(.system(size: 18))
                            .foregroundColor(DesignSystem.Colors.tertiaryText)
                            .frame(width: 36)

                        Text(L.Collection.none)
                            .foregroundColor(DesignSystem.Colors.secondaryText)

                        Spacer()

                        if selected == nil {
                            Image(systemName: "checkmark")
                                .foregroundColor(DesignSystem.Colors.primary)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())

                // 컬렉션 목록
                ForEach(collections) { collection in
                    Button {
                        selected = collection
                        dismiss()
                    } label: {
                        HStack(spacing: DesignSystem.Spacing.md) {
                            ZStack {
                                Circle()
                                    .fill(collection.color.opacity(0.2))
                                    .frame(width: 36, height: 36)
                                Image(systemName: collection.icon)
                                    .font(.system(size: 16))
                                    .foregroundColor(collection.color)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(collection.name)
                                    .font(DesignSystem.Typography.callout)
                                    .foregroundColor(DesignSystem.Colors.primaryText)
                                Text("\(collection.prayers.count)개의 기도")
                                    .font(DesignSystem.Typography.caption2)
                                    .foregroundColor(DesignSystem.Colors.secondaryText)
                            }

                            Spacer()

                            if selected?.persistentModelID == collection.persistentModelID {
                                Image(systemName: "checkmark")
                                    .foregroundColor(DesignSystem.Colors.primary)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(L.Collection.selectCollection)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L.Button.cancel) { dismiss() }
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
            }
        }
    }
}

#Preview {
    CollectionFormView()
        .modelContainer(for: [PrayerCollection.self, Prayer.self], inMemory: true)
}
