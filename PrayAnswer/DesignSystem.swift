import SwiftUI

// MARK: - Design System

struct DesignSystem {
    
    // MARK: - Colors
    struct Colors {
        // Primary Colors
        static let primary = Color("PrimaryColor")
        static let secondary = Color("SecondaryColor")
        
        // Background Colors
        static let background = Color(.systemBackground)
        static let secondaryBackground = Color(.secondarySystemBackground)
        static let cardBackground = Color(.tertiarySystemBackground)
        
        // Semantic Colors
        static let wait = Color("WaitColor")
        static let answered = Color("AnsweredColor")
        static let notAnswered = Color("NotAnsweredColor")
        
        // Category Colors
        static let personal = Color("PersonalColor")
        static let family = Color("FamilyColor")
        static let health = Color("HealthColor")
        static let work = Color("WorkColor")
        static let relationship = Color("RelationshipColor")
        static let thanksgiving = Color("ThanksgivingColor")
        static let vision = Color("VisionColor")
        static let other = Color("OtherColor")
        
        // Text Colors
        static let primaryText = Color(.label)
        static let secondaryText = Color(.secondaryLabel)
        static let tertiaryText = Color(.tertiaryLabel)
    }
    
    // MARK: - Typography
    struct Typography {
        static let largeTitle = Font.largeTitle.weight(.bold)
        static let title1 = Font.title.weight(.bold)
        static let title2 = Font.title2.weight(.semibold)
        static let title3 = Font.title3.weight(.semibold)
        static let headline = Font.headline.weight(.semibold)
        static let body = Font.body.weight(.regular)
        static let callout = Font.callout.weight(.medium)
        static let subheadline = Font.subheadline.weight(.medium)
        static let footnote = Font.footnote.weight(.regular)
        static let caption = Font.caption.weight(.medium)
        static let caption2 = Font.caption2.weight(.regular)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
        static let huge: CGFloat = 40
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 20
    }
    
    // MARK: - Shadows
    struct Shadow {
        static let small = (color: Color.black.opacity(0.05), radius: CGFloat(2), x: CGFloat(0), y: CGFloat(1))
        static let medium = (color: Color.black.opacity(0.1), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(2))
        static let large = (color: Color.black.opacity(0.15), radius: CGFloat(16), x: CGFloat(0), y: CGFloat(4))
    }
    
    // MARK: - Animation
    struct Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
    }
}

// MARK: - Storage Utilities

extension PrayerStorage {
    var color: Color {
        switch self {
        case .wait: return DesignSystem.Colors.wait
        case .yes: return DesignSystem.Colors.answered
        case .no: return DesignSystem.Colors.notAnswered
        }
    }
    
    var description: String {
        switch self {
        case .wait: return "하나님의 응답을 기다리는 기도들"
        case .yes: return "응답받은 감사한 기도들"
        case .no: return "다른 계획이 있으셨던 기도들"
        }
    }
    
    var icon: String {
        switch self {
        case .wait: return "clock.fill"
        case .yes: return "checkmark.circle.fill"
        case .no: return "xmark.circle.fill"
        }
    }
}

// MARK: - Category Utilities

extension PrayerCategory {
    var color: Color {
        switch self {
        case .personal: return DesignSystem.Colors.personal
        case .family: return DesignSystem.Colors.family
        case .health: return DesignSystem.Colors.health
        case .work: return DesignSystem.Colors.work
        case .relationship: return DesignSystem.Colors.relationship
        case .thanksgiving: return DesignSystem.Colors.thanksgiving
        case .vision: return DesignSystem.Colors.vision
        case .other: return DesignSystem.Colors.other
        }
    }
}

// MARK: - Date Formatters

extension DateFormatter {
    static let compact: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy.MM.dd"
        return formatter
    }()
    
    static let full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy.MM.dd HH:mm"
        return formatter
    }()
    
    static let detailed: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

// MARK: - Core UI Components

// 모던한 카드 컴포넌트
struct ModernCard<Content: View>: View {
    let content: Content
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let shadowStyle: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat)
    
    init(
        backgroundColor: Color = DesignSystem.Colors.cardBackground,
        cornerRadius: CGFloat = DesignSystem.CornerRadius.large,
        shadowStyle: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = DesignSystem.Shadow.medium,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.shadowStyle = shadowStyle
    }
    
    var body: some View {
        content
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(
                color: shadowStyle.color,
                radius: shadowStyle.radius,
                x: shadowStyle.x,
                y: shadowStyle.y
            )
    }
}

