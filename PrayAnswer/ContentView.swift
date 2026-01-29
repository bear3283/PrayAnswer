//
//  ContentView.swift
//  PrayAnswer
//
//  Created by bear on 6/29/25.
//

import SwiftUI
import SwiftData
import WidgetKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedTab: Int = 0

    var body: some View {
        if horizontalSizeClass == .regular {
            iPadContentView()
        } else {
            iPhoneContentView(selectedTab: $selectedTab)
        }
    }

    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground

        // 선택되지 않은 탭 아이템
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray,
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 4)

        // 선택된 탭 아이템
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(DesignSystem.Colors.primary)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(DesignSystem.Colors.primary),
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]
        appearance.stackedLayoutAppearance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 4)

        // 부드러운 shadow 적용
        appearance.shadowColor = UIColor.systemGray5

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - iPhone Content View (TabView-based)

struct iPhoneContentView: View {
    @Binding var selectedTab: Int

    var body: some View {
        TabView(selection: $selectedTab) {
            // 기도 목록 탭 (첫 번째 화면)
            PrayerListView()
                .tabItem {
                    Image(systemName: "list.bullet.rectangle.portrait")
                    Text(L.Tab.prayerList)
                }
                .tag(0)
            // 기도 추가 탭 (두 번째로 이동)
            AddPrayerView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "hands.clap")
                    Text(L.Tab.addPrayer)
                }
                .tag(1)

            // 기도대상자 탭 (세 번째 화면)
            PeopleListView()
                .tabItem {
                    Image(systemName: "person.2")
                    Text(L.Tab.people)
                }
                .tag(2)
        }
        .tint(DesignSystem.Colors.primary)
        .onAppear {
            setupTabBarAppearance()
        }
    }

    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground

        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray,
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 4)

        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(DesignSystem.Colors.primary)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(DesignSystem.Colors.primary),
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]
        appearance.stackedLayoutAppearance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 4)

        appearance.shadowColor = UIColor.systemGray5

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - iPad Content View (NavigationSplitView-based)

struct iPadContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allPrayers: [Prayer]
    @State private var selectedSection: iPadSection = .prayers
    @State private var selectedStorage: PrayerStorage = .wait
    @State private var selectedPrayer: Prayer?
    @State private var selectedPerson: String?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    enum iPadSection: String, CaseIterable, Identifiable {
        case prayers = "prayers"
        case people = "people"
        case addPrayer = "addPrayer"

        var id: String { rawValue }

        var title: String {
            switch self {
            case .prayers: return L.Tab.prayerList
            case .people: return L.Tab.people
            case .addPrayer: return L.Tab.addPrayer
            }
        }

        var icon: String {
            switch self {
            case .prayers: return "list.bullet.rectangle.portrait"
            case .people: return "person.2"
            case .addPrayer: return "hands.clap"
            }
        }
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Sidebar
            List {
                Section {
                    ForEach(iPadSection.allCases) { section in
                        Button {
                            selectedSection = section
                        } label: {
                            HStack {
                                Label(section.title, systemImage: section.icon)
                                Spacer()
                                if selectedSection == section {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(DesignSystem.Colors.primary)
                                }
                            }
                        }
                        .foregroundColor(selectedSection == section ? DesignSystem.Colors.primary : DesignSystem.Colors.primaryText)
                    }
                } header: {
                    Text("Pray")
                        .font(DesignSystem.Typography.title2)
                        .foregroundColor(DesignSystem.Colors.primary)
                        .padding(.bottom, DesignSystem.Spacing.sm)
                }

                if selectedSection == .prayers {
                    Section {
                        ForEach(PrayerStorage.allCases, id: \.self) { storage in
                            iPadStorageButton(
                                storage: storage,
                                count: prayerCount(for: storage),
                                isSelected: selectedStorage == storage
                            ) {
                                selectedStorage = storage
                                selectedPrayer = nil
                            }
                        }
                    } header: {
                        Text(L.StoragePicker.title)
                    }
                }
            }
            .listStyle(SidebarListStyle())
            .navigationTitle("Pray")
        } content: {
            // Content Column
            switch selectedSection {
            case .prayers:
                iPadPrayerListContentView(
                    selectedStorage: $selectedStorage,
                    selectedPrayer: $selectedPrayer,
                    allPrayers: allPrayers
                )
            case .people:
                iPadPeopleListContentView(
                    selectedPerson: $selectedPerson,
                    allPrayers: allPrayers
                )
            case .addPrayer:
                iPadAddPrayerContentView()
            }
        } detail: {
            // Detail Column
            switch selectedSection {
            case .prayers:
                if let prayer = selectedPrayer {
                    PrayerDetailView(prayer: prayer)
                } else {
                    iPadEmptyDetailView(
                        icon: "hands.sparkles",
                        title: L.Empty.storageTitle,
                        description: selectedStorage.localizedDescription
                    )
                }
            case .people:
                if let person = selectedPerson {
                    if person.isEmpty {
                        MyselfPrayerListView()
                    } else {
                        PersonDetailView(target: person)
                    }
                } else {
                    iPadEmptyDetailView(
                        icon: "person.2",
                        title: L.Empty.peopleTitle,
                        description: L.Empty.peopleDescription
                    )
                }
            case .addPrayer:
                iPadEmptyDetailView(
                    icon: "hands.clap",
                    title: L.Info.saveNotice,
                    description: L.Info.saveDescription
                )
            }
        }
        .navigationSplitViewStyle(.balanced)
        .tint(DesignSystem.Colors.primary)
    }

    private func prayerCount(for storage: PrayerStorage) -> Int {
        allPrayers.filter { $0.storage == storage }.count
    }
}

