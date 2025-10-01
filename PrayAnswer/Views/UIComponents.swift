import SwiftUI

// MARK: - Prayer List Components

// 모던한 기도 행 컴포넌트
struct ModernPrayerRow: View {
    let prayer: Prayer
    let onFavoriteToggle: (() -> Void)?
    
    init(prayer: Prayer, onFavoriteToggle: (() -> Void)? = nil) {
        self.prayer = prayer
        self.onFavoriteToggle = onFavoriteToggle
    }
    
    var body: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                    StatusIndicator(storage: prayer.storage, size: .medium)
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text(prayer.title)
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(prayer.content)
                            .font(DesignSystem.Typography.callout)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        CategoryTag(category: prayer.category, size: .small)
                        
                        if let onFavoriteToggle = onFavoriteToggle {
                            FavoriteButton(isFavorite: prayer.isFavorite) {
                                onFavoriteToggle()
                            }
                        }
                    }
                }
                
                HStack {
                    if prayer.hasTarget {
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Image(systemName: "person.fill")
                                .font(.caption2)
                                .foregroundColor(DesignSystem.Colors.secondary)
                            
                            Text(prayer.target)
                                .font(DesignSystem.Typography.caption2)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    Text(prayer.formattedCreatedDate)
                        .font(DesignSystem.Typography.caption2)
                        .foregroundColor(DesignSystem.Colors.tertiaryText)
                }
            }
            .padding(DesignSystem.Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityLabel(prayer.accessibilityLabel)
        .accessibilityHint(prayer.accessibilityHint)
        .accessibilityAddTraits(.isButton)
    }
}

// 빈 상태 뷰
struct EmptyStateView: View {
    let storage: PrayerStorage
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xxxl) {
            // 상태 인디케이터를 더 큰 크기로 커스텀 구현
            Image(systemName: storage.iconName)
                .font(.system(size: 64, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 100, height: 100)
                .background(storage.color)
                .clipShape(Circle())
                .shadow(
                    color: storage.color.opacity(0.3),
                    radius: 12,
                    x: 0,
                    y: 4
                )
            
            VStack(spacing: DesignSystem.Spacing.md) {
                Text(L.Empty.storageTitle)
                    .font(DesignSystem.Typography.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.primaryText)

                Text(storage.localizedDescription)
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 400)
        .padding(.vertical, DesignSystem.Spacing.xxxl)
    }
}

// 모던한 보관소 카드
struct ModernStorageCard: View {
    let storage: PrayerStorage
    let count: Int
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: DesignSystem.Spacing.sm) {
                StatusIndicator(storage: storage, size: .medium)
                
                VStack(spacing: DesignSystem.Spacing.xs) {
                    Text(storage.displayName)
                        .font(DesignSystem.Typography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(isSelected ? .white : DesignSystem.Colors.primaryText)
                    
                    Text("\(count)")
                        .font(DesignSystem.Typography.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : DesignSystem.Colors.secondaryText)
                }
            }
            .padding(.vertical, DesignSystem.Spacing.md)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .frame(maxWidth: .infinity)
            .background(
                isSelected ? storage.color : DesignSystem.Colors.cardBackground
            )
            .cornerRadius(DesignSystem.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .stroke(
                        isSelected ? storage.color.opacity(0.3) : Color.clear,
                        lineWidth: 2
                    )
            )
            .shadow(
                color: isSelected ? storage.color.opacity(0.3) : DesignSystem.Shadow.small.color,
                radius: isSelected ? DesignSystem.Shadow.medium.radius : DesignSystem.Shadow.small.radius,
                x: 0,
                y: isSelected ? 2 : 1
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(DesignSystem.Animation.quick, value: isSelected)
        .accessibilityLabel(L.Accessibility.storageFormat(storage.displayName, count))
        .accessibilityHint(L.Accessibility.selectStorage(storage.displayName))
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

// MARK: - Form Components

// 모던한 폼 섹션
struct ModernFormSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text(title)
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .padding(.horizontal, DesignSystem.Spacing.xs)
            
            ModernCard {
                content
                    .padding(DesignSystem.Spacing.lg)
            }
        }
    }
}

// 모던한 텍스트 필드
struct ModernTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var focusedField: FocusState<Bool>.Binding?
    
    init(title: String, text: Binding<String>, placeholder: String, focusedField: FocusState<Bool>.Binding? = nil) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.focusedField = focusedField
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text(title)
                .font(DesignSystem.Typography.callout)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .fontWeight(.medium)
            
            TextField(placeholder, text: $text)
                .font(DesignSystem.Typography.body)
                .padding(DesignSystem.Spacing.md)
                .background(DesignSystem.Colors.secondaryBackground)
                .cornerRadius(DesignSystem.CornerRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                        .stroke(
                            text.isEmpty ? Color.clear : DesignSystem.Colors.primary.opacity(0.3),
                            lineWidth: 1
                        )
                )
                .animation(DesignSystem.Animation.quick, value: text.isEmpty)
                .focused(focusedField ?? FocusState<Bool>().projectedValue)
        }
    }
}

