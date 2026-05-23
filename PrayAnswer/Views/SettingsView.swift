//
//  SettingsView.swift
//  PrayAnswer
//

import SwiftUI
import StoreKit

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
            ForEach(guideItems, id: \.title) { item in
                FeatureGuideRow(icon: item.icon, color: item.color, title: item.title, description: item.description)
            }
        } header: {
            Text(L.Settings.guideSection)
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
                let email = "eunkwanbear@gmail.com"
                let subject = "PrayAnswer 문의"
                let urlString = "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
                if let url = URL(string: urlString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Label(L.Settings.contact, systemImage: "envelope")
                    .foregroundColor(DesignSystem.Colors.primaryText)
            }

            Button {
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    AppStore.requestReview(in: scene)
                }
            } label: {
                Label(L.Settings.review, systemImage: "star")
                    .foregroundColor(DesignSystem.Colors.primaryText)
            }

            Button {
                if let url = URL(string: "https://sites.google.com/view/prayanswer-privacy") {
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

    // MARK: - Guide Items Data

    private var guideItems: [GuideItem] {
        [
            GuideItem(icon: "hands.clap.fill",   color: DesignSystem.Colors.primary,      title: L.Guide.addPrayerTitle,   description: L.Guide.addPrayerDesc),
            GuideItem(icon: "tray.2.fill",        color: DesignSystem.Colors.wait,         title: L.Guide.storageTitle,     description: L.Guide.storageDesc),
            GuideItem(icon: "person.2.fill",      color: Color.blue,                       title: L.Guide.peopleTitle,      description: L.Guide.peopleDesc),
            GuideItem(icon: "heart.fill",         color: Color.red,                        title: L.Guide.favoriteTitle,    description: L.Guide.favoriteDesc),
            GuideItem(icon: "clock.badge.checkmark", color: Color.orange,                  title: L.Guide.habitTitle,       description: L.Guide.habitDesc),
            GuideItem(icon: "rectangle.3.group.fill", color: Color.indigo,                 title: L.Guide.widgetTitle,      description: L.Guide.widgetDesc),
            GuideItem(icon: "arrow.triangle.2.circlepath", color: DesignSystem.Colors.answered, title: L.Guide.exchangeTitle, description: L.Guide.exchangeDesc),
            GuideItem(icon: "square.and.arrow.up.fill", color: Color.teal,                 title: L.Guide.shareExtTitle,    description: L.Guide.shareExtDesc),
            GuideItem(icon: "folder.fill",        color: Color.yellow,                     title: L.Guide.collectionTitle,  description: L.Guide.collectionDesc),
            GuideItem(icon: "checkmark.seal.fill", color: DesignSystem.Colors.answered,    title: L.Guide.answerNoteTitle,  description: L.Guide.answerNoteDesc),
            GuideItem(icon: "mic.fill",           color: Color.purple,                     title: L.Guide.voiceAITitle,     description: L.Guide.voiceAIDesc),
        ]
    }
}

// MARK: - Supporting Types

private struct GuideItem {
    let icon: String
    let color: Color
    let title: String
    let description: String
}

private struct FeatureGuideRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                Text(description)
                    .font(DesignSystem.Typography.caption2)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, DesignSystem.Spacing.xs)
    }
}

#Preview {
    SettingsView()
}