// MARK: - iPad Storage Button

struct iPadStorageButton: View {
    let storage: PrayerStorage
    let count: Int
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DesignSystem.Spacing.md) {
                StatusIndicator(storage: storage, size: .small, style: .circleWhite)

                VStack(alignment: .leading, spacing: 2) {
                    Text(storage.displayName)
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.primaryText)

                    Text("\(count)")
                        .font(DesignSystem.Typography.caption2)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.primary)
                }
            }
            .padding(.vertical, DesignSystem.Spacing.xs)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - iPad Prayer List Content View

struct iPadPrayerListContentView: View {
    @Binding var selectedStorage: PrayerStorage
    @Binding var selectedPrayer: Prayer?
    let allPrayers: [Prayer]

    private var filteredPrayers: [Prayer] {
        allPrayers.filter { $0.storage == selectedStorage }
            .sorted { $0.createdDate > $1.createdDate }
    }

    var body: some View {
        List(selection: $selectedPrayer) {
            ForEach(filteredPrayers) { prayer in
                iPadPrayerRow(prayer: prayer)
                    .tag(prayer)
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle(selectedStorage.displayName)
        .overlay {
            if filteredPrayers.isEmpty {
                EmptyStateView(storage: selectedStorage)
            }
        }
    }
}

// MARK: - iPad Prayer Row

struct iPadPrayerRow: View {
    let prayer: Prayer

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                StatusIndicator(storage: prayer.storage, size: .small)

                if prayer.hasTarget {
                    Text(prayer.target)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                        .lineLimit(1)
                }

                CategoryTag(category: prayer.category, size: .small)

                Spacer()

                if prayer.isFavorite {
                    Image(systemName: "heart.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }

            Text(prayer.content)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .lineLimit(2)

            HStack {
                if prayer.hasTargetDate {
                    DDayBadge(prayer: prayer, size: .small)
                }

                Spacer()

                Text(prayer.formattedCreatedDate)
                    .font(DesignSystem.Typography.caption2)
                    .foregroundColor(DesignSystem.Colors.tertiaryText)
            }
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
    }
}

// MARK: - iPad People List Content View

struct iPadPeopleListContentView: View {
    @Binding var selectedPerson: String?
    let allPrayers: [Prayer]

    private var myselfPrayers: [Prayer] {
        allPrayers.filter { $0.target.isEmpty }
    }

    private var prayersByTarget: [String: [Prayer]] {
        allPrayers.byTarget
    }

    private var sortedTargets: [String] {
        let targetsWithLatestDates = prayersByTarget.map { (target, prayers) in
            let latestDate = prayers.max { $0.createdDate < $1.createdDate }?.createdDate ?? Date.distantPast
            return (target: target, latestDate: latestDate)
        }

        return targetsWithLatestDates
            .sorted { $0.latestDate > $1.latestDate }
            .map { $0.target }
    }

    private var allDisplayTargets: [String] {
        var targets: [String] = []
        if !myselfPrayers.isEmpty {
            targets.append("")
        }
        targets.append(contentsOf: sortedTargets)
        return targets
    }

    var body: some View {
        List(selection: $selectedPerson) {
            ForEach(allDisplayTargets, id: \.self) { target in
                iPadPersonRow(
                    target: target,
                    prayers: prayersForTarget(target),
                    isMyself: target.isEmpty
                )
                .tag(target)
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle(L.Nav.peopleList)
        .overlay {
            if allDisplayTargets.isEmpty {
                EmptyPeopleStateView()
            }
        }
    }

    private func prayersForTarget(_ target: String) -> [Prayer] {
        if target.isEmpty {
            return myselfPrayers
        }
        return prayersByTarget[target] ?? []
    }
}

// MARK: - iPad Person Row

struct iPadPersonRow: View {
    let target: String
    let prayers: [Prayer]
    let isMyself: Bool

    private var displayName: String {
        isMyself ? L.Target.myself : target
    }

    private var waitCount: Int {
        prayers.filter { $0.storage == .wait }.count
    }

    private var yesCount: Int {
        prayers.filter { $0.storage == .yes }.count
    }

    private var noCount: Int {
        prayers.filter { $0.storage == .no }.count
    }

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    if isMyself {
                        Image(systemName: "person.fill")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.primary)
                    }

                    Text(displayName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(isMyself ? DesignSystem.Colors.primary : .primary)
                }

                HStack(spacing: DesignSystem.Spacing.sm) {
                    HStack(spacing: 4) {
                        Circle().fill(Color.orange).frame(width: 8, height: 8)
                        Text("\(waitCount)").font(.caption).foregroundColor(.secondary)
                    }
                    HStack(spacing: 4) {
                        Circle().fill(Color.green).frame(width: 8, height: 8)
                        Text("\(yesCount)").font(.caption).foregroundColor(.secondary)
                    }
                    HStack(spacing: 4) {
                        Circle().fill(Color.red).frame(width: 8, height: 8)
                        Text("\(noCount)").font(.caption).foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            Text("\(prayers.count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.primary)
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
    }
}

// MARK: - iPad Add Prayer Content View

struct iPadAddPrayerContentView: View {
    @State private var dummyTab: Int = 0

    var body: some View {
        AddPrayerView(selectedTab: $dummyTab)
            .navigationTitle(L.Nav.newPrayer)
    }
}

// MARK: - iPad Empty Detail View

struct iPadEmptyDetailView: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Image(systemName: icon)
                .font(.system(size: 64, weight: .light))
                .foregroundColor(DesignSystem.Colors.tertiaryText)

            VStack(spacing: DesignSystem.Spacing.sm) {
                Text(title)
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.secondaryText)

                Text(description)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.tertiaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.xxl)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.background)
    }
}

// MARK: - Prayer List View (Adaptive)

struct PrayerListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Query private var allPrayers: [Prayer]
    @State private var selectedStorage: PrayerStorage = .wait
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var prayerViewModel: PrayerViewModel?

    // 선택된 보관소에 따른 기도 목록 필터링
    private var filteredPrayers: [Prayer] {
        allPrayers.filter { $0.storage == selectedStorage }
            .sorted { $0.createdDate > $1.createdDate }
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                // 메인 컨텐츠
                if filteredPrayers.isEmpty {
                    VStack(spacing: 0) {
                        // 헤더 공간 확보
                        Color.clear.frame(height: 68)

                        // 보관소 선택 섹션
                        ModernStorageSelector(selectedStorage: $selectedStorage, allPrayers: allPrayers)

                        EmptyStateView(storage: selectedStorage)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else {
                    List {
                        // 헤더 공간 확보를 위한 상단 여백
                        Section {
                            Color.clear.frame(height: 24)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())

                        // 보관소 선택 섹션
                        Section {
                            ModernStorageSelector(selectedStorage: $selectedStorage, allPrayers: allPrayers)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())

                        ForEach(filteredPrayers) { prayer in
                            ZStack {
                                // 투명한 NavigationLink로 네비게이션 기능만 유지
                                NavigationLink(destination: PrayerDetailView(prayer: prayer)) {
                                    EmptyView()
                                }
                                .opacity(0)

                                // 실제 보이는 UI
                                ModernPrayerRow(prayer: prayer) {
                                    toggleFavorite(prayer)
                                }
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(
                                top: DesignSystem.Spacing.sm,
                                leading: DesignSystem.Spacing.md,
                                bottom: DesignSystem.Spacing.sm,
                                trailing: DesignSystem.Spacing.md
                            ))
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let prayer = filteredPrayers[index]
                                deletePrayer(prayer)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                }

                // 고정 헤더 오버레이 (iOS 전화 앱 스타일)
                VStack(spacing: 0) {
                    InlineHeader(title: L.Nav.prayerList, showFadeGradient: true)
                    Spacer()
                }
                .allowsHitTesting(false)
            }
            .navigationBarHidden(true)
            .background(DesignSystem.Colors.background)
            .onAppear {
                if prayerViewModel == nil {
                    prayerViewModel = PrayerViewModel(modelContext: modelContext)
                }

                // 앱 실행 시 위젯 데이터 업데이트
                updateWidgetDataOnAppear()

                // 메모리 사용량 로깅
                PrayerLogger.shared.logMemoryUsage()
            }
            .onDisappear {
                // 뷰가 사라질 때 정리 작업
                PrayerLogger.shared.viewDidAppear("PrayerListView - onDisappear")
            }
            .alert(L.Alert.error, isPresented: $showingErrorAlert) {
                Button(L.Button.confirm) { }
            } message: {
                Text(errorMessage)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func deletePrayer(_ prayer: Prayer) {
        guard let viewModel = prayerViewModel else {
            showError(L.Error.deleteFailed)
            return
        }

        do {
            try viewModel.deletePrayer(prayer)
            PrayerLogger.shared.userAction("목록에서 기도 삭제")
        } catch {
            showError(L.Error.deletePrayerFailed)
            PrayerLogger.shared.prayerOperationFailed("삭제", error: error)
        }
    }

    private func toggleFavorite(_ prayer: Prayer) {
        guard let viewModel = prayerViewModel else {
            showError(L.Error.favoriteFailed)
            return
        }

        do {
            try viewModel.toggleFavorite(prayer)
        } catch {
            showError(L.Error.favoriteToggleFailed)
            PrayerLogger.shared.prayerOperationFailed("즐겨찾기 토글", error: error)
        }
    }

    private func showError(_ message: String) {
        errorMessage = message
        showingErrorAlert = true
    }

    private func updateWidgetDataOnAppear() {
        // 모든 즐겨찾기 기도들을 가져와서 보관소별로 분류
        let allFavorites = allPrayers.filter { $0.isFavorite }
        let favoritesByStorage = Dictionary(grouping: allFavorites) { $0.storage }

        // 위젯 데이터 매니저를 통해 데이터 공유
        WidgetDataManager.shared.shareFavoritePrayersByStorage(favoritesByStorage)
    }
}

// 모던한 보관소 선택 섹션
struct ModernStorageSelector: View {
    @Binding var selectedStorage: PrayerStorage
    let allPrayers: [Prayer]

    // 각 보관소별 기도 개수 계산 (성능 최적화: Dictionary grouping 사용)
    private var storageCounts: [PrayerStorage: Int] {
        let grouped = Dictionary(grouping: allPrayers) { $0.storage }
        var counts: [PrayerStorage: Int] = [:]
        for storage in PrayerStorage.allCases {
            counts[storage] = grouped[storage]?.count ?? 0
        }
        return counts
    }

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(PrayerStorage.allCases, id: \.self) { storage in
                    ModernStorageCard(
                        storage: storage,
                        count: storageCounts[storage] ?? 0,
                        isSelected: selectedStorage == storage
                    ) {
                        withAnimation(DesignSystem.Animation.standard) {
                            selectedStorage = storage
                        }
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
        }
        .padding(.bottom, DesignSystem.Spacing.md)
    }
}

#Preview {
    ContentView()
}