// 모던한 텍스트 에디터
struct ModernTextEditor: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text(title)
                .font(DesignSystem.Typography.callout)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .fontWeight(.medium)
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: $text)
                    .font(DesignSystem.Typography.body)
                    .padding(DesignSystem.Spacing.md)
                    .scrollContentBackground(.hidden)
                    .background(DesignSystem.Colors.secondaryBackground)
                    .frame(height: 200)
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                            .stroke(
                                text.isEmpty ? Color.clear : DesignSystem.Colors.primary.opacity(0.3),
                                lineWidth: 1
                            )
                    )
                
                if text.isEmpty {
                    Text(placeholder)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.tertiaryText)
                        .padding(.horizontal, DesignSystem.Spacing.md + 4)
                        .padding(.vertical, DesignSystem.Spacing.md + 8)
                        .allowsHitTesting(false)
                }
            }
            .animation(DesignSystem.Animation.quick, value: text.isEmpty)
        }
    }
}

// 모던한 카테고리 피커
struct ModernCategoryPicker: View {
    let title: String
    @Binding var selection: PrayerCategory
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text(title)
                .font(DesignSystem.Typography.callout)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .fontWeight(.medium)
            
            Menu {
                ForEach(PrayerCategory.allCases, id: \.self) { category in
                    Button(action: {
                        withAnimation(DesignSystem.Animation.quick) {
                            selection = category
                        }
                    }) {
                        HStack {
                            Text(category.displayName)
                            if selection == category {
                                Image(systemName: "checkmark")
                                    .foregroundColor(DesignSystem.Colors.primary)
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    CategoryTag(category: selection, size: .medium)
                    
                    Text(selection.displayName)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                .padding(DesignSystem.Spacing.md)
                .background(DesignSystem.Colors.secondaryBackground)
                .cornerRadius(DesignSystem.CornerRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                        .stroke(DesignSystem.Colors.primary.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
}

// MARK: - Detail Components

// 모던한 기도 정보 카드
struct ModernPrayerInfoCard: View {
    let prayer: Prayer
    
    var body: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                Text(L.Info.prayerInfo)
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                
                VStack(spacing: DesignSystem.Spacing.md) {
                    ModernDateInfoRow(
                        icon: "calendar",
                        title: L.Info.createdDate,
                        date: prayer.createdDate,
                        color: DesignSystem.Colors.primary
                    )

                    if let modifiedDate = prayer.modifiedDate {
                        ModernDateInfoRow(
                            icon: "pencil",
                            title: L.Info.modifiedDate,
                            date: modifiedDate,
                            color: DesignSystem.Colors.secondary
                        )
                    }

                    if let movedDate = prayer.movedDate {
                        ModernDateInfoRow(
                            icon: "arrow.right.circle",
                            title: L.Info.movedDate,
                            date: movedDate,
                            color: DesignSystem.Colors.answered
                        )
                    }
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }
    }
}

// 모던한 날짜 정보 행
struct ModernDateInfoRow: View {
    let icon: String
    let title: String
    let date: Date
    let color: Color
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(title)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .frame(width: 44, alignment: .leading)
            
            Text(DateFormatter.full.string(from: date))
                .font(DesignSystem.Typography.caption2)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .fontWeight(.medium)
                .lineLimit(1)
            
            Spacer()
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(color.opacity(0.1))
        .cornerRadius(DesignSystem.CornerRadius.medium)
    }
}

// MARK: - Storage Picker Components

// 모던한 보관소 선택 뷰
struct ModernStoragePickerView: View {
    let currentStorage: PrayerStorage
    let onStorageSelected: (PrayerStorage) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                // 헤더
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "arrow.up.arrow.down.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(DesignSystem.Colors.primary)
                    
                    Text(L.StoragePicker.title)
                        .font(DesignSystem.Typography.title2)
                        .foregroundColor(DesignSystem.Colors.primaryText)

                    Text(L.StoragePicker.description)
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, DesignSystem.Spacing.xl)
                
                // 보관소 옵션들
                VStack(spacing: DesignSystem.Spacing.md) {
                    ForEach(PrayerStorage.allCases, id: \.self) { storage in
                        if storage != currentStorage {
                            ModernStorageOptionCard(
                                storage: storage,
                                onTap: {
                                    onStorageSelected(storage)
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
                
                Spacer()
            }
            .navigationTitle(L.StoragePicker.title)
            .navigationBarTitleDisplayMode(.inline)
            .background(DesignSystem.Colors.background)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L.Button.cancel) {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                }
            }
        }
    }
}

// 모던한 보관소 선택 옵션 카드
struct ModernStorageOptionCard: View {
    let storage: PrayerStorage
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ModernCard(shadowStyle: DesignSystem.Shadow.medium) {
                HStack(spacing: DesignSystem.Spacing.lg) {
                    StatusIndicator(storage: storage, size: .medium)
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text(storage.displayName)
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(DesignSystem.Colors.primaryText)

                        Text(storage.storageDescription)
                            .font(DesignSystem.Typography.callout)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .foregroundColor(storage.color)
                }
                .padding(DesignSystem.Spacing.lg)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Favorite Components

// 즐겨찾기 토글 버튼
struct FavoriteButton: View {
    let isFavorite: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isFavorite ? Color.red : DesignSystem.Colors.secondaryText)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(isFavorite ? Color.red.opacity(0.1) : DesignSystem.Colors.secondaryBackground)
                )
                .overlay(
                    Circle()
                        .stroke(isFavorite ? Color.red.opacity(0.3) : Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFavorite)
        .accessibilityLabel(isFavorite ? L.Accessibility.favoriteRemove : L.Accessibility.favoriteAdd)
        .accessibilityHint(isFavorite ? L.Accessibility.favoriteRemoveHint : L.Accessibility.favoriteAddHint)
    }
} 