import SwiftUI

// MARK: - Keyboard Dismiss Extension

extension View {
    /// 키보드를 숨기는 함수
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Scroll Offset Tracking

/// 스크롤 오프셋을 추적하기 위한 PreferenceKey
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

/// 스크롤 오프셋 감지용 뷰
struct ScrollOffsetDetector: View {
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).minY)
        }
        .frame(height: 0)
    }
}

// MARK: - Inline Header (Apple Style)

/// iOS 전화 앱 스타일의 인라인 헤더 - 중앙 제목 + 하단 페이드 효과
/// fadeOpacity: 스크롤 위치에 따른 페이드 효과 투명도 (0.0 ~ 1.0)
struct InlineHeader: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let title: String
    var showFadeGradient: Bool = true
    var fadeOpacity: CGFloat = 1.0  // 스크롤 시 페이드 효과 투명도

    private var fontSize: CGFloat {
        horizontalSizeClass == .regular ? 20 : 17
    }

    var body: some View {
        VStack(spacing: 0) {
            // 헤더 영역
            Text(title)
                .font(.system(size: fontSize, weight: .semibold))
                .foregroundColor(DesignSystem.Colors.primaryText)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 11)
                .background(DesignSystem.Colors.background)

            // 페이드 그라데이션 (스크롤 시에만 나타남)
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
                .opacity(fadeOpacity)
                .allowsHitTesting(false)
            }
        }
    }
}