// 모던한 버튼 컴포넌트
struct ModernButton: View {
    let title: String
    let style: ButtonStyle
    let size: ButtonSize
    let action: () -> Void
    
    enum ButtonStyle {
        case primary, secondary, tertiary, success, destructive
        
        var backgroundColor: Color {
            switch self {
            case .primary: return DesignSystem.Colors.primary
            case .secondary: return DesignSystem.Colors.secondary
            case .tertiary: return DesignSystem.Colors.cardBackground
            case .success: return DesignSystem.Colors.answered
            case .destructive: return DesignSystem.Colors.notAnswered
            }
        }
        
        var textColor: Color {
            switch self {
            case .primary, .secondary, .success, .destructive: return .white
            case .tertiary: return DesignSystem.Colors.primaryText
            }
        }
    }
    
    enum ButtonSize {
        case small, medium, large
        
        var padding: (vertical: CGFloat, horizontal: CGFloat) {
            switch self {
            case .small: return (DesignSystem.Spacing.sm, DesignSystem.Spacing.md)
            case .medium: return (DesignSystem.Spacing.md, DesignSystem.Spacing.lg)
            case .large: return (DesignSystem.Spacing.lg, DesignSystem.Spacing.xl)
            }
        }
        
        var font: Font {
            switch self {
            case .small: return DesignSystem.Typography.caption
            case .medium: return DesignSystem.Typography.callout
            case .large: return DesignSystem.Typography.headline
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(size.font)
                .fontWeight(.semibold)
                .foregroundColor(style.textColor)
                .padding(.vertical, size.padding.vertical)
                .padding(.horizontal, size.padding.horizontal)
                .frame(maxWidth: .infinity)
                .background(style.backgroundColor)
                .cornerRadius(DesignSystem.CornerRadius.medium)
                .shadow(
                    color: style.backgroundColor.opacity(0.3),
                    radius: DesignSystem.Shadow.medium.radius,
                    x: DesignSystem.Shadow.medium.x,
                    y: DesignSystem.Shadow.medium.y
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 카테고리 태그 컴포넌트
struct CategoryTag: View {
    let category: PrayerCategory
    let size: TagSize
    
    enum TagSize {
        case small, medium
        
        var padding: (vertical: CGFloat, horizontal: CGFloat) {
            switch self {
            case .small: return (DesignSystem.Spacing.xs, DesignSystem.Spacing.sm)
            case .medium: return (DesignSystem.Spacing.sm, DesignSystem.Spacing.md)
            }
        }
        
        var font: Font {
            switch self {
            case .small: return DesignSystem.Typography.caption2
            case .medium: return DesignSystem.Typography.caption
            }
        }
    }
    
    var body: some View {
        Text(category.displayName)
            .font(size.font)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.vertical, size.padding.vertical)
            .padding(.horizontal, size.padding.horizontal)
            .background(category.color)
            .cornerRadius(DesignSystem.CornerRadius.small)
    }
}

// 상태 인디케이터 컴포넌트
struct StatusIndicator: View {
    let storage: PrayerStorage
    let size: IndicatorSize
    var style: IndicatorStyle = .colored

    enum IndicatorSize {
        case small, medium, large

        var iconSize: CGFloat {
            switch self {
            case .small: return 24
            case .medium: return 32
            case .large: return 40
            }
        }
    }

    enum IndicatorStyle {
        case colored      // 색상 아이콘만 표시 (기도 목록용)
        case circleWhite  // 색상 원형 배경 + 흰색 아이콘 (보관소 카드용)
    }

    // filled 버전 아이콘 이름
    private var filledIconName: String {
        switch storage {
        case .wait: return "clock.fill"
        case .yes: return "checkmark.circle.fill"
        case .no: return "xmark.circle.fill"
        }
    }

    var body: some View {
        switch style {
        case .colored:
            Image(systemName: filledIconName)
                .font(.system(size: size.iconSize, weight: .medium))
                .foregroundColor(storage.color)
                .symbolRenderingMode(.hierarchical)

        case .circleWhite:
            Image(systemName: storage.icon)
                .font(.system(size: size.iconSize * 0.5, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: size.iconSize, height: size.iconSize)
                .background(storage.color)
                .clipShape(Circle())
        }
    }
} 
