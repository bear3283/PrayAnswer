//
//  AppleIntelligenceSetupGuideView.swift
//  PrayAnswer
//
//  Apple Intelligence 설정 안내 뷰
//

import SwiftUI

/// Apple Intelligence 설정 안내 뷰
/// AI 기능을 사용할 수 없을 때 표시되어 사용자에게 설정 방법을 안내합니다
struct AppleIntelligenceSetupGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    /// 현재 상태에 따른 안내 메시지
    private var statusMessage: String? {
        AIFeatureAvailability.unavailabilityMessage
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    // 헤더 아이콘
                    headerSection

                    // 현재 상태 표시
                    if let message = statusMessage {
                        statusBadge(message: message)
                    }

                    // 설정 단계 안내
                    setupStepsSection

                    // 참고 사항
                    noteSection

                    // 버튼들
                    actionButtons
                }
                .padding(DesignSystem.Spacing.lg)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle(L.AI.setupGuideTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L.Button.done) {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Header Section

    @ViewBuilder
    private var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple.opacity(0.2), .cyan.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: "apple.intelligence")
                    .font(.system(size: 44))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            Text(L.AI.setupGuideDescription)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }

    // MARK: - Status Badge

    @ViewBuilder
    private func statusBadge(message: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)

            Text(message)
                .font(DesignSystem.Typography.callout)
                .foregroundColor(DesignSystem.Colors.primaryText)
        }
        .padding(DesignSystem.Spacing.md)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(Color.orange.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Setup Steps Section

    @ViewBuilder
    private var setupStepsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            setupStepRow(
                number: 1,
                icon: "gear",
                title: L.AI.setupStep1Title,
                description: L.AI.setupStep1Description
            )

            setupStepRow(
                number: 2,
                icon: "sparkles",
                title: L.AI.setupStep2Title,
                description: L.AI.setupStep2Description
            )

            setupStepRow(
                number: 3,
                icon: "toggle.on",
                title: L.AI.setupStep3Title,
                description: L.AI.setupStep3Description
            )

            setupStepRow(
                number: 4,
                icon: "arrow.down.circle",
                title: L.AI.setupStep4Title,
                description: L.AI.setupStep4Description
            )
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                .fill(DesignSystem.Colors.cardBackground)
        )
    }

    @ViewBuilder
    private func setupStepRow(number: Int, icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
            // 숫자 배지
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)

                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(title)
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.primaryText)

                Text(description)
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }

            Spacer()
        }
    }

    // MARK: - Note Section

    @ViewBuilder
    private var noteSection: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.blue)

            Text(L.AI.setupNote)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.secondaryText)
        }
        .padding(DesignSystem.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(Color.blue.opacity(0.1))
        )
    }

    // MARK: - Action Buttons

    @ViewBuilder
    private var actionButtons: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // 설정 열기 버튼
            Button(action: openSettings) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "gear")
                    Text(L.AI.openSettings)
                }
                .font(DesignSystem.Typography.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(DesignSystem.Spacing.md)
                .background(
                    LinearGradient(
                        colors: [.purple, .cyan],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(DesignSystem.CornerRadius.medium)
            }

            // Apple 지원 페이지 링크
            Button(action: openAppleSupport) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "safari")
                    Text(L.AI.learnMore)
                }
                .font(DesignSystem.Typography.callout)
                .foregroundColor(DesignSystem.Colors.primary)
            }
        }
    }

    // MARK: - Actions

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    private func openAppleSupport() {
        // Apple Intelligence 지원 페이지
        if let url = URL(string: "https://support.apple.com/apple-intelligence") {
            openURL(url)
        }
    }
}

// MARK: - Preview

#Preview {
    AppleIntelligenceSetupGuideView()
}
