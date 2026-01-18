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
    @State private var showingNewTargetInput = false
    @State private var newTargetName = ""
    @FocusState private var isNewTargetFocused: Bool

    let existingTargets: [String]

    init(selectedTarget: Binding<String>, existingTargets: [String]) {
        self._selectedTarget = selectedTarget
        self.existingTargets = existingTargets
    }

    private var isMyselfSelected: Bool {
        selectedTarget.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text(L.Target.selectTarget)
                .font(DesignSystem.Typography.callout)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .fontWeight(.medium)

            // 기도대상자 선택 영역
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    // 본인 (기본값)
                    TargetChip(
                        name: L.Target.myself,
                        isSelected: isMyselfSelected,
                        isMyself: true
                    ) {
                        withAnimation(DesignSystem.Animation.quick) {
                            selectedTarget = ""
                            showingNewTargetInput = false
                            newTargetName = ""
                        }
                    }

                    // 기존 기도대상자 목록
                    ForEach(existingTargets, id: \.self) { target in
                        TargetChip(
                            name: target,
                            isSelected: selectedTarget == target,
                            isMyself: false
                        ) {
                            withAnimation(DesignSystem.Animation.quick) {
                                selectedTarget = target
                                showingNewTargetInput = false
                                newTargetName = ""
                            }
                        }
                    }

                    // 새 대상자 추가 버튼
                    AddTargetButton(isActive: showingNewTargetInput) {
                        withAnimation(DesignSystem.Animation.quick) {
                            showingNewTargetInput.toggle()
                            if showingNewTargetInput {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    isNewTargetFocused = true
                                }
                            } else {
                                newTargetName = ""
                            }
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.xs)
            }

            // 새 대상자 입력 필드
            if showingNewTargetInput {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    TextField(L.Target.newTargetPlaceholder, text: $newTargetName)
                        .font(DesignSystem.Typography.body)
                        .padding(DesignSystem.Spacing.md)
                        .background(DesignSystem.Colors.secondaryBackground)
                        .cornerRadius(DesignSystem.CornerRadius.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                .stroke(
                                    newTargetName.isEmpty ? Color.clear : DesignSystem.Colors.primary.opacity(0.3),
                                    lineWidth: 1
                                )
                        )
                        .focused($isNewTargetFocused)
                        .onSubmit {
                            confirmNewTarget()
                        }

                    Button(action: confirmNewTarget) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(newTargetName.isEmpty ? DesignSystem.Colors.tertiaryText : DesignSystem.Colors.primary)
                    }
                    .disabled(newTargetName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private func confirmNewTarget() {
        let trimmedName = newTargetName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        withAnimation(DesignSystem.Animation.quick) {
            selectedTarget = trimmedName
            showingNewTargetInput = false
            newTargetName = ""
        }
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
                if isMyself {
                    Image(systemName: "person.fill")
                        .font(.caption)
                } else {
                    Image(systemName: "person.circle")
                        .font(.caption)
                }

                Text(name)
                    .font(DesignSystem.Typography.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                isSelected
                    ? (isMyself ? DesignSystem.Colors.primary : DesignSystem.Colors.secondary)
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

// MARK: - Add Target Button Component

struct AddTargetButton: View {
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: isActive ? "xmark" : "plus")
                    .font(.caption.weight(.semibold))

                if !isActive {
                    Text(L.Target.addNewTarget)
                        .font(DesignSystem.Typography.caption)
                        .fontWeight(.medium)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                isActive
                    ? DesignSystem.Colors.notAnswered.opacity(0.1)
                    : DesignSystem.Colors.primary.opacity(0.1)
            )
            .foregroundColor(
                isActive
                    ? DesignSystem.Colors.notAnswered
                    : DesignSystem.Colors.primary
            )
            .cornerRadius(DesignSystem.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .stroke(
                        isActive
                            ? DesignSystem.Colors.notAnswered.opacity(0.3)
                            : DesignSystem.Colors.primary.opacity(0.3),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(DesignSystem.Animation.quick, value: isActive)
    }
}

#Preview {
    VStack {
        TargetPicker(
            selectedTarget: .constant(""),
            existingTargets: ["엄마", "아빠", "친구"]
        )
        .padding()

        TargetPicker(
            selectedTarget: .constant("엄마"),
            existingTargets: ["엄마", "아빠", "친구"]
        )
        .padding()
    }
}
