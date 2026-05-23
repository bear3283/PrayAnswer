//
//  StatisticsView.swift
//  PrayAnswer
//

import SwiftUI
import SwiftData
import Charts

// MARK: - StatsPeriod

private enum StatsPeriod: String, CaseIterable {
    case all = "전체"
    case sixMonths = "6개월"
    case threeMonths = "3개월"
    case oneMonth = "1개월"

    var months: Int? {
        switch self {
        case .all: return nil
        case .sixMonths: return 6
        case .threeMonths: return 3
        case .oneMonth: return 1
        }
    }
}

// MARK: - InsightItem

private struct InsightItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let value: String
    let color: Color
}

// MARK: - StatsData (단일 패스 캐시)
// allPrayers를 한 번만 순회해서 모든 통계를 계산한다.
private struct StatsData {
    var filteredCount: Int = 0
    var favoritesCount: Int = 0
    var storageChartData: [(storage: PrayerStorage, count: Int)] = []
    var answerRateText: String = "0%"
    var monthlyData: [MonthlyCount] = []
    var insightItems: [InsightItem] = []
    var monthlyTotalLabel: String = ""
    var categoryData: [(category: PrayerCategory, count: Int)] = []
    var topTargets: [(target: String, count: Int)] = []

    init() {}

    init(prayers: [Prayer], period: StatsPeriod) {
        let calendar = Calendar.current
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "M월"

        // 기간 필터링
        let monthCount = period.months ?? 6
        let periodStart: Date?
        if let m = period.months,
           let start = calendar.date(byAdding: .month, value: -m, to: now) {
            periodStart = calendar.startOfDay(for: start)
        } else {
            periodStart = nil
        }

        let filtered: [Prayer]
        if let start = periodStart {
            filtered = prayers.filter { $0.createdDate >= start }
        } else {
            filtered = prayers
        }

        guard !filtered.isEmpty else { return }

        // 월별 경계 (monthCount개월)
        let monthBoundaries: [(start: Date, end: Date, label: String)] = (0..<monthCount).reversed().compactMap { offset in
            guard let date = calendar.date(byAdding: .month, value: -offset, to: now),
                  let start = calendar.date(from: calendar.dateComponents([.year, .month], from: date)),
                  let end = calendar.date(byAdding: .month, value: 1, to: start)
            else { return nil }
            return (start, end, formatter.string(from: date))
        }

        // ── 단일 패스 ──────────────────────────────
        var storageMap: [PrayerStorage: Int] = [:]
        var categoryMap: [PrayerCategory: Int] = [:]
        var targetMap: [String: Int] = [:]
        var monthlyMap: [String: Int] = [:]
        var favCount = 0

        for prayer in filtered {
            storageMap[prayer.storage, default: 0] += 1
            categoryMap[prayer.category, default: 0] += 1
            if prayer.isFavorite { favCount += 1 }
            if !prayer.target.isEmpty {
                targetMap[prayer.target, default: 0] += 1
            }
            for boundary in monthBoundaries
            where prayer.createdDate >= boundary.start && prayer.createdDate < boundary.end {
                monthlyMap[boundary.label, default: 0] += 1
                break
            }
        }

        // ── 결과 조합 ──────────────────────────────
        filteredCount = filtered.count
        favoritesCount = favCount

        storageChartData = PrayerStorage.allCases.map { s in
            (storage: s, count: storageMap[s] ?? 0)
        }

        let yesCount = storageMap[.yes] ?? 0
        let rate = Double(yesCount) / Double(filtered.count) * 100
        answerRateText = String(format: "%.0f%%", rate)

        monthlyData = monthBoundaries.map { b in
            MonthlyCount(label: b.label, count: monthlyMap[b.label] ?? 0)
        }

        let recentTotal = monthlyData.reduce(0) { $0 + $1.count }
        switch period {
        case .all:        monthlyTotalLabel = L.Stats.last6MonthsTotal(recentTotal)
        case .sixMonths:  monthlyTotalLabel = L.Stats.last6MonthsTotal(recentTotal)
        case .threeMonths: monthlyTotalLabel = "최근 3개월 합계 \(recentTotal)개"
        case .oneMonth:   monthlyTotalLabel = "최근 1개월 합계 \(recentTotal)개"
        }

        categoryData = PrayerCategory.allCases
            .compactMap { cat -> (category: PrayerCategory, count: Int)? in
                let c = categoryMap[cat] ?? 0
                return c > 0 ? (cat, c) : nil
            }
            .sorted { $0.count > $1.count }

        topTargets = targetMap
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { (target: $0.key, count: $0.value) }

        // ── 인사이트 카드 ────────────────────────────
        var insights: [InsightItem] = []

        // 기도 시작일 (기간 내 첫 기도부터 오늘까지)
        if let earliest = filtered.min(by: { $0.createdDate < $1.createdDate }) {
            let days = max(1, (calendar.dateComponents([.day],
                from: calendar.startOfDay(for: earliest.createdDate),
                to: calendar.startOfDay(for: now)).day ?? 0) + 1)
            insights.append(InsightItem(icon: "calendar.badge.clock",
                title: "기도 시작", value: "\(days)일째", color: .blue))
        }

        // 이번 달 추가된 기도
        let thisMonthStart = calendar.date(
            from: calendar.dateComponents([.year, .month], from: now)) ?? now
        let thisMonthCount = filtered.filter { $0.createdDate >= thisMonthStart }.count
        if thisMonthCount > 0 {
            insights.append(InsightItem(icon: "plus.circle.fill",
                title: "이번 달 추가", value: "\(thisMonthCount)개", color: DesignSystem.Colors.primary))
        }

        // 응답받은 기도
        let yesCountInsight = storageMap[.yes] ?? 0
        if yesCountInsight > 0 {
            insights.append(InsightItem(icon: "checkmark.seal.fill",
                title: "응답받은 기도", value: "\(yesCountInsight)개", color: DesignSystem.Colors.answered))
        }

        // 주 기도 분야
        if let topCat = categoryData.first {
            insights.append(InsightItem(icon: "tag.fill",
                title: "주 기도 분야", value: topCat.category.displayName,
                color: topCat.category.color))
        }

        // 가장 많이 기도한 대상
        if let topTarget = topTargets.first {
            insights.append(InsightItem(icon: "person.fill",
                title: "가장 많이 기도한 대상", value: topTarget.target, color: .orange))
        }

        insightItems = insights
    }
}

