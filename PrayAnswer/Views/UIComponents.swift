import SwiftUI

// MARK: - Keyboard Dismiss Extension

extension View {
    /// 키보드를 숨기는 함수
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Inline Header (Apple Style)

/// iOS 전화 앱 스타일의 인라인 헤더 - 중앙 제목 + 하단 페이드 효과
struct InlineHeader: View {
    let title: String
    var showFadeGradient: Bool = true

    var body: some View {
        VStack(spacing: 0) {
            // 헤더 영역
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(DesignSystem.Colors.primaryText)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 11)
                .background(DesignSystem.Colors.background)

            // 페이드 그라데이션 (컨텐츠가 헤더 아래로 스크롤될 때 자연스럽게 흐려지는 효과)
            if showFadeGradient {
                LinearGradient(
                    gradient: Gradient(colors: [
                        DesignSystem.Colors.background,
                        DesignSystem.Colors.background.opacity(0.8),
                        DesignSystem.Colors.background.opacity(0.0)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 16)
                .allowsHitTesting(false)
            }
        }
    }
}

/// 스크롤 가능한 리스트용 헤더 컨테이너 - ZStack으로 오버레이
struct ScrollFadeHeaderContainer<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .top) {
            // 스크롤 컨텐츠
            content
                .padding(.top, 50) // 헤더 높이만큼 패딩

            // 고정 헤더 + 페이드 오버레이
            VStack(spacing: 0) {
                // 헤더 영역
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.primaryText)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(height: 44)
                    .background(
                        DesignSystem.Colors.background
                            .opacity(0.98)
                    )
                    .background(.ultraThinMaterial)

                // 하단 구분선
                Rectangle()
                    .fill(DesignSystem.Colors.tertiaryText.opacity(0.15))
                    .frame(height: 0.5)

                // 페이드 그라데이션
                LinearGradient(
                    gradient: Gradient(colors: [
                        DesignSystem.Colors.background.opacity(0.85),
                        DesignSystem.Colors.background.opacity(0.4),
                        DesignSystem.Colors.background.opacity(0.0)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 24)
                .allowsHitTesting(false)

                Spacer()
            }
        }
    }
}

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
                // 상단: 상태 아이콘 + 대상자 + 카테고리 + 즐겨찾기
                HStack(alignment: .center, spacing: DesignSystem.Spacing.sm) {
                    StatusIndicator(storage: prayer.storage, size: .medium)

                    // 대상자 표시 (있는 경우)
                    if prayer.hasTarget {
                        Text(prayer.target)
                            .font(DesignSystem.Typography.callout)
                            .fontWeight(.medium)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                            .lineLimit(1)
                    }

                    CategoryTag(category: prayer.category, size: .small)

                    Spacer()

                    if let onFavoriteToggle = onFavoriteToggle {
                        FavoriteButton(isFavorite: prayer.isFavorite) {
                            onFavoriteToggle()
                        }
                    }
                }

                // 중간: 기도 내용 (전체 너비 사용, 3줄)
                Text(prayer.content)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // 하단: D-Day + 날짜
                HStack {
                    // D-Day 배지 표시
                    if prayer.hasTargetDate {
                        DDayBadge(prayer: prayer, size: .small)
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

// MARK: - D-Day Components

/// D-Day 표시 배지 컴포넌트
struct DDayBadge: View {
    let prayer: Prayer

    enum Size {
        case small
        case medium
        case large

        var font: Font {
            switch self {
            case .small: return DesignSystem.Typography.caption2
            case .medium: return DesignSystem.Typography.caption
            case .large: return DesignSystem.Typography.callout
            }
        }

        var padding: CGFloat {
            switch self {
            case .small: return DesignSystem.Spacing.xs
            case .medium: return DesignSystem.Spacing.sm
            case .large: return DesignSystem.Spacing.md
            }
        }

        var iconSize: CGFloat {
            switch self {
            case .small: return 10
            case .medium: return 12
            case .large: return 14
            }
        }
    }

    var size: Size = .medium

    var body: some View {
        if let dDayText = prayer.dDayDisplayText {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: statusIcon)
                    .font(.system(size: size.iconSize, weight: .semibold))

                Text(dDayText)
                    .font(size.font)
                    .fontWeight(.bold)
            }
            .foregroundColor(statusColor)
            .padding(.horizontal, size.padding + 2)
            .padding(.vertical, size.padding)
            .background(statusColor.opacity(0.15))
            .cornerRadius(DesignSystem.CornerRadius.small)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .stroke(statusColor.opacity(0.3), lineWidth: 1)
            )
        }
    }

    private var statusIcon: String {
        if prayer.isDDay {
            return "star.fill"
        } else if prayer.isDDayPassed {
            return "clock.badge.exclamationmark"
        } else if prayer.isDDayApproaching {
            return "bell.fill"
        } else {
            return "calendar"
        }
    }

    private var statusColor: Color {
        if prayer.isDDay {
            return DesignSystem.Colors.answered // 오늘 D-Day - 강조 색상
        } else if prayer.isDDayPassed {
            return DesignSystem.Colors.notAnswered // D-Day 지남 - 회색/빨간색
        } else if prayer.isDDayApproaching {
            return Color.orange // D-Day 임박 - 주황색
        } else {
            return DesignSystem.Colors.primary // 일반 - 기본 색상
        }
    }
}

