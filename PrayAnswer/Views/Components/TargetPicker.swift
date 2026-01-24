//
//  TargetPicker.swift
//  PrayAnswer
//
//  Created for prayer target selection
//

import SwiftUI
import SwiftData

/// 기도대상자 선택 컴포넌트
/// 본인, 기존 대상자 목록, 새 대상자 입력 옵션 제공
struct TargetPicker: View {
    @Binding var selectedTarget: String
    @State private var inputText = ""
    @FocusState private var isInputFocused: Bool

    let existingTargets: [String]

    init(selectedTarget: Binding<String>, existingTargets: [String]) {
        self._selectedTarget = selectedTarget
        self.existingTargets = existingTargets
    }

    private var isMyselfSelected: Bool {
        selectedTarget.isEmpty && inputText.isEmpty
    }

    // 입력 텍스트로 필터링된 기존 대상자
    private var filteredTargets: [String] {
        if inputText.isEmpty {
            return []
        }
        return existingTargets.filter { target in
            target.localizedCaseInsensitiveContains(inputText)
        }
    }

    // 입력된 텍스트가 기존 대상자와 정확히 일치하는지
    private var isExactMatch: Bool {
        existingTargets.contains { $0.lowercased() == inputText.lowercased() }
    }

    // 입력 텍스트가 새로운 대상자인지 (기존에 없는 경우)
    private var isNewTarget: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isExactMatch
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text(L.Target.selectTarget)
                .font(DesignSystem.Typography.callout)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .fontWeight(.medium)

            // 본인 선택 칩
            TargetChip(
                name: L.Target.myself,
                isSelected: isMyselfSelected,
                isMyself: true
            ) {
                withAnimation(DesignSystem.Animation.quick) {
                    selectedTarget = ""
                    inputText = ""
                    isInputFocused = false
                }
            }

            // 대상자 이름 입력 필드
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(DesignSystem.Colors.tertiaryText)
                        .font(.subheadline)

                    TextField(L.Target.searchOrAddPlaceholder, text: $inputText)
                        .font(DesignSystem.Typography.body)
                        .focused($isInputFocused)
                        .onChange(of: inputText) { _, newValue in
                            // 입력 중에는 selectedTarget 업데이트하지 않음
                            // 선택하거나 확인할 때만 업데이트
                        }
                        .onSubmit {
                            confirmInput()
                        }

                    // 입력 내용이 있으면 클리어 버튼 표시
                    if !inputText.isEmpty {
                        Button(action: {
                            inputText = ""
                            selectedTarget = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(DesignSystem.Colors.tertiaryText)
                                .font(.subheadline)
                        }
                    }
                }
                .padding(DesignSystem.Spacing.md)
                .background(DesignSystem.Colors.secondaryBackground)
                .cornerRadius(DesignSystem.CornerRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                        .stroke(
                            isInputFocused ? DesignSystem.Colors.primary.opacity(0.5) : Color.clear,
                            lineWidth: 1
                        )
                )

                // 검색 결과 또는 새 대상자 표시
                if !inputText.isEmpty {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        // 필터링된 기존 대상자 목록
                        ForEach(filteredTargets, id: \.self) { target in
                            TargetSearchResultRow(
                                name: target,
                                isSelected: selectedTarget == target,
                                isNew: false
                            ) {
                                selectTarget(target)
                            }
                        }

                        // 새 대상자 추가 옵션 (기존에 없는 경우에만)
                        if isNewTarget {
                            TargetSearchResultRow(
                                name: inputText.trimmingCharacters(in: .whitespacesAndNewlines),
                                isSelected: selectedTarget == inputText.trimmingCharacters(in: .whitespacesAndNewlines),
                                isNew: true
                            ) {
                                confirmInput()
                            }
                        }
                    }
                    .padding(.top, DesignSystem.Spacing.xs)
                }

                // 현재 선택된 대상자 표시 (입력 필드와 별개로)
                if !selectedTarget.isEmpty && inputText.isEmpty {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(DesignSystem.Colors.primary)
                            .font(.subheadline)

                        Text(selectedTarget)
                            .font(DesignSystem.Typography.callout)
                            .fontWeight(.medium)
                            .foregroundColor(DesignSystem.Colors.primary)

                        Spacer()

                        Button(action: {
                            selectedTarget = ""
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(DesignSystem.Colors.tertiaryText)
                                .font(.caption)
                        }
                    }
                    .padding(DesignSystem.Spacing.md)
                    .background(DesignSystem.Colors.primary.opacity(0.1))
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                }
            }
        }
    }

    private func selectTarget(_ target: String) {
        withAnimation(DesignSystem.Animation.quick) {
            selectedTarget = target
            inputText = ""
            isInputFocused = false
        }
    }

    private func confirmInput() {
        let trimmedName = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        withAnimation(DesignSystem.Animation.quick) {
            selectedTarget = trimmedName
            inputText = ""
            isInputFocused = false
        }
    }
}

// MARK: - Target Search Result Row

struct TargetSearchResultRow: View {
    let name: String
    let isSelected: Bool
    let isNew: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                // 아이콘
                Image(systemName: isNew ? "plus.circle.fill" : (isSelected ? "checkmark.circle.fill" : "person.circle"))
                    .foregroundColor(isSelected ? DesignSystem.Colors.primary : (isNew ? DesignSystem.Colors.primary : DesignSystem.Colors.secondaryText))
                    .font(.subheadline)

                // 이름
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(DesignSystem.Typography.callout)
                        .fontWeight(isSelected ? .semibold : .regular)
                        .foregroundColor(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.primaryText)

                    if isNew {
                        Text(L.Target.addAsNewTarget)
                            .font(DesignSystem.Typography.caption2)
                            .foregroundColor(DesignSystem.Colors.primary)
                    }
                }

                Spacer()

                // 선택 표시
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(DesignSystem.Colors.primary)
                        .font(.subheadline.weight(.semibold))
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                isSelected
                    ? DesignSystem.Colors.primary.opacity(0.1)
                    : DesignSystem.Colors.cardBackground
            )
            .cornerRadius(DesignSystem.CornerRadius.small)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Target Chip Component

struct TargetChip: View {
    let name: String
    let isSelected: Bool
    let isMyself: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : (isMyself ? "person.fill" : "person.circle"))
                    .font(.caption)

                Text(name)
                    .font(DesignSystem.Typography.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                isSelected
                    ? DesignSystem.Colors.primary
                    : DesignSystem.Colors.secondaryBackground
            )
            .foregroundColor(isSelected ? .white : DesignSystem.Colors.primaryText)
            .cornerRadius(DesignSystem.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .stroke(
                        isSelected
                            ? Color.clear
                            : DesignSystem.Colors.tertiaryText.opacity(0.3),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(DesignSystem.Animation.quick, value: isSelected)
    }
}

// MARK: - Add Target Button Component (Legacy - 제거됨)

// 이제 검색 기반 입력으로 대체되어 사용되지 않음

#Preview {
    VStack {
        TargetPicker(
            selectedTarget: .constant(""),
            existingTargets: ["엄마", "아빠", "친구", "동생", "할머니"]
        )
        .padding()

        TargetPicker(
            selectedTarget: .constant("엄마"),
            existingTargets: ["엄마", "아빠", "친구", "동생", "할머니"]
        )
        .padding()
    }
}
