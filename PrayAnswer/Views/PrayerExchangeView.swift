import SwiftUI
import SwiftData

/// 보낼 기도제목을 선택하고 공유 시트를 띄우는 화면
struct PrayerExchangeView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var allPrayers: [Prayer]
    @ObservedObject private var myProfile = MyProfile.shared

    @State private var selectedIDs: Set<UUID> = []
    @State private var shareItems: [Any] = []
    @State private var showShareSheet = false
    @State private var errorMessage: String?
    @State private var showError = false

    // 나의 기도제목
    private var myRequestPrayers: [Prayer] {
        allPrayers.filter { $0.isMyRequest }
    }

    // 다른 사람의 기도 (공유 가능 항목 — target이 있고 isMyRequest가 아닌 것)
    private var othersPrayers: [Prayer] {
        allPrayers.filter { !$0.target.isEmpty && !$0.isMyRequest }
    }

    var body: some View {
        NavigationStack {
            List {
                // 나의 기도제목 섹션
                if !myRequestPrayers.isEmpty {
                    Section {
                        ForEach(myRequestPrayers) { prayer in
                            prayerRow(prayer, prefix: nil)
                        }
                    } header: {
                        Text("나의 기도제목")
                    }
                }

                // 다른 사람의 기도 섹션
                if !othersPrayers.isEmpty {
                    Section {
                        ForEach(othersPrayers) { prayer in
                            prayerRow(prayer, prefix: prayer.target)
                        }
                    } header: {
                        Text("다른 사람의 기도")
                    }
                }

                if myRequestPrayers.isEmpty && othersPrayers.isEmpty {
                    Section {
                        VStack(spacing: DesignSystem.Spacing.md) {
                            Image(systemName: "hands.clap")
                                .font(.system(size: 40))
                                .foregroundColor(DesignSystem.Colors.tertiaryText)
                            Text("공유할 기도제목이 없습니다.\n나의 기도제목을 먼저 추가해보세요.")
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignSystem.Spacing.xl)
                    }
                }
            }
            .navigationTitle("기도 교환하기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") { dismiss() }
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("보내기 (\(selectedIDs.count))") {
                        prepareAndShare()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.primary)
                    .disabled(selectedIDs.isEmpty)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(activityItems: shareItems)
            }
            .alert("오류", isPresented: $showError) {
                Button("확인") {}
            } message: {
                Text(errorMessage ?? "알 수 없는 오류가 발생했습니다.")
            }
        }
    }

    @ViewBuilder
    private func prayerRow(_ prayer: Prayer, prefix: String?) -> some View {
        let isSelected = selectedIDs.contains(prayer.id)
        HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.tertiaryText)
                .font(.system(size: 22))

            VStack(alignment: .leading, spacing: 2) {
                if let prefix = prefix {
                    Text(prefix)
                        .font(DesignSystem.Typography.caption2)
                        .foregroundColor(DesignSystem.Colors.tertiaryText)
                }
                Text(prayer.title)
                    .font(DesignSystem.Typography.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                if !prayer.content.isEmpty {
                    Text(prayer.content)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .lineLimit(2)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if isSelected { selectedIDs.remove(prayer.id) }
            else { selectedIDs.insert(prayer.id) }
        }
    }

    private func prepareAndShare() {
        let selected = allPrayers.filter { selectedIDs.contains($0.id) }
        let items = selected.map { ExchangePrayerItem(from: $0) }
        let senderName = myProfile.name.isEmpty ? "PrayAnswer 사용자" : myProfile.name
        let package = PrayerExchangePackage(sender: senderName, prayers: items)

        do {
            let fileURL = try PrayerExchangePackager.writeToFile(package)
            shareItems = [fileURL]
            showShareSheet = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