/// D-Day 설정 섹션 (폼에서 사용)
struct DDayFormSection: View {
    @Binding var targetDate: Date?
    @Binding var notificationEnabled: Bool
    @State private var showDatePicker = false
    @State private var tempDate = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // 섹션 타이틀
            Text(L.DDay.title)
                .font(DesignSystem.Typography.callout)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .fontWeight(.medium)

            // 날짜 선택 버튼
            Button(action: {
                if targetDate == nil {
                    tempDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
                } else {
                    tempDate = targetDate!
                }
                showDatePicker = true
            }) {
                HStack {
                    Image(systemName: targetDate == nil ? "calendar.badge.plus" : "calendar")
                        .font(.title3)
                        .foregroundColor(DesignSystem.Colors.primary)

                    if let date = targetDate {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(DateFormatter.compact.string(from: date))
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(DesignSystem.Colors.primaryText)

                            if let daysRemaining = daysUntilDate(date) {
                                Text(dDayText(days: daysRemaining))
                                    .font(DesignSystem.Typography.caption2)
                                    .foregroundColor(dDayColor(days: daysRemaining))
                            }
                        }
                    } else {
                        Text(L.DDay.setTargetDate)
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }

                    Spacer()

                    if targetDate != nil {
                        Button(action: {
                            withAnimation {
                                targetDate = nil
                                notificationEnabled = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(DesignSystem.Colors.tertiaryText)
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                }
                .padding(DesignSystem.Spacing.md)
                .background(DesignSystem.Colors.secondaryBackground)
                .cornerRadius(DesignSystem.CornerRadius.medium)
            }
            .buttonStyle(PlainButtonStyle())

            // 알림 토글 (날짜가 설정된 경우에만 표시)
            if targetDate != nil {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Toggle(isOn: $notificationEnabled) {
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            Image(systemName: notificationEnabled ? "bell.fill" : "bell")
                                .foregroundColor(notificationEnabled ? DesignSystem.Colors.primary : DesignSystem.Colors.secondaryText)

                            Text(L.DDay.enableNotification)
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(DesignSystem.Colors.primaryText)
                        }
                    }
                    .tint(DesignSystem.Colors.primary)
                    .padding(DesignSystem.Spacing.md)
                    .background(DesignSystem.Colors.secondaryBackground)
                    .cornerRadius(DesignSystem.CornerRadius.medium)

                    if notificationEnabled {
                        Text(L.DDay.notificationDescription)
                            .font(DesignSystem.Typography.caption2)
                            .foregroundColor(DesignSystem.Colors.tertiaryText)
                            .padding(.horizontal, DesignSystem.Spacing.sm)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(DesignSystem.Animation.quick, value: targetDate != nil)
        .sheet(isPresented: $showDatePicker) {
            DDayDatePickerSheet(
                selectedDate: $tempDate,
                onSave: {
                    targetDate = tempDate
                },
                onCancel: {}
            )
        }
    }

    private func daysUntilDate(_ date: Date) -> Int? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: date)
        return calendar.dateComponents([.day], from: today, to: target).day
    }

    private func dDayText(days: Int) -> String {
        if days == 0 {
            return "D-Day"
        } else if days > 0 {
            return "D-\(days)"
        } else {
            return "D+\(abs(days))"
        }
    }

    private func dDayColor(days: Int) -> Color {
        if days == 0 {
            return DesignSystem.Colors.answered
        } else if days < 0 {
            return DesignSystem.Colors.notAnswered
        } else if days <= 7 {
            return Color.orange
        } else {
            return DesignSystem.Colors.primary
        }
    }
}

/// D-Day 날짜 선택 시트
struct DDayDatePickerSheet: View {
    @Binding var selectedDate: Date
    let onSave: () -> Void
    let onCancel: () -> Void
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                // 헤더
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 50))
                        .foregroundColor(DesignSystem.Colors.primary)

                    Text(L.DDay.targetDate)
                        .font(DesignSystem.Typography.title2)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                }
                .padding(.top, DesignSystem.Spacing.xl)

                // D-Day 미리보기
                if let days = daysUntilDate(selectedDate) {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Text(dDayText(days: days))
                            .font(DesignSystem.Typography.title1)
                            .fontWeight(.bold)
                            .foregroundColor(dDayColor(days: days))
                    }
                    .padding(DesignSystem.Spacing.md)
                    .background(dDayColor(days: days).opacity(0.1))
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                }

                // 날짜 피커
                DatePicker(
                    "",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding(.horizontal, DesignSystem.Spacing.lg)

                Spacer()
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle(L.DDay.setTargetDate)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L.Button.cancel) {
                        onCancel()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L.Button.done) {
                        onSave()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.primary)
                }
            }
        }
    }

    private func daysUntilDate(_ date: Date) -> Int? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: date)
        return calendar.dateComponents([.day], from: today, to: target).day
    }

    private func dDayText(days: Int) -> String {
        if days == 0 {
            return "D-Day"
        } else if days > 0 {
            return "D-\(days)"
        } else {
            return "D+\(abs(days))"
        }
    }

    private func dDayColor(days: Int) -> Color {
        if days == 0 {
            return DesignSystem.Colors.answered
        } else if days < 0 {
            return DesignSystem.Colors.notAnswered
        } else if days <= 7 {
            return Color.orange
        } else {
            return DesignSystem.Colors.primary
        }
    }
}

