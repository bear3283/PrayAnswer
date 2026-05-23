import SwiftUI
import SwiftData

/// 다른 사람에게 받은 .prayanswer 파일을 미리보고 저장하는 화면
struct ImportPrayerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let package: PrayerExchangePackage

    @State private var senderName: String
    @State private var selectedIDs: Set<UUID>
    @State private var isSaved = false

    init(package: PrayerExchangePackage) {
        self.package = package
        _senderName = State(initialValue: package.sender)
        _selectedIDs = State(initialValue: Set(package.prayers.map { $0.id }))
    }

    private var selectedPrayers: [ExchangePrayerItem] {
        package.prayers.filter { selectedIDs.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("보낸 사람")
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                            .font(DesignSystem.Typography.subheadline)
                        Spacer()
                        TextField("이름 입력", text: $senderName)
                            .multilineTextAlignment(.trailing)
                            .font(DesignSystem.Typography.body)
                    }
                } header: {
                    Text("보낸 사람")
                }

                Section {
                    ForEach(package.prayers) { item in
                        HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                            Image(systemName: selectedIDs.contains(item.id) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedIDs.contains(item.id) ? DesignSystem.Colors.primary : DesignSystem.Colors.tertiaryText)
                                .font(.system(size: 22))
                                .onTapGesture { toggleSelection(item.id) }

                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                Text(item.title)
                                    .font(DesignSystem.Typography.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(DesignSystem.Colors.primaryText)
                                if !item.content.isEmpty {
                                    Text(item.content)
                                        .font(DesignSystem.Typography.caption)
                                        .foregroundColor(DesignSystem.Colors.secondaryText)
                                        .lineLimit(2)
                                }
                                if let category = PrayerCategory(rawValue: item.category) {
                                    Text(category.displayName)
                                        .font(DesignSystem.Typography.caption2)
                                        .foregroundColor(DesignSystem.Colors.tertiaryText)
                                }
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { toggleSelection(item.id) }
                    }
                } header: {
                    HStack {
                        Text("기도제목 (\(package.prayers.count)개)")
                        Spacer()
                        Button(selectedIDs.count == package.prayers.count ? "모두 해제" : "모두 선택") {
                            if selectedIDs.count == package.prayers.count {
                                selectedIDs.removeAll()
                            } else {
                                selectedIDs = Set(package.prayers.map { $0.id })
                            }
                        }
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.primary)
                    }
                }
            }
            .navigationTitle("\(package.sender)님의 기도제목")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") { dismiss() }
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장 (\(selectedIDs.count))") {
                        savePrayers()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.primary)
                    .disabled(selectedIDs.isEmpty || senderName.isEmpty)
                }
            }
            .alert("저장 완료", isPresented: $isSaved) {
                Button("확인") { dismiss() }
            } message: {
                Text("\(selectedIDs.count)개의 기도제목을 '\(senderName)'님 항목으로 저장했습니다.")
            }
        }
    }

    private func toggleSelection(_ id: UUID) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }

    private func savePrayers() {
        for item in selectedPrayers {
            let category = PrayerCategory(rawValue: item.category) ?? .personal
            let prayer = Prayer(
                title: item.title,
                content: item.content,
                category: category,
                target: senderName,
                storage: .wait
            )
            modelContext.insert(prayer)
        }
        try? modelContext.save()
        isSaved = true
    }
}