/// 스크롤 가능한 리스트용 헤더 컨테이너 - ZStack으로 오버레이
struct ScrollFadeHeaderContainer<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    private var fontSize: CGFloat {
        horizontalSizeClass == .regular ? 20 : 17
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
                    .font(.system(size: fontSize, weight: .semibold))
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
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                            .lineLimit(1)
                    }

                    CategoryTag(category: prayer.category, size: .small)

                    if prayer.hasAttachments {
                        HStack(spacing: 2) {
                            Image(systemName: prayer.imageAttachments.isEmpty ? "doc.fill" : "photo.fill")
                                .font(.caption2)
                            if prayer.attachmentCount > 1 {
                                Text("\(prayer.attachmentCount)")
                                    .font(.system(size: 9, weight: .bold))
                            }
                        }
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                    }

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
                StatusIndicator(storage: storage, size: .medium, style: .circleWhite)

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
                    StatusIndicator(storage: storage, size: .medium, style: .circleWhite)

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
    @Binding var notificationSettings: NotificationSettings
    @Binding var calendarEnabled: Bool  // 캘린더 추가 토글
    @Binding var calendarEventId: String?
    var prayer: Prayer?
    @State private var showDatePicker = false
    @State private var showNotificationSettings = false
    @State private var showCalendarPermissionAlert = false
    @State private var showCalendarSuccessAlert = false
    @State private var calendarAlertMessage = ""
    @State private var isCalendarLoading = false
    @State private var tempDate = Date()

    init(targetDate: Binding<Date?>, notificationEnabled: Binding<Bool>, notificationSettings: Binding<NotificationSettings>? = nil, calendarEnabled: Binding<Bool>? = nil, calendarEventId: Binding<String?>? = nil, prayer: Prayer? = nil) {
        self._targetDate = targetDate
        self._notificationEnabled = notificationEnabled
        self._notificationSettings = notificationSettings ?? .constant(NotificationSettings())
        self._calendarEnabled = calendarEnabled ?? .constant(false)
        self._calendarEventId = calendarEventId ?? .constant(nil)
        self.prayer = prayer
    }

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
                                notificationSettings = NotificationSettings()
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
                    Toggle(isOn: Binding(
                        get: { notificationEnabled },
                        set: { newValue in
                            notificationEnabled = newValue
                            notificationSettings.isEnabled = newValue
                        }
                    )) {
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

                    // 알림 세부설정 버튼 (알림이 활성화된 경우에만 표시)
                    if notificationEnabled {
                        Button(action: {
                            showNotificationSettings = true
                        }) {
                            HStack {
                                Image(systemName: "gearshape")
                                    .foregroundColor(DesignSystem.Colors.primary)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(L.Notification.advancedSettings)
                                        .font(DesignSystem.Typography.callout)
                                        .foregroundColor(DesignSystem.Colors.primaryText)

                                    Text(notificationSettingsSummary)
                                        .font(DesignSystem.Typography.caption2)
                                        .foregroundColor(DesignSystem.Colors.secondaryText)
                                        .lineLimit(1)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.Colors.tertiaryText)
                            }
                            .padding(DesignSystem.Spacing.md)
                            .background(DesignSystem.Colors.primary.opacity(0.05))
                            .cornerRadius(DesignSystem.CornerRadius.medium)
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                    .stroke(DesignSystem.Colors.primary.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    if notificationEnabled && !notificationSettings.isEnabled {
                        Text(L.DDay.notificationDescription)
                            .font(DesignSystem.Typography.caption2)
                            .foregroundColor(DesignSystem.Colors.tertiaryText)
                            .padding(.horizontal, DesignSystem.Spacing.sm)
                    }

                    // 캘린더 추가 토글 (알림 토글과 동일한 스타일)
                    Toggle(isOn: Binding(
                        get: { calendarEnabled },
                        set: { newValue in
                            if newValue && !CalendarManager.shared.hasCalendarAccess {
                                // 권한 요청
                                CalendarManager.shared.requestAccess { granted, _ in
                                    if granted {
                                        calendarEnabled = true
                                    } else {
                                        showCalendarPermissionAlert = true
                                    }
                                }
                            } else {
                                calendarEnabled = newValue
                            }
                        }
                    )) {
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            Image(systemName: calendarEnabled ? "calendar.badge.checkmark" : "calendar")
                                .foregroundColor(calendarEnabled ? DesignSystem.Colors.primary : DesignSystem.Colors.secondaryText)

                            Text(L.Calendar.addToCalendar)
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(DesignSystem.Colors.primaryText)
                        }
                    }
                    .tint(DesignSystem.Colors.primary)
                    .padding(DesignSystem.Spacing.md)
                    .background(DesignSystem.Colors.secondaryBackground)
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))

                // 기존 캘린더 버튼 (기도 편집/상세 화면에서만 표시)
                if prayer != nil {
                    calendarButton
                }
            }
        }
        .animation(DesignSystem.Animation.quick, value: targetDate != nil)
        .animation(DesignSystem.Animation.quick, value: notificationEnabled)
        .sheet(isPresented: $showDatePicker) {
            DDayDatePickerSheet(
                selectedDate: $tempDate,
                onSave: {
                    targetDate = tempDate
                },
                onCancel: {}
            )
        }
        .sheet(isPresented: $showNotificationSettings) {
            NotificationSettingsView(settings: $notificationSettings)
        }
        .alert(L.Calendar.permissionRequired, isPresented: $showCalendarPermissionAlert) {
            Button(L.Calendar.openSettings) {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button(L.Button.cancel, role: .cancel) { }
        } message: {
            Text(L.Calendar.permissionMessage)
        }
        .alert(L.Alert.notification, isPresented: $showCalendarSuccessAlert) {
            Button(L.Button.confirm) { }
        } message: {
            Text(calendarAlertMessage)
        }
    }

    // MARK: - Calendar Button

    @ViewBuilder
    private var calendarButton: some View {
        if let date = targetDate {
            Button(action: {
                handleCalendarAction(targetDate: date)
            }) {
                HStack {
                    if isCalendarLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: isAddedToCalendar ? "calendar.badge.checkmark" : "calendar.badge.plus")
                            .font(.title3)
                            .foregroundColor(isAddedToCalendar ? DesignSystem.Colors.answered : DesignSystem.Colors.primary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(isAddedToCalendar ? L.Calendar.addedToCalendar : L.Calendar.addToCalendar)
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.primaryText)

                        if isAddedToCalendar {
                            Text(L.Calendar.removeFromCalendar)
                                .font(DesignSystem.Typography.caption2)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.tertiaryText)
                }
                .padding(DesignSystem.Spacing.md)
                .background(isAddedToCalendar ? DesignSystem.Colors.answered.opacity(0.1) : DesignSystem.Colors.secondaryBackground)
                .cornerRadius(DesignSystem.CornerRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                        .stroke(isAddedToCalendar ? DesignSystem.Colors.answered.opacity(0.3) : Color.clear, lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isCalendarLoading)
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    /// 캘린더에 추가되어 있는지 확인
    private var isAddedToCalendar: Bool {
        guard let eventId = calendarEventId else { return false }
        return CalendarManager.shared.eventExists(withIdentifier: eventId)
    }

    /// 캘린더 액션 처리 (추가/삭제)
    private func handleCalendarAction(targetDate: Date) {
        if isAddedToCalendar, let eventId = calendarEventId {
            // 캘린더에서 삭제
            isCalendarLoading = true
            CalendarManager.shared.removeEvent(withIdentifier: eventId) { result in
                isCalendarLoading = false
                switch result {
                case .success:
                    calendarEventId = nil
                    calendarAlertMessage = L.Calendar.removeSuccess
                    showCalendarSuccessAlert = true
                case .failure(let error):
                    calendarAlertMessage = error.localizedDescription
                    showCalendarSuccessAlert = true
                }
            }
        } else {
            // 캘린더에 추가
            guard let prayer = prayer else {
                calendarAlertMessage = L.Calendar.addFailed
                showCalendarSuccessAlert = true
                return
            }

            // 권한 확인
            if !CalendarManager.shared.hasCalendarAccess {
                CalendarManager.shared.requestAccess { granted, _ in
                    if granted {
                        addToCalendar(prayer: prayer, targetDate: targetDate)
                    } else {
                        showCalendarPermissionAlert = true
                    }
                }
            } else {
                addToCalendar(prayer: prayer, targetDate: targetDate)
            }
        }
    }

    /// 캘린더에 이벤트 추가
    private func addToCalendar(prayer: Prayer, targetDate: Date) {
        isCalendarLoading = true
        CalendarManager.shared.addDDayEvent(for: prayer, targetDate: targetDate, addReminder: notificationEnabled) { result in
            isCalendarLoading = false
            switch result {
            case .success(let eventId):
                calendarEventId = eventId
                calendarAlertMessage = L.Calendar.addSuccess
                showCalendarSuccessAlert = true
            case .failure(let error):
                if case .permissionDenied = error {
                    showCalendarPermissionAlert = true
                } else {
                    calendarAlertMessage = error.localizedDescription
                    showCalendarSuccessAlert = true
                }
            }
        }
    }

    /// 알림 설정 요약 텍스트
    private var notificationSettingsSummary: String {
        if notificationSettings.isEnabled {
            return "\(notificationSettings.timeDisplayText) • \(notificationSettings.reminderDaysDisplayText)"
        } else {
            return L.DDay.notificationDescription
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

/// 음성 녹음 오버레이 - 녹음 중 전체 화면 표시 (AI 정리 기능 포함)
struct VoiceRecordingOverlay: View {
    @Bindable var speechManager: SpeechRecognitionManager
    let onUseText: (String) -> Void
    let onCancel: () -> Void

    @State private var pulseAnimation = false
    @State private var isAIProcessing = false
    @State private var showAISummaryPreview = false
    @State private var summarizedText = ""
    @State private var aiErrorMessage: String?

    /// AI 사용자 설정 (AppStorage 연동)
    @AppStorage("aiFeatureEnabled") private var isAIUserEnabled: Bool = true

    /// AI 기능 사용 가능 여부 (시스템 지원 + 사용자 활성화)
    private var isAIAvailable: Bool {
        AIFeatureAvailability.isSupported
    }

    /// 시스템이 AI를 지원하는지 여부 (사용자 설정과 무관)
    private var isAISystemSupported: Bool {
        AIFeatureAvailability.isSystemSupported
    }

    var body: some View {
        ZStack {
            // 배경 블러
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    // 배경 탭으로 취소
                    if !speechManager.isRecording && !isAIProcessing {
                        onCancel()
                    }
                }
                .zIndex(0)

            VStack(spacing: DesignSystem.Spacing.xxl) {
                // AI 토글 버튼 (시스템이 지원하는 경우에만 표시)
                if isAISystemSupported {
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isAIUserEnabled.toggle()
                            }
                        }) {
                            HStack(spacing: DesignSystem.Spacing.xs) {
                                Image(systemName: isAIUserEnabled ? "sparkles" : "sparkles.slash")
                                    .font(.body)
                                Text(isAIUserEnabled ? "AI ON" : "AI OFF")
                                    .font(DesignSystem.Typography.callout)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(isAIUserEnabled ? .cyan : .white.opacity(0.5))
                            .padding(.horizontal, DesignSystem.Spacing.lg)
                            .padding(.vertical, DesignSystem.Spacing.md)
                            .background(
                                isAIUserEnabled
                                    ? LinearGradient(
                                        colors: [.purple.opacity(0.3), .blue.opacity(0.3), .cyan.opacity(0.3)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    : LinearGradient(
                                        colors: [.white.opacity(0.1), .white.opacity(0.1)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                            )
                            .cornerRadius(DesignSystem.CornerRadius.medium)
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                    .stroke(
                                        isAIUserEnabled
                                            ? LinearGradient(
                                                colors: [.purple.opacity(0.5), .cyan.opacity(0.5)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                            : LinearGradient(
                                                colors: [.white.opacity(0.2), .white.opacity(0.2)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ),
                                        lineWidth: 1
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(isAIProcessing)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    .padding(.top, DesignSystem.Spacing.xl)
                }

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

                    // AI 처리 중 애니메이션
                    if isAIProcessing {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.purple.opacity(0.3), .blue.opacity(0.3), .cyan.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 160, height: 160)
                            .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                            .opacity(pulseAnimation ? 0 : 0.5)
                            .animation(
                                .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                                value: pulseAnimation
                            )
                    }

                    // 마이크/AI 버튼
                    Button(action: {
                        if !isAIProcessing {
                            speechManager.toggleRecording()
                        }
                    }) {
                        Circle()
                            .fill(
                                isAIProcessing
                                    ? LinearGradient(
                                        colors: [.purple, .blue, .cyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    : LinearGradient(
                                        colors: [speechManager.isRecording ? .red : DesignSystem.Colors.primary,
                                                 speechManager.isRecording ? .red : DesignSystem.Colors.primary],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                            )
                            .frame(width: 120, height: 120)
                            .shadow(
                                color: (speechManager.isRecording ? Color.red : DesignSystem.Colors.primary).opacity(0.4),
                                radius: 20,
                                x: 0,
                                y: 10
                            )
                            .overlay(
                                Group {
                                    if isAIProcessing {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(2)
                                    } else {
                                        Image(systemName: speechManager.isRecording ? "stop.fill" : "mic.fill")
                                            .font(.system(size: 50, weight: .medium))
                                            .foregroundColor(.white)
                                    }
                                }
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(isAIProcessing)
                }
                .onAppear {
                    pulseAnimation = true
                }

                // 상태 텍스트
                VStack(spacing: DesignSystem.Spacing.md) {
                    if isAIProcessing {
                        Text(L.AI.summarizing)
                            .font(DesignSystem.Typography.headline)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .blue, .cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    } else {
                        Text(speechManager.isRecording ? L.Voice.listening : L.Voice.tapToStart)
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(.white)
                    }

                    if let errorMessage = speechManager.errorMessage ?? aiErrorMessage {
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
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(DesignSystem.CornerRadius.medium)
                        .padding(.horizontal, DesignSystem.Spacing.xl)
                    }
                }

                Spacer()

                // 하단 버튼
                VStack(spacing: DesignSystem.Spacing.md) {
                    // 녹음 중일 때 명시적 중지 버튼
                    if speechManager.isRecording {
                        Button(action: {
                            speechManager.stopRecording()
                        }) {
                            HStack(spacing: DesignSystem.Spacing.sm) {
                                Image(systemName: "stop.circle.fill")
                                Text(L.Voice.stopRecording)
                            }
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(.red)
                            .padding(.horizontal, DesignSystem.Spacing.xl)
                            .padding(.vertical, DesignSystem.Spacing.md)
                            .background(Color.red.opacity(0.2))
                            .cornerRadius(DesignSystem.CornerRadius.large)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    // AI 정리 버튼 (텍스트가 있고 녹음이 완료된 경우에만)
                    if !speechManager.recognizedText.isEmpty && !speechManager.isRecording && isAIAvailable {
                        Button(action: {
                            performAISummarization()
                        }) {
                            HStack(spacing: DesignSystem.Spacing.sm) {
                                Image(systemName: "sparkles")
                                Text(L.AI.summarize)
                            }
                            .font(DesignSystem.Typography.headline)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .blue, .cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .padding(.horizontal, DesignSystem.Spacing.xl)
                            .padding(.vertical, DesignSystem.Spacing.md)
                            .background(
                                LinearGradient(
                                    colors: [.purple.opacity(0.2), .blue.opacity(0.2), .cyan.opacity(0.2)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(DesignSystem.CornerRadius.large)
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.purple.opacity(0.5), .blue.opacity(0.5), .cyan.opacity(0.5)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(isAIProcessing)
                    }

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
                        .disabled(isAIProcessing)

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
                            .disabled(isAIProcessing)
                        }
                    }
                }
                .padding(.bottom, DesignSystem.Spacing.xxxl)
            }
            .zIndex(1)
        }
        .animation(DesignSystem.Animation.standard, value: speechManager.isRecording)
        .animation(DesignSystem.Animation.standard, value: speechManager.recognizedText)
        .animation(DesignSystem.Animation.standard, value: isAIProcessing)
        .sheet(isPresented: $showAISummaryPreview) {
            AISummaryPreviewView(
                originalText: speechManager.recognizedText,
                summarizedText: $summarizedText,
                onApply: {
                    onUseText(summarizedText)
                    speechManager.clearText()
                    showAISummaryPreview = false
                },
                onCancel: {
                    showAISummaryPreview = false
                },
                onRetry: {
                    showAISummaryPreview = false
                    performAISummarization()
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - AI Summarization

    private func performAISummarization() {
        guard !speechManager.recognizedText.isEmpty else { return }

        isAIProcessing = true
        aiErrorMessage = nil

        Task {
            do {
                if #available(iOS 26.0, *) {
                    let result = try await AISummarizationManager.shared.summarize(text: speechManager.recognizedText)
                    await MainActor.run {
                        summarizedText = result
                        isAIProcessing = false
                        showAISummaryPreview = true
                    }
                } else {
                    await MainActor.run {
                        aiErrorMessage = L.AI.errorRequiresiOS26
                        isAIProcessing = false
                    }
                }
            } catch {
                await MainActor.run {
                    aiErrorMessage = error.localizedDescription
                    isAIProcessing = false
                }
            }
        }
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