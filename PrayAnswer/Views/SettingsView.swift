//
//  SettingsView.swift
//  PrayAnswer
//

import SwiftUI

struct SettingsView: View {
    @State private var showStatistics = false
    @AppStorage("aiFeatureEnabled") private var isAIUserEnabled: Bool = true

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
    }

    var body: some View {
        NavigationStack {
            List {
                guideSection
                aiSection
                statsSection
                appInfoSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle(L.Settings.tabTitle)
        }
        .sheet(isPresented: $showStatistics) {
            StatisticsView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Sections

    private var guideSection: some View {
        Section {
            NavigationLink {
                FeatureGuideView()
            } label: {
                Label {
                    Text(L.Settings.guideSection)
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                } icon: {
                    Image(systemName: "book")
                        .foregroundColor(DesignSystem.Colors.primary)
                }
            }
        }
    }

    private var aiSection: some View {
        Section {
            Toggle(isOn: $isAIUserEnabled) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(
                                LinearGradient(colors: [.purple, .cyan], startPoint: .leading, endPoint: .trailing)
                            )
                        Text(L.Settings.aiToggle)
                            .font(DesignSystem.Typography.callout)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                    }
                    Text(L.Settings.aiToggleDesc)
                        .font(DesignSystem.Typography.caption2)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
            }
            .tint(DesignSystem.Colors.primary)

            HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                Image(systemName: "airpodspro")
                    .font(.body)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                Text(L.Settings.bluetoothTip)
                    .font(DesignSystem.Typography.footnote)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
            .listRowSeparator(.hidden)

            HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                Image(systemName: "clock.arrow.2.circlepath")
                    .font(.body)
                    .foregroundColor(.orange)
                    .frame(width: 24)
                Text(L.Settings.voiceChunkingTip)
                    .font(DesignSystem.Typography.footnote)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
        } header: {
            Text(L.Settings.aiSection)
        }
    }

    private var statsSection: some View {
        Section {
            Button {
                showStatistics = true
            } label: {
                HStack {
                    Label {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(L.Settings.statsButton)
                                .font(DesignSystem.Typography.callout)
                                .foregroundColor(DesignSystem.Colors.primaryText)
                            Text(L.Settings.statsDesc)
                                .font(DesignSystem.Typography.caption2)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                        }
                    } icon: {
                        Image(systemName: "chart.bar.xaxis")
                            .foregroundColor(DesignSystem.Colors.primary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.tertiaryText)
                }
            }
            .buttonStyle(PlainButtonStyle())
        } header: {
            Text(L.Settings.statsSection)
        }
    }

    private var appInfoSection: some View {
        Section {
            HStack {
                Text(L.Settings.version)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                Spacer()
                Text(appVersion)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }

            Button {
                if let url = URL(string: "https://www.instagram.com/mordecai_kwan") {
                    UIApplication.shared.open(url)
                }
            } label: {
                Label(L.Settings.contact, systemImage: "message")
                    .foregroundColor(DesignSystem.Colors.primaryText)
            }

            Button {
                // 지역 코드(/kr/) 포함 URL 재사용 — 미포함 시 기본 스토어프론트로 연결돼 "지역에서 사용 불가" 오류 발생
                if let url = URL(string: "\(PrayerExchangePackager.appStoreURL)?action=write-review") {
                    UIApplication.shared.open(url)
                }
            } label: {
                Label(L.Settings.review, systemImage: "star")
                    .foregroundColor(DesignSystem.Colors.primaryText)
            }

            Button {
                if let url = URL(string: "https://www.notion.so/prayanswer-2a1d59d95c59809fb0aac3ec8ba026e6?source=copy_link") {
                    UIApplication.shared.open(url)
                }
            } label: {
                Label(L.Settings.privacyPolicy, systemImage: "lock.shield")
                    .foregroundColor(DesignSystem.Colors.primaryText)
            }
        } header: {
            Text(L.Settings.appSection)
        }
    }
}

#Preview {
    SettingsView()
}