// MARK: - Voice Recording Components

/// 음성 녹음 버튼 - 기도 내용 입력 폼에서 사용
struct VoiceRecordingButton: View {
    let isRecording: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: isRecording ? "mic.fill" : "mic")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(isRecording ? .white : DesignSystem.Colors.primary)

                if isRecording {
                    Text(L.Voice.recording)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                isRecording ?
                    DesignSystem.Colors.primary :
                    DesignSystem.Colors.primary.opacity(0.1)
            )
            .cornerRadius(DesignSystem.CornerRadius.large)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                    .stroke(
                        DesignSystem.Colors.primary.opacity(isRecording ? 0.5 : 0.3),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isRecording)
        .accessibilityLabel(L.Voice.microphoneButton)
        .accessibilityHint(isRecording ? L.Voice.tapToStop : L.Voice.tapToStart)
    }
}

/// 음성 녹음 오버레이 - 녹음 중 전체 화면 표시
struct VoiceRecordingOverlay: View {
    @Bindable var speechManager: SpeechRecognitionManager
    let onUseText: (String) -> Void
    let onCancel: () -> Void

    @State private var pulseAnimation = false

    var body: some View {
        ZStack {
            // 배경 블러
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    // 배경 탭으로 취소
                    if !speechManager.isRecording {
                        onCancel()
                    }
                }

            VStack(spacing: DesignSystem.Spacing.xxl) {
                Spacer()

                // 녹음 상태 인디케이터
                ZStack {
                    // 펄스 애니메이션 원
                    if speechManager.isRecording {
                        Circle()
                            .fill(DesignSystem.Colors.primary.opacity(0.3))
                            .frame(width: 160, height: 160)
                            .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                            .opacity(pulseAnimation ? 0 : 0.5)
                            .animation(
                                .easeInOut(duration: 1.0).repeatForever(autoreverses: false),
                                value: pulseAnimation
                            )

                        Circle()
                            .fill(DesignSystem.Colors.primary.opacity(0.2))
                            .frame(width: 140, height: 140)
                            .scaleEffect(pulseAnimation ? 1.3 : 1.0)
                            .opacity(pulseAnimation ? 0 : 0.3)
                            .animation(
                                .easeInOut(duration: 1.0).repeatForever(autoreverses: false).delay(0.3),
                                value: pulseAnimation
                            )
                    }

                    // 마이크 버튼
                    Button(action: {
                        speechManager.toggleRecording()
                    }) {
                        Circle()
                            .fill(speechManager.isRecording ? Color.red : DesignSystem.Colors.primary)
                            .frame(width: 120, height: 120)
                            .shadow(
                                color: (speechManager.isRecording ? Color.red : DesignSystem.Colors.primary).opacity(0.4),
                                radius: 20,
                                x: 0,
                                y: 10
                            )
                            .overlay(
                                Image(systemName: speechManager.isRecording ? "stop.fill" : "mic.fill")
                                    .font(.system(size: 50, weight: .medium))
                                    .foregroundColor(.white)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .onAppear {
                    pulseAnimation = true
                }

                // 상태 텍스트
                VStack(spacing: DesignSystem.Spacing.md) {
                    Text(speechManager.isRecording ? L.Voice.listening : L.Voice.tapToStart)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(.white)

                    if let errorMessage = speechManager.errorMessage {
                        Text(errorMessage)
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(Color.red.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, DesignSystem.Spacing.xl)
                    }
                }

                // 인식된 텍스트 표시
                if !speechManager.recognizedText.isEmpty {
                    VStack(spacing: DesignSystem.Spacing.md) {
                        ScrollView {
                            Text(speechManager.recognizedText)
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(DesignSystem.Spacing.lg)
                        }
                        .frame(maxHeight: 200)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(DesignSystem.CornerRadius.medium)
                        .padding(.horizontal, DesignSystem.Spacing.xl)
                    }
                }

                Spacer()

                // 하단 버튼
                HStack(spacing: DesignSystem.Spacing.xl) {
                    // 취소 버튼
                    Button(action: {
                        speechManager.stopRecording()
                        speechManager.clearText()
                        onCancel()
                    }) {
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            Image(systemName: "xmark")
                            Text(L.Voice.cancel)
                        }
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, DesignSystem.Spacing.xl)
                        .padding(.vertical, DesignSystem.Spacing.md)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(DesignSystem.CornerRadius.large)
                    }
                    .buttonStyle(PlainButtonStyle())

                    // 텍스트 사용 버튼 (텍스트가 있을 때만)
                    if !speechManager.recognizedText.isEmpty && !speechManager.isRecording {
                        Button(action: {
                            onUseText(speechManager.recognizedText)
                            speechManager.clearText()
                        }) {
                            HStack(spacing: DesignSystem.Spacing.sm) {
                                Image(systemName: "checkmark")
                                Text(L.Voice.useText)
                            }
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, DesignSystem.Spacing.xl)
                            .padding(.vertical, DesignSystem.Spacing.md)
                            .background(DesignSystem.Colors.primary)
                            .cornerRadius(DesignSystem.CornerRadius.large)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.bottom, DesignSystem.Spacing.xxxl)
            }
        }
        .animation(DesignSystem.Animation.standard, value: speechManager.isRecording)
        .animation(DesignSystem.Animation.standard, value: speechManager.recognizedText)
    }
}

/// 투명 배경 뷰 (fullScreenCover용)
struct ClearBackgroundView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

/// 권한 요청 알림 뷰
struct VoicePermissionAlert: View {
    let onOpenSettings: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Image(systemName: "mic.slash.fill")
                .font(.system(size: 50))
                .foregroundColor(DesignSystem.Colors.notAnswered)

