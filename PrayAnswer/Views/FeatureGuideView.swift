//
//  FeatureGuideView.swift
//  PrayAnswer
//
//  설정에서 진입하는 사용법 안내 화면
//

import SwiftUI

struct FeatureGuideView: View {
    var body: some View {
        List {
            ForEach(guideItems, id: \.title) { item in
                FeatureGuideRow(icon: item.icon, color: item.color, title: item.title, description: item.description)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(L.Settings.guideSection)
        .navigationBarTitleDisplayMode(.inline)
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
    NavigationStack {
        FeatureGuideView()
    }
}
