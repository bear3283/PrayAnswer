import SwiftUI
import SwiftData

/// 보낼 기도제목을 선택하고 공유하는 화면
struct PrayerExchangeView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var allPrayers: [Prayer]
    @ObservedObject private var myProfile = MyProfile.shared

    @State private var selectedIDs: Set<PersistentIdentifier> = []
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var showSuccessToast = false

    // 나의 기도제목 (최신순)
    private var myRequestPrayers: [Prayer] {
        allPrayers
            .filter { $0.isMyRequest }
            .sorted { $0.createdDate > $1.createdDate }
    }

    // 다른 사람의 기도 (target이 있고 isMyRequest가 아닌 것, 최신순)
    private var othersPrayers: [Prayer] {
        allPrayers
            .filter { !$0.target.isEmpty && !$0.isMyRequest }
            .sorted { $0.createdDate > $1.createdDate }
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
                            Text("카카오톡·문자: 텍스트로 전달")
                                .font(DesignSystem.Typography.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(DesignSystem.Colors.primaryText)
                            Text("에어드롭·이메일: 기도파일(.prayanswer)로 전달 — 받는 분이 PrayAnswer 앱이 있다면 파일을 열어 바로 저장할 수 있어요.")
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
                ShareSheet(activityItems: shareItems) { completed in
                    if completed {
                        showSuccessToast = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            dismiss()
                        }
                    }
                }
            }
            .alert("오류", isPresented: $showError) {
                Button("확인") {}
            } message: {
                Text(errorMessage ?? "알 수 없는 오류가 발생했습니다.")
            }
            .overlay(alignment: .bottom) {
                if showSuccessToast {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                        Text("기도제목을 공유했습니다")
                            .font(DesignSystem.Typography.subheadline)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.vertical, DesignSystem.Spacing.md)
                    .background(DesignSystem.Colors.primary, in: Capsule())
                    .padding(.bottom, DesignSystem.Spacing.xl)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: showSuccessToast)
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
        let exchangeItems = selected.map { ExchangePrayerItem(from: $0) }
        let senderName = myProfile.name.isEmpty ? "PrayAnswer 사용자" : myProfile.name
        let package = PrayerExchangePackage(sender: senderName, prayers: exchangeItems)

        let text = PrayerExchangePackager.makeShareMessage(package)

        // 텍스트 + 파일(.prayanswer)을 함께 공유
        // 카카오톡/문자: 텍스트 선택, 에어드롭/메일: 파일 첨부 가능
        var activityItems: [Any] = [text]
        if let fileURL = try? PrayerExchangePackager.writeToFile(package) {
            activityItems.append(fileURL)
        }

        shareItems = activityItems
        showShareSheet = true
    }
}