// MARK: - StatisticsView

struct StatisticsView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.modelContext) private var modelContext
    @Query private var allPrayers: [Prayer]
    @State private var animateCharts = false
    @State private var stats = StatsData()
    @State private var selectedPeriod: StatsPeriod = .all
    #if DEBUG
    @State private var showDummyDataConfirm = false
    #endif

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
        .navigationBarTitleDisplayMode(.inline)
        #if DEBUG
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showDummyDataConfirm = true
                } label: {
                    Image(systemName: "wand.and.stars")
                        .foregroundColor(.orange)
                }
            }
        }
        .confirmationDialog("더미 데이터 생성", isPresented: $showDummyDataConfirm, titleVisibility: .visible) {
            Button("생성 (기존 데이터 삭제됨)", role: .destructive) {
                ScreenshotDataGenerator.generateSampleData(in: modelContext)
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("스크린샷용 샘플 데이터를 생성합니다.\n기존 데이터가 모두 삭제됩니다.")
        }
        #endif
        .onAppear {
            rebuildStats()
            animateCharts = false
            withAnimation(.easeOut(duration: 0.7).delay(0.15)) {
                animateCharts = true
            }
        }
        .onChange(of: allPrayers) { rebuildStats() }
        .onChange(of: selectedPeriod) {
            rebuildStats()
            animateCharts = false
            withAnimation(.easeOut(duration: 0.5).delay(0.05)) {
                animateCharts = true
            }
        }
    }

    private func rebuildStats() {
        stats = StatsData(prayers: allPrayers, period: selectedPeriod)
    }

    // MARK: - Main Scroll Content

    private var mainScrollContent: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.xl) {
                periodPicker
                if !stats.insightItems.isEmpty {
                    insightCardsSection
                }
                summaryCards
                storageSection
                monthlySection
                if !stats.categoryData.isEmpty {
                    categorySection
                }
                if !stats.topTargets.isEmpty {
                    targetsSection
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.xl)
        }
    }

    // MARK: - Period Picker

    private var periodPicker: some View {
        Picker("기간", selection: $selectedPeriod) {
            ForEach(StatsPeriod.allCases, id: \.self) { period in
                Text(period.rawValue).tag(period)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Insight Cards

    private var insightCardsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.md) {
                ForEach(stats.insightItems) { item in
                    InsightCard(item: item)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
        }
        // LazyVStack에 이미 lg padding이 있으므로 bleed out
        .padding(.horizontal, -DesignSystem.Spacing.lg)
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
                value: "\(stats.filteredCount)",
                label: L.Stats.totalPrayers,
                icon: "hands.clap.fill",
                color: DesignSystem.Colors.primary
            )
            StatSummaryCard(
                value: stats.answerRateText,
                label: L.Stats.answerRate,
                icon: "checkmark.circle.fill",
                color: DesignSystem.Colors.answered
            )
            StatSummaryCard(
                value: "\(stats.favoritesCount)",
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
                    Chart(stats.storageChartData.filter { $0.count > 0 }, id: \.storage) { item in
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
                        Text("\(stats.filteredCount)")
                            .font(DesignSystem.Typography.title2)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                        Text(L.Stats.total)
                            .font(DesignSystem.Typography.caption2)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                }

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    ForEach(stats.storageChartData, id: \.storage) { item in
                        StorageLegendRow(
                            storage: item.storage,
                            count: item.count,
                            total: stats.filteredCount
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
                    ForEach(stats.monthlyData) { data in
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

                Text(stats.monthlyTotalLabel)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
        }
    }

    // MARK: - Category Distribution

    private var categorySection: some View {
        StatSectionCard(title: L.Stats.categoryDistribution) {
            Chart {
                ForEach(stats.categoryData, id: \.category) { item in
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
            .frame(height: CGFloat(stats.categoryData.count) * 36 + 20)
        }
    }

    // MARK: - Top Targets

    private var targetsSection: some View {
        StatSectionCard(title: L.Stats.topTargets) {
            VStack(spacing: 0) {
                ForEach(Array(stats.topTargets.enumerated()), id: \.offset) { index, item in
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

// MARK: - InsightCard

private struct InsightCard: View {
    let item: InsightItem

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: item.icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(item.color)
                Text(item.title)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
            Text(item.value)
                .font(DesignSystem.Typography.title3)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.md)
        .frame(minWidth: 110)
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .strokeBorder(item.color.opacity(0.25), lineWidth: 1)
        )
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
        case 1: return Color(red: 1.0, green: 0.84, blue: 0.0)
        case 2: return Color(.systemGray2)
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2)
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
