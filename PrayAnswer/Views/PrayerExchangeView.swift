import SwiftUI
import SwiftData

/// 보낼 기도제목을 선택하고 공유하는 화면
struct PrayerExchangeView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var allPrayers: [Prayer]
    @ObservedObject private var myProfile = MyProfile.shared

    @State private var selectedIDs: Set<UUID> = []
    @State private var showShareSheet = false
    @State private var shareText = ""
    @State private var errorMessage: String?
    @State private var showError = false

    // 나의 기도제목
    private var myRequestPrayers: [Prayer] {
        allPrayers.filter { $0.isMyRequest }
    }

    // 다른 사람의 기도 (target이 있고 isMyRequest가 아닌 것)
    private var othersPrayers: [Prayer] {
        allPrayers.filter { !$0.target.isEmpty && !$0.isMyRequest }
    }

    var body: some View {
        NavigationStack {
            List {
                // 안내
                Section {
                    HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(DesignSystem.Colors.primary)
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                            Text("앱이 있으면 바로 저장, 없으면 텍스트로 전달")
                                .font(DesignSystem.Typography.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(DesignSystem.Colors.primaryText)
                            Text("카카오톡, 문자, 이메일 등 어디서든 공유할 수 있어요. 받는 분이 PrayAnswer 앱이 있다면 링크 한 번으로 기도목록에 바로 저장됩니다.")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                        }
                    }
                    .padding(.vertical, DesignSystem.Spacing.xs)
                }
                .listRowBackground(DesignSystem.Colors.primary.opacity(0.06))

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
                    Button {
                        prepareAndShare()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.up")
                            Text("보내기 (\(selectedIDs.count))")
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(selectedIDs.isEmpty ? DesignSystem.Colors.tertiaryText : DesignSystem.Colors.primary)
                    }
                    .disabled(selectedIDs.isEmpty)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(activityItems: [shareText])
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

        shareText = PrayerExchangePackager.makeShareMessage(package)
        showShareSheet = true
    }
}
