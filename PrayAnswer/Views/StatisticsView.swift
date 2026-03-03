//
//  StatisticsView.swift
//  PrayAnswer
//

import SwiftUI
import SwiftData
import Charts

// MARK: - StatisticsView

struct StatisticsView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Query private var allPrayers: [Prayer]
    @State private var animateCharts = false

    // MARK: - Computed Properties

    private var storageChartData: [(storage: PrayerStorage, count: Int)] {
        PrayerStorage.allCases.map { s in
            (storage: s, count: allPrayers.filter { $0.storage == s }.count)
        }
    }

    private var answerRateText: String {
        guard !allPrayers.isEmpty else { return "0%" }
        let rate = Double(allPrayers.filter { $0.storage == .yes }.count) / Double(allPrayers.count) * 100
        return String(format: "%.0f%%", rate)
    }

    private var monthlyData: [MonthlyCount] {
        let calendar = Calendar.current
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "M월"
        return (0..<6).reversed().compactMap { offset -> MonthlyCount? in
            guard let date = calendar.date(byAdding: .month, value: -offset, to: now),
                  let start = calendar.date(from: calendar.dateComponents([.year, .month], from: date)),
                  let end = calendar.date(byAdding: .month, value: 1, to: start)
            else { return nil }
            let count = allPrayers.filter { $0.createdDate >= start && $0.createdDate < end }.count
            return MonthlyCount(label: formatter.string(from: date), count: count)
        }
    }

    private var categoryData: [(category: PrayerCategory, count: Int)] {
        PrayerCategory.allCases
            .map { cat in (category: cat, count: allPrayers.filter { $0.category == cat }.count) }
            .filter { $0.count > 0 }
            .sorted { $0.count > $1.count }
    }

    private var topTargets: [(target: String, count: Int)] {
        let grouped = Dictionary(grouping: allPrayers.filter { !$0.target.isEmpty }) { $0.target }
        return grouped.map { ($0.key, $0.value.count) }
            .sorted { $0.1 > $1.1 }
            .prefix(5)
            .map { $0 }
    }

    // MARK: - Body

    var body: some View {
        if horizontalSizeClass == .regular {
            statisticsContent
        } else {
            NavigationStack {
                statisticsContent
            }
        }
    }

    @ViewBuilder
    private var statisticsContent: some View {
        Group {
            if allPrayers.isEmpty {
                emptyStateView
            } else {
                mainScrollContent
            }
        }
        .background(DesignSystem.Colors.secondaryBackground)
        .navigationTitle(L.Stats.title)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            animateCharts = false
            withAnimation(.easeOut(duration: 0.7).delay(0.15)) {
                animateCharts = true
            }
        }
    }

    // MARK: - Main Scroll Content

    private var mainScrollContent: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.xl) {
                summaryCards
                storageSection
                monthlySection
                if !categoryData.isEmpty {
                    categorySection
                }
                if !topTargets.isEmpty {
                    targetsSection
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.xl)
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 64))
                .foregroundColor(DesignSystem.Colors.tertiaryText)
                .symbolRenderingMode(.hierarchical)
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text(L.Stats.emptyTitle)
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                Text(L.Stats.emptyDescription)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.tertiaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.xxxl)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Summary Cards

    private var summaryCards: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            StatSummaryCard(
                value: "\(allPrayers.count)",
                label: L.Stats.totalPrayers,
                icon: "hands.clap.fill",
                color: DesignSystem.Colors.primary
            )
            StatSummaryCard(
                value: answerRateText,
                label: L.Stats.answerRate,
                icon: "checkmark.circle.fill",
                color: DesignSystem.Colors.answered
            )
            StatSummaryCard(
                value: "\(allPrayers.totalFavoritePrayers)",
                label: L.Stats.favorites,
                icon: "heart.fill",
                color: .pink
            )
        }
    }

    // MARK: - Storage Distribution

    private var storageSection: some View {
        StatSectionCard(title: L.Stats.storageDistribution) {
            HStack(alignment: .center, spacing: DesignSystem.Spacing.xl) {
                ZStack {
                    Chart(storageChartData.filter { $0.count > 0 }, id: \.storage) { item in
                        SectorMark(
                            angle: .value("count", item.count),
                            innerRadius: .ratio(0.58),
                            angularInset: 1.5
                        )
                        .foregroundStyle(item.storage.color)
                        .cornerRadius(3)
                    }
                    .frame(width: 130, height: 130)
                    .opacity(animateCharts ? 1 : 0)
                    .scaleEffect(animateCharts ? 1 : 0.7)
                    .animation(.spring(duration: 0.6).delay(0.1), value: animateCharts)

                    VStack(spacing: 2) {
                        Text("\(allPrayers.count)")
                            .font(DesignSystem.Typography.title2)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                        Text(L.Stats.total)
                            .font(DesignSystem.Typography.caption2)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                }

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    ForEach(storageChartData, id: \.storage) { item in
                        StorageLegendRow(
                            storage: item.storage,
                            count: item.count,
                            total: allPrayers.count
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    // MARK: - Monthly Activity

    private var monthlySection: some View {
        StatSectionCard(title: L.Stats.monthlyActivity) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Chart {
                    ForEach(monthlyData) { data in
                        BarMark(
                            x: .value("월", data.label),
                            y: .value("기도", animateCharts ? data.count : 0)
                        )
                        .foregroundStyle(DesignSystem.Colors.primary.gradient)
                        .cornerRadius(6)
                        .annotation(position: .top) {
                            if animateCharts && data.count > 0 {
                                Text("\(data.count)")
                                    .font(DesignSystem.Typography.caption2)
                                    .foregroundColor(DesignSystem.Colors.secondaryText)
                            }
                        }
                    }
                }
                .frame(height: 160)
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) {
                        AxisGridLine().foregroundStyle(Color.secondary.opacity(0.15))
                        AxisValueLabel()
                    }
                }

                let recentTotal = monthlyData.reduce(0) { $0 + $1.count }
                Text(L.Stats.last6MonthsTotal(recentTotal))
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
        }
    }

    // MARK: - Category Distribution

    private var categorySection: some View {
        StatSectionCard(title: L.Stats.categoryDistribution) {
            Chart {
                ForEach(categoryData, id: \.category) { item in
                    BarMark(
                        x: .value("기도 수", animateCharts ? item.count : 0),
                        y: .value("카테고리", item.category.displayName)
                    )
                    .foregroundStyle(item.category.color)
                    .cornerRadius(4)
                    .annotation(position: .trailing) {
                        if animateCharts {
                            Text("\(item.count)")
                                .font(DesignSystem.Typography.caption2)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 4)) {
                    AxisGridLine().foregroundStyle(Color.secondary.opacity(0.15))
                    AxisValueLabel()
                }
            }
            .frame(height: CGFloat(categoryData.count) * 36 + 20)
        }
    }

    // MARK: - Top Targets

    private var targetsSection: some View {
        StatSectionCard(title: L.Stats.topTargets) {
            VStack(spacing: 0) {
                ForEach(Array(topTargets.enumerated()), id: \.offset) { index, item in
                    if index > 0 {
                        Divider()
                            .padding(.leading, DesignSystem.Spacing.xxxl)
                    }
                    TargetRankRow(rank: index + 1, target: item.target, count: item.count)
                }
            }
        }
    }
}

// MARK: - Supporting Types

private struct MonthlyCount: Identifiable {
    var id: String { label }
    let label: String
    let count: Int
}

// MARK: - StatSummaryCard

private struct StatSummaryCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        ModernCard {
            VStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(color)
                    .symbolRenderingMode(.hierarchical)
                Text(value)
                    .font(DesignSystem.Typography.title2)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Text(label)
                    .font(DesignSystem.Typography.caption2)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(.vertical, DesignSystem.Spacing.lg)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - StatSectionCard

private struct StatSectionCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                Text(title)
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                content()
            }
            .padding(DesignSystem.Spacing.lg)
        }
    }
}