            VStack(spacing: DesignSystem.Spacing.md) {
                Text(L.Voice.permissionRequired)
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.primaryText)

                Text(L.Voice.microphonePermission)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: DesignSystem.Spacing.lg) {
                Button(action: onCancel) {
                    Text(L.Button.cancel)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .padding(.horizontal, DesignSystem.Spacing.xl)
                        .padding(.vertical, DesignSystem.Spacing.md)
                        .background(DesignSystem.Colors.secondaryBackground)
                        .cornerRadius(DesignSystem.CornerRadius.medium)
                }

                Button(action: onOpenSettings) {
                    Text(L.Voice.openSettings)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, DesignSystem.Spacing.xl)
                        .padding(.vertical, DesignSystem.Spacing.md)
                        .background(DesignSystem.Colors.primary)
                        .cornerRadius(DesignSystem.CornerRadius.medium)
                }
            }
        }
        .padding(DesignSystem.Spacing.xxl)
        .background(DesignSystem.Colors.cardBackground)
        .cornerRadius(DesignSystem.CornerRadius.large)
        .shadow(color: DesignSystem.Shadow.large.color, radius: DesignSystem.Shadow.large.radius, x: 0, y: 4)
        .padding(.horizontal, DesignSystem.Spacing.xl)
    }
} 