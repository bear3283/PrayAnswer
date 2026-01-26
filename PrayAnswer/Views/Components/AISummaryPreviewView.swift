//
//  AISummaryPreviewView.swift
//  PrayAnswer
//
//  Created for AI summarization result preview and comparison
//

import SwiftUI

/// AI 요약 결과 미리보기 뷰
/// 원본 텍스트와 AI가 정리한 텍스트를 비교하고 선택할 수 있음
struct AISummaryPreviewView: View {
    let originalText: String
    @Binding var summarizedText: String
    let onApply: () -> Void
    let onCancel: () -> Void
    let onRetry: () -> Void

    @State private var selectedTab: PreviewTab = .summarized
    @State private var isEditing: Bool = false

    enum PreviewTab: String, CaseIterable {
        case original
        case summarized

        var title: String {
            switch self {
            case .original:
                return L.AI.originalText
            case .summarized:
                return L.AI.summarizedText
            }
        }

        var icon: String {
            switch self {
            case .original:
                return "doc.text"
            case .summarized:
                return "sparkles"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            // Tab Selector
            tabSelector

            // Content Area
            contentArea

            // Bottom Buttons
            bottomButtons
        }
        .background(DesignSystem.Colors.background)
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text(L.AI.summaryResult)
                        .font(DesignSystem.Typography.title2)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                }

                Text(L.AI.summaryResultDescription)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }

            Spacer()

            // Close button
            Button(action: onCancel) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(DesignSystem.Colors.tertiaryText)
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(DesignSystem.Colors.cardBackground)
    }

    // MARK: - Tab Selector

    private var tabSelector: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(PreviewTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }) {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: tab.icon)
                            .font(.caption)
                        Text(tab.title)
                            .font(DesignSystem.Typography.callout)
                            .fontWeight(selectedTab == tab ? .semibold : .regular)
                    }
                    .foregroundColor(selectedTab == tab ? .white : DesignSystem.Colors.primaryText)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                    .background(
                        selectedTab == tab
                            ? AnyShapeStyle(DesignSystem.Colors.primary)
                            : AnyShapeStyle(DesignSystem.Colors.secondaryBackground)
                    )
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                }
                .buttonStyle(PlainButtonStyle())
            }

            Spacer()

            // 편집 모드 토글 (요약 탭에서만)
            if selectedTab == .summarized {
                Button(action: {
                    withAnimation {
                        isEditing.toggle()
                    }
                }) {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: isEditing ? "checkmark" : "pencil")
                            .font(.caption)
                        Text(isEditing ? L.Button.done : L.Button.edit)
                            .font(DesignSystem.Typography.caption)
                    }
                    .foregroundColor(DesignSystem.Colors.primary)
                    .padding(.horizontal, DesignSystem.Spacing.sm)
                    .padding(.vertical, DesignSystem.Spacing.xs)
                    .background(DesignSystem.Colors.primary.opacity(0.1))
                    .cornerRadius(DesignSystem.CornerRadius.small)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.cardBackground)
    }

    // MARK: - Content Area

    private var contentArea: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                switch selectedTab {
                case .original:
                    originalContentView
                case .summarized:
                    summarizedContentView
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }
        .frame(maxHeight: .infinity)
    }

    private var originalContentView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Label(L.AI.originalRecording, systemImage: "waveform")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)

                Spacer()

                Text("\(originalText.count) " + L.AI.characters)
                    .font(DesignSystem.Typography.caption2)
                    .foregroundColor(DesignSystem.Colors.tertiaryText)
            }

            Text(originalText)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .padding(DesignSystem.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(DesignSystem.Colors.secondaryBackground)
                .cornerRadius(DesignSystem.CornerRadius.medium)
        }
    }

    private var summarizedContentView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Label(L.AI.aiSummarized, systemImage: "sparkles")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.primary)

                Spacer()

                Text("\(summarizedText.count) " + L.AI.characters)
                    .font(DesignSystem.Typography.caption2)
                    .foregroundColor(DesignSystem.Colors.tertiaryText)
            }

            if isEditing {
                TextEditor(text: $summarizedText)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                    .scrollContentBackground(.hidden)
                    .padding(DesignSystem.Spacing.md)
                    .frame(minHeight: 200)
                    .background(DesignSystem.Colors.secondaryBackground)
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                            .stroke(DesignSystem.Colors.primary.opacity(0.5), lineWidth: 2)
                    )
            } else {
                Text(summarizedText)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                    .padding(DesignSystem.Spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.primary.opacity(0.05),
                                DesignSystem.Colors.primary.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                            .stroke(DesignSystem.Colors.primary.opacity(0.2), lineWidth: 1)
                    )
            }

            // 통계 비교
            comparisonStats
        }
    }

    private var comparisonStats: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            StatItem(
                title: L.AI.reduction,
                value: reductionPercentage,
                icon: "arrow.down.circle.fill",
                color: .green
            )

            StatItem(
                title: L.AI.originalLength,
                value: "\(originalText.count)",
                icon: "doc.text",
                color: DesignSystem.Colors.secondaryText
            )

            StatItem(
                title: L.AI.summarizedLength,
                value: "\(summarizedText.count)",
                icon: "sparkles",
                color: DesignSystem.Colors.primary
            )
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.secondaryBackground.opacity(0.5))
        .cornerRadius(DesignSystem.CornerRadius.medium)
    }

    private var reductionPercentage: String {
        guard originalText.count > 0 else { return "0%" }
        let reduction = 100 - (summarizedText.count * 100 / originalText.count)
        return "\(max(0, reduction))%"
    }

    // MARK: - Bottom Buttons

    private var bottomButtons: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Divider()

            HStack(spacing: DesignSystem.Spacing.md) {
                // 다시 시도 버튼
                Button(action: onRetry) {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "arrow.clockwise")
                        Text(L.AI.retry)
                    }
                    .font(DesignSystem.Typography.callout)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.primary)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.vertical, DesignSystem.Spacing.md)
                    .background(DesignSystem.Colors.primary.opacity(0.1))
                    .cornerRadius(DesignSystem.CornerRadius.large)
                }
                .buttonStyle(PlainButtonStyle())

                // 원본 사용 버튼
                Button(action: {
                    summarizedText = originalText
                    onApply()
                }) {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "doc.text")
                        Text(L.AI.useOriginal)
                    }
                    .font(DesignSystem.Typography.callout)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.vertical, DesignSystem.Spacing.md)
                    .background(DesignSystem.Colors.secondaryBackground)
                    .cornerRadius(DesignSystem.CornerRadius.large)
                }
                .buttonStyle(PlainButtonStyle())

                // 적용 버튼
                Button(action: onApply) {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "checkmark")
                        Text(L.AI.apply)
                    }
                    .font(DesignSystem.Typography.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    .padding(.vertical, DesignSystem.Spacing.md)
                    .background(DesignSystem.Colors.primary)
                    .cornerRadius(DesignSystem.CornerRadius.large)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.bottom, DesignSystem.Spacing.lg)
        }
        .background(DesignSystem.Colors.cardBackground)
    }
}

// MARK: - Supporting Views

private struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)

            Text(value)
                .font(DesignSystem.Typography.callout)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.primaryText)

            Text(title)
                .font(DesignSystem.Typography.caption2)
                .foregroundColor(DesignSystem.Colors.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }
}