// MARK: - StorageLegendRow

private struct StorageLegendRow: View {
    let storage: PrayerStorage
    let count: Int
    let total: Int

    private var percentText: String {
        guard total > 0 else { return "0%" }
        return String(format: "%.0f%%", Double(count) / Double(total) * 100)
    }

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            RoundedRectangle(cornerRadius: 3)
                .fill(storage.color)
                .frame(width: 12, height: 12)
            Text(storage.displayName)
                .font(DesignSystem.Typography.subheadline)
                .foregroundColor(DesignSystem.Colors.primaryText)
            Spacer()
            Text("\(count)")
                .font(DesignSystem.Typography.callout)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.primaryText)
            Text(percentText)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .frame(width: 40, alignment: .trailing)
        }
    }
}

// MARK: - TargetRankRow

private struct TargetRankRow: View {
    let rank: Int
    let target: String
    let count: Int

    private var rankColor: Color {
        switch rank {
        case 1: return Color(red: 1.0, green: 0.84, blue: 0.0)    // gold
        case 2: return Color(.systemGray2)                          // silver
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2)     // bronze
        default: return DesignSystem.Colors.tertiaryText
        }
    }

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Text("\(rank)")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(rankColor)
                .frame(width: 24, alignment: .center)
            Text(target)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .lineLimit(1)
            Spacer()
            HStack(spacing: 2) {
                Text("\(count)")
                    .font(DesignSystem.Typography.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                Text(L.Counter.count)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.tertiaryText)
            }
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
    }
}
