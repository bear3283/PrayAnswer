import SwiftUI

// MARK: - 다인원 기도대상자 선택 컴포넌트

/// 여러 명의 기도 대상자를 동시에 관리하는 피커.
/// - 항상 "나" 칩이 첫 번째로 표시된다.
/// - 추가된 인원은 각자 고유한 색상 칩으로 표시된다.
/// - 활성 칩을 클릭하면 해당 인원의 기도 내용으로 전환된다.
struct MultiTargetPicker: View {
    @Binding var entries: [PrayerDraftEntry]
    @Binding var activeEntryIndex: Int
    let existingTargets: [String]

    @State private var inputText = ""
    @FocusState private var isInputFocused: Bool

    // MARK: - Computed

    private var myselfEntry: PrayerDraftEntry? {
        entries.first(where: { $0.target.isEmpty })
    }

    private var namedEntries: [PrayerDraftEntry] {
        entries.filter { !$0.target.isEmpty }
    }

    /// 이미 추가된 이름 목록 (중복 방지용)
    private var addedNames: Set<String> {
        Set(entries.compactMap { $0.target.isEmpty ? nil : $0.target.lowercased() })
    }

    /// 검색어로 필터링된 기존 대상자 (이미 추가된 이름 제외)
    private var filteredTargets: [String] {
        guard !inputText.isEmpty else { return [] }
        return existingTargets.filter { target in
            target.localizedCaseInsensitiveContains(inputText) &&
            !addedNames.contains(target.lowercased())
        }
    }

    /// 입력된 이름이 기존 대상자 목록 또는 이미 추가된 목록에 정확히 일치하는지
    private var isExactMatch: Bool {
        let lower = inputText.lowercased()
        return existingTargets.contains { $0.lowercased() == lower } ||
               addedNames.contains(lower)
    }

    /// 입력된 이름이 새로운 대상자인지 (아직 추가되지 않은 경우)
    private var isNewTarget: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isExactMatch
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text(L.Target.selectTarget)
                .font(DesignSystem.Typography.callout)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .fontWeight(.medium)

            // 칩 목록: 나 + 추가된 인원
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    if let myself = myselfEntry,
                       let myselfIdx = entries.firstIndex(where: { $0.id == myself.id }) {
                        PersonChip(
                            entry: myself,
                            isActive: activeEntryIndex == myselfIdx,
                            showRemoveButton: false,
                            onTap: {
                                withAnimation(DesignSystem.Animation.quick) {
                                    activeEntryIndex = myselfIdx
                                }
                            },
                            onRemove: {}
                        )
                    }

                    ForEach(namedEntries) { entry in
                        let entryIdx = entries.firstIndex(where: { $0.id == entry.id }) ?? 0
                        PersonChip(
                            entry: entry,
                            isActive: activeEntryIndex == entryIdx,
                            showRemoveButton: true,
                            onTap: {
                                withAnimation(DesignSystem.Animation.quick) {
                                    activeEntryIndex = entryIdx
                                }
                            },
                            onRemove: {
                                removeEntry(entry)
                            }
                        )
                    }
                }
                .padding(.vertical, 2)
                .padding(.horizontal, 1)
            }

            // 이름 검색 및 추가 필드
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "person.badge.plus")
                        .foregroundColor(DesignSystem.Colors.tertiaryText)
                        .font(.subheadline)

                    TextField(L.Target.searchOrAddPlaceholder, text: $inputText)
                        .font(DesignSystem.Typography.body)
                        .focused($isInputFocused)
                        .onSubmit { confirmInput() }

                    if !inputText.isEmpty {
                        Button(action: { inputText = "" }) {
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

                // 검색 결과 드롭다운
                if !inputText.isEmpty {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        ForEach(filteredTargets, id: \.self) { target in
                            TargetSearchResultRow(
                                name: target,
                                isSelected: false,
                                isNew: false
                            ) {
                                addTarget(target)
                            }
                        }

                        if isNewTarget {
                            TargetSearchResultRow(
                                name: inputText.trimmingCharacters(in: .whitespacesAndNewlines),
                                isSelected: false,
                                isNew: true
                            ) {
                                confirmInput()
                            }
                        }
                    }
                    .padding(.top, DesignSystem.Spacing.xs)
                }
            }
        }
    }

    // MARK: - Actions

    private func addTarget(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // 이미 추가된 이름이면 해당 항목을 활성화
        if let existingIdx = entries.firstIndex(where: { $0.target.lowercased() == trimmed.lowercased() }) {
            withAnimation(DesignSystem.Animation.quick) {
                activeEntryIndex = existingIdx
                inputText = ""
                isInputFocused = false
            }
            return
        }

        // 새 entry 추가 (색상 인덱스는 현재 entries 수 기준)
        let newColorIndex = entries.count
        let newEntry = PrayerDraftEntry(target: trimmed, colorIndex: newColorIndex)
        withAnimation(DesignSystem.Animation.quick) {
            entries.append(newEntry)
            activeEntryIndex = entries.count - 1
            inputText = ""
            isInputFocused = false
        }
    }

    private func confirmInput() {
        addTarget(inputText)
    }

    private func removeEntry(_ entry: PrayerDraftEntry) {
        guard let index = entries.firstIndex(where: { $0.id == entry.id }) else { return }

        withAnimation(DesignSystem.Animation.quick) {
            entries.remove(at: index)
            // 삭제된 항목이 활성이었거나 인덱스가 범위를 벗어나면 조정
            if activeEntryIndex >= index {
                activeEntryIndex = max(0, activeEntryIndex - 1)
            }
        }
    }
}

// MARK: - 개인 칩 컴포넌트

struct PersonChip: View {
    let entry: PrayerDraftEntry
    let isActive: Bool
    let showRemoveButton: Bool
    let onTap: () -> Void
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: isActive
                  ? "checkmark.circle.fill"
                  : (entry.target.isEmpty ? "person.fill" : "person.circle"))
                .font(.caption)
                .foregroundColor(isActive ? .white : entry.color)

            Text(entry.displayName)
                .font(DesignSystem.Typography.caption)
                .fontWeight(.medium)
                .foregroundColor(isActive ? .white : DesignSystem.Colors.primaryText)
                .lineLimit(1)

            if showRemoveButton {
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(Font.system(size: 9, weight: .bold))
                        .foregroundColor(isActive ? .white.opacity(0.85) : DesignSystem.Colors.tertiaryText)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            isActive
                ? entry.color
                : DesignSystem.Colors.secondaryBackground
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .stroke(
                    isActive ? Color.clear : entry.color.opacity(0.6),
                    lineWidth: 1.5
                )
        )
        .cornerRadius(DesignSystem.CornerRadius.medium)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .animation(DesignSystem.Animation.quick, value: isActive)
    }
}

#Preview {
    let entries: [PrayerDraftEntry] = {
        let e0 = PrayerDraftEntry(target: "", colorIndex: 0)
        let e1 = PrayerDraftEntry(target: "박지수", colorIndex: 1)
        let e2 = PrayerDraftEntry(target: "김민수", colorIndex: 2)
        return [e0, e1, e2]
    }()

    MultiTargetPicker(
        entries: .constant(entries),
        activeEntryIndex: .constant(1),
        existingTargets: ["박지수", "김민수", "이다솔", "최하은"]
    )
    .padding()
}
