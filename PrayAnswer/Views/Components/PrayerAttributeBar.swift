//
//  PrayerAttributeBar.swift
//  PrayAnswer
//
//  기도 추가 폼의 부가 속성(첨부·카테고리·D-Day·컬렉션)을 한 줄 알약 버튼으로 접어두고,
//  누른 항목만 아래로 펼치는 컨트롤.
//

import SwiftUI

// MARK: - 속성 종류

/// 기도 추가 폼에서 펼쳐볼 수 있는 부가 속성
enum PrayerAttribute: String, CaseIterable, Identifiable {
    case attachment
    case category
    case dDay
    case collection

    var id: String { rawValue }
}

// MARK: - 속성 칩

/// 값이 비어 있으면 속성 이름을, 채워지면 그 값을 그대로 말하는 알약 버튼.
///
/// - `name`은 음성 안내용 속성 이름("카테고리"), `label`은 화면에 보이는 문구("건강")다.
///   둘을 나눠두면 시각 사용자는 값만 읽고, VoiceOver 사용자는 "카테고리, 건강"으로 듣는다.
struct AttributeChip: View {
    let icon: String
    let name: String
    let label: String
    let tint: Color
    /// 값이 채워져 있는지 — 채워지면 tint 색을 입는다
    let isSet: Bool
    /// 패널이 펼쳐져 있는지
    let isOpen: Bool
    let action: () -> Void

    private var foreground: Color {
        (isSet || isOpen) ? tint : DesignSystem.Colors.secondaryText
    }

    private var background: Color {
        if isOpen { return tint.opacity(0.22) }
        if isSet { return tint.opacity(0.12) }
        return DesignSystem.Colors.secondaryBackground
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.xs + 2) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))

                Text(label)
                    .font(DesignSystem.Typography.caption)
                    .lineLimit(1)
            }
            .foregroundColor(foreground)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm + 1)
            .background(Capsule().fill(background))
            .overlay(
                Capsule().stroke(isOpen ? tint.opacity(0.5) : Color.clear, lineWidth: 1.5)
            )
            .contentShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(name)
        .accessibilityValue(isSet ? label : L.AttributeBar.notSet)
        .accessibilityHint(isOpen ? L.AttributeBar.collapseHint : L.AttributeBar.expandHint)
    }
}

// MARK: - 펼쳐진 패널

/// 칩 아래로 펼쳐지는 패널. 테두리 색으로 어느 칩이 열렸는지 잇는다.
struct AttributePanel<Content: View>: View {
    let tint: Color
    let borderWidth: CGFloat
    @ViewBuilder let content: Content

    init(tint: Color, borderWidth: CGFloat = 1.5, @ViewBuilder content: () -> Content) {
        self.tint = tint
        self.borderWidth = borderWidth
        self.content = content()
    }

    var body: some View {
        ModernCard {
            content
                .padding(DesignSystem.Spacing.lg)
        }
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                .stroke(tint.opacity(0.4), lineWidth: borderWidth)
        )
    }
}

// MARK: - D-Day 표시 헬퍼

/// 아직 Prayer로 저장되지 않은 초안의 목표 날짜를 표시용으로 바꾼다.
/// (저장된 기도는 `Prayer.dDayDisplayText`를 쓴다)
enum DraftDDay {

    static func daysRemaining(until date: Date) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: date)
        return calendar.dateComponents([.day], from: today, to: target).day ?? 0
    }

    /// "D-7" / "D-Day" / "D+3"
    static func label(for date: Date) -> String {
        let days = daysRemaining(until: date)
        if days == 0 { return "D-Day" }
        return days > 0 ? "D-\(days)" : "D+\(abs(days))"
    }

    /// 날짜가 지났으면 주의색, 일주일 안이면 대기색, 그 밖에는 기본색
    static func tint(for date: Date) -> Color {
        let days = daysRemaining(until: date)
        if days < 0 { return DesignSystem.Colors.notAnswered }
        if days <= 7 { return DesignSystem.Colors.wait }
        return DesignSystem.Colors.primary
    }
}
