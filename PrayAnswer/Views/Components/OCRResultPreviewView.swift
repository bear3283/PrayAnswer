//
//  OCRResultPreviewView.swift
//  PrayAnswer
//
//  OCR 결과 미리보기 + AI 요약 연동
//

import SwiftUI

/// OCR 결과 미리보기 뷰
/// 추출된 텍스트 편집 및 AI 정리 기능 제공
struct OCRResultPreviewView: View {
    @Binding var extractedText: String
    let onApply: (String) -> Void
    let onCancel: () -> Void

    @State private var isEditing: Bool = false
    @State private var isAIProcessing: Bool = false
    @State private var aiSummarizedText: String = ""
    @State private var showAIResult: Bool = false
    @State private var aiErrorMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            // Content Area
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    if showAIResult && !aiSummarizedText.isEmpty {
                        aiResultView
                    } else {
                        extractedTextView
                    }
                }
                .padding(DesignSystem.Spacing.lg)
            }
            .frame(maxHeight: .infinity)

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
                    Image(systemName: "text.viewfinder")
                        .font(.title2)
                        .foregroundColor(DesignSystem.Colors.primary)

                    Text(L.Image.ocrResult)
                        .font(DesignSystem.Typography.title2)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                }

                Text(L.Image.ocrResultDescription)
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

    // MARK: - Extracted Text View

    private var extractedTextView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Label(L.Image.extractedText, systemImage: "doc.text")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)

                Spacer()

                // 편집 모드 토글
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

                Text("\(extractedText.count) " + L.AI.characters)
                    .font(DesignSystem.Typography.caption2)
                    .foregroundColor(DesignSystem.Colors.tertiaryText)
            }

            if isEditing {
                TextEditor(text: $extractedText)
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
                Text(extractedText)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                    .padding(DesignSystem.Spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(DesignSystem.Colors.secondaryBackground)
                    .cornerRadius(DesignSystem.CornerRadius.medium)
            }

            // AI 에러 메시지
            if let error = aiErrorMessage {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text(error)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                .padding(DesignSystem.Spacing.sm)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(DesignSystem.CornerRadius.small)
            }
        }
    }

    // MARK: - AI Result View

    private var aiResultView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Label(L.AI.aiSummarized, systemImage: "sparkles")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.primary)

                Spacer()

                // 원본으로 돌아가기
                Button(action: {
                    withAnimation {
                        showAIResult = false
                    }
                }) {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.caption)
                        Text(L.AI.useOriginal)
                            .font(DesignSystem.Typography.caption)
                    }
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .padding(.horizontal, DesignSystem.Spacing.sm)
                    .padding(.vertical, DesignSystem.Spacing.xs)
                    .background(DesignSystem.Colors.secondaryBackground)
                    .cornerRadius(DesignSystem.CornerRadius.small)
                }
                .buttonStyle(PlainButtonStyle())

                Text("\(aiSummarizedText.count) " + L.AI.characters)
                    .font(DesignSystem.Typography.caption2)
                    .foregroundColor(DesignSystem.Colors.tertiaryText)
            }

            Text(aiSummarizedText)
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

            // 압축률 표시
            if extractedText.count > 0 {
                let reduction = 100 - (aiSummarizedText.count * 100 / extractedText.count)
                HStack {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundColor(.green)
                    Text("\(L.AI.reduction): \(max(0, reduction))%")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                .padding(.horizontal, DesignSystem.Spacing.sm)
            }
        }
    }

    // MARK: - Bottom Buttons

    private var bottomButtons: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Divider()

            HStack(spacing: DesignSystem.Spacing.md) {
                // AI 정리 버튼 (iOS 26+)
                if AIFeatureAvailability.isSupported {
                    Button(action: performAISummarization) {
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            if isAIProcessing {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .tint(DesignSystem.Colors.primary)
                            } else {
                                Image(systemName: "sparkles")
                            }
                            Text(isAIProcessing ? L.Image.aiOrganizing : L.Image.aiOrganize)
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
                    .disabled(isAIProcessing || extractedText.isEmpty)
                }

                Spacer()

                // 적용 버튼
                Button(action: applyText) {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "checkmark")
                        Text(L.Image.applyToContent)
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
                .disabled(extractedText.isEmpty && aiSummarizedText.isEmpty)
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.bottom, DesignSystem.Spacing.lg)
        }
        .background(DesignSystem.Colors.cardBackground)
    }

    // MARK: - Actions

    private func performAISummarization() {
        guard !extractedText.isEmpty else { return }

        isAIProcessing = true
        aiErrorMessage = nil

        Task {
            if #available(iOS 26.0, *) {
                do {
                    let result = try await AISummarizationManager.shared.summarize(text: extractedText)
                    await MainActor.run {
                        aiSummarizedText = result
                        showAIResult = true
                        isAIProcessing = false
                    }
                } catch {
                    await MainActor.run {
                        aiErrorMessage = error.localizedDescription
                        isAIProcessing = false
                    }
                }
            } else {
                await MainActor.run {
                    aiErrorMessage = L.AI.errorRequiresiOS26
                    isAIProcessing = false
                }
            }
        }
    }

    private func applyText() {
        // AI 결과가 있으면 AI 결과 적용, 없으면 원본 적용
        let textToApply = showAIResult && !aiSummarizedText.isEmpty ? aiSummarizedText : extractedText
        onApply(textToApply)
    }
}
