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
            PrayerListView(selectedTab: selectedTab)
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
            PeopleListView(selectedTab: selectedTab)
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
    @State private var addPrayerRecordedText: String = ""

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
            sidebarContent
        } content: {
            contentColumn
        } detail: {
            detailColumn
        }
        .navigationSplitViewStyle(.balanced)
        .tint(DesignSystem.Colors.primary)
    }

    // MARK: - Sidebar

    @ViewBuilder
    private var sidebarContent: some View {
        List {
            Section {
                ForEach(iPadSection.allCases) { section in
                    Button {
                        selectedSection = section
                        withAnimation {
                            columnVisibility = .all
                        }
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
        .scrollContentBackground(.hidden)
        .background(DesignSystem.Colors.background)
        .navigationTitle("Pray")
    }

    // MARK: - Content Column

    @ViewBuilder
    private var contentColumn: some View {
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
            iPadAddPrayerSidePanel(recordedText: $addPrayerRecordedText)
        }
    }

    // MARK: - Detail Column

    @ViewBuilder
    private var detailColumn: some View {
        switch selectedSection {
        case .prayers:
            prayerDetailContent
        case .people:
            peopleDetailContent
        case .addPrayer:
            iPadAddPrayerDetailView(recordedText: $addPrayerRecordedText)
        }
    }

    @ViewBuilder
    private var prayerDetailContent: some View {
        if let prayer = selectedPrayer {
            PrayerDetailView(prayer: prayer)
        } else {
            iPadEmptyDetailView(
                icon: "hands.sparkles",
                title: L.Empty.storageTitle,
                description: selectedStorage.localizedDescription
            )
        }
    }

    @ViewBuilder
    private var peopleDetailContent: some View {
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

// MARK: - iPad Add Prayer Side Panel (인라인 녹음 UI)

struct iPadAddPrayerSidePanel: View {
    @Binding var recordedText: String

    @State private var isRecordingMode = false
    @State private var showVoicePermissionAlert = false
    @State private var pulseAnimation = false
    @Bindable var speechManager = SpeechRecognitionManager.shared

    // AI 기능
    @State private var isAIProcessing = false
    @State private var showAISummaryPreview = false
    @State private var summarizedText = ""
    @State private var aiErrorMessage: String?
    @AppStorage("aiFeatureEnabled") private var isAIUserEnabled: Bool = true

    private var isAIAvailable: Bool {
        AIFeatureAvailability.isSupported
    }

    private var isAISystemSupported: Bool {
        AIFeatureAvailability.isSystemSupported
    }

    var body: some View {
        VStack(spacing: 0) {
            if isRecordingMode {
                inlineRecordingView
            } else {
                idleStateView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.secondaryBackground)
        .navigationTitle(L.Voice.recording)
        .sheet(isPresented: $showVoicePermissionAlert) {
            permissionAlert
        }
        .sheet(isPresented: $showAISummaryPreview) {
            AISummaryPreviewView(
                originalText: speechManager.recognizedText,
                summarizedText: $summarizedText,
                onApply: {
                    recordedText = summarizedText
                    speechManager.clearText()
                    showAISummaryPreview = false
                    isRecordingMode = false
                },
                onCancel: {
                    showAISummaryPreview = false
                },
                onRetry: {
                    showAISummaryPreview = false
                    performAISummarization()
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Idle State (녹음 대기 상태)

    @ViewBuilder
    private var idleStateView: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()

            Button(action: startVoiceRecording) {
                VStack(spacing: DesignSystem.Spacing.md) {
                    ZStack {
                        Circle()
                            .fill(DesignSystem.Colors.primary)
                            .frame(width: 80, height: 80)
                            .shadow(color: DesignSystem.Colors.primary.opacity(0.3), radius: 10, x: 0, y: 5)

                        Image(systemName: "mic.fill")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(.white)
                    }

                    Text(L.Voice.tapToStart)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                }
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()

            VStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "hand.point.right.fill")
                    .font(.title2)
                    .foregroundColor(DesignSystem.Colors.tertiaryText)

                Text("오른쪽에서\n기도를 작성하세요")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.tertiaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, DesignSystem.Spacing.xxl)
        }
    }

    // MARK: - Inline Recording View (녹음 중 상태)

    @ViewBuilder
    private var inlineRecordingView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // AI 토글 버튼
            if isAISystemSupported {
                HStack {
                    Spacer()
                    aiToggleButton
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.top, DesignSystem.Spacing.md)
            }

            Spacer()

            // 녹음 버튼
            recordingButton

            // 상태 텍스트
            statusText

            // 인식된 텍스트
            if !speechManager.recognizedText.isEmpty {
                recognizedTextView
            }

            Spacer()

            // 하단 버튼들
            actionButtons
                .padding(.bottom, DesignSystem.Spacing.xl)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    @ViewBuilder
    private var aiToggleButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                isAIUserEnabled.toggle()
            }
        }) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: isAIUserEnabled ? "sparkles" : "sparkles.slash")
                    .font(.caption2)
                Text(isAIUserEnabled ? "AI" : "AI")
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .foregroundColor(isAIUserEnabled ? .cyan : DesignSystem.Colors.tertiaryText)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(
                isAIUserEnabled
                    ? LinearGradient(
                        colors: [.purple.opacity(0.2), .cyan.opacity(0.2)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    : LinearGradient(
                        colors: [DesignSystem.Colors.tertiaryText.opacity(0.1)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
            )
            .cornerRadius(DesignSystem.CornerRadius.small)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isAIProcessing)
    }

    @ViewBuilder
    private var recordingButton: some View {
        ZStack {
            // 펄스 애니메이션
            if speechManager.isRecording {
                Circle()
                    .fill(DesignSystem.Colors.primary.opacity(0.2))
                    .frame(width: 100, height: 100)
                    .scaleEffect(pulseAnimation ? 1.3 : 1.0)
                    .opacity(pulseAnimation ? 0 : 0.5)
                    .animation(
                        .easeInOut(duration: 1.0).repeatForever(autoreverses: false),
                        value: pulseAnimation
                    )
            }

            if isAIProcessing {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple.opacity(0.2), .cyan.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                    .animation(
                        .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                        value: pulseAnimation
                    )
            }

            Button(action: {
                if !isAIProcessing {
                    speechManager.toggleRecording()
                }
            }) {
                Circle()
                    .fill(
                        isAIProcessing
                            ? LinearGradient(colors: [.purple, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(
                                colors: [speechManager.isRecording ? .red : DesignSystem.Colors.primary,
                                         speechManager.isRecording ? .red : DesignSystem.Colors.primary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
                    .frame(width: 70, height: 70)
                    .shadow(
                        color: (speechManager.isRecording ? Color.red : DesignSystem.Colors.primary).opacity(0.3),
                        radius: 10,
                        x: 0,
                        y: 5
                    )
                    .overlay(
                        Group {
                            if isAIProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.2)
                            } else {
                                Image(systemName: speechManager.isRecording ? "stop.fill" : "mic.fill")
                                    .font(.system(size: 28, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isAIProcessing)
        }
        .onAppear { pulseAnimation = true }
    }

    @ViewBuilder
    private var statusText: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            if isAIProcessing {
                Text(L.AI.summarizing)
                    .font(DesignSystem.Typography.callout)
                    .foregroundStyle(
                        LinearGradient(colors: [.purple, .cyan], startPoint: .leading, endPoint: .trailing)
                    )
            } else {
                Text(speechManager.isRecording ? L.Voice.listening : L.Voice.tapToStart)
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.primaryText)
            }

            if let errorMessage = speechManager.errorMessage ?? aiErrorMessage {
                Text(errorMessage)
                    .font(DesignSystem.Typography.caption2)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
        }
    }

    @ViewBuilder
    private var recognizedTextView: some View {
        ScrollView {
            Text(speechManager.recognizedText)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(DesignSystem.Spacing.md)
        }
        .frame(maxHeight: 150)
        .background(DesignSystem.Colors.cardBackground)
        .cornerRadius(DesignSystem.CornerRadius.medium)
    }

    @ViewBuilder
    private var actionButtons: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            // AI 정리 버튼
            if !speechManager.recognizedText.isEmpty && !speechManager.isRecording && isAIAvailable {
                Button(action: performAISummarization) {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: "sparkles")
                            .font(.caption)
                        Text(L.AI.summarize)
                            .font(DesignSystem.Typography.caption)
                    }
                    .foregroundStyle(
                        LinearGradient(colors: [.purple, .cyan], startPoint: .leading, endPoint: .trailing)
                    )
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                    .background(
                        LinearGradient(
                            colors: [.purple.opacity(0.15), .cyan.opacity(0.15)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(isAIProcessing)
            }

            HStack(spacing: DesignSystem.Spacing.md) {
                // 취소 버튼
                Button(action: {
                    speechManager.stopRecording()
                    speechManager.clearText()
                    isRecordingMode = false
                }) {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: "xmark")
                            .font(.caption)
                        Text(L.Voice.cancel)
                            .font(DesignSystem.Typography.caption)
                    }
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                    .background(DesignSystem.Colors.cardBackground)
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(isAIProcessing)

                // 텍스트 사용 버튼
                if !speechManager.recognizedText.isEmpty && !speechManager.isRecording {
                    Button(action: {
                        recordedText = speechManager.recognizedText
                        speechManager.clearText()
                        isRecordingMode = false
                    }) {
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Image(systemName: "checkmark")
                                .font(.caption)
                            Text(L.Voice.useText)
                                .font(DesignSystem.Typography.caption)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        .padding(.vertical, DesignSystem.Spacing.sm)
                        .background(DesignSystem.Colors.primary)
                        .cornerRadius(DesignSystem.CornerRadius.medium)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(isAIProcessing)
                }
            }
        }
    }

    @ViewBuilder
    private var permissionAlert: some View {
        VStack {
            Spacer()
            VoicePermissionAlert(
                onOpenSettings: {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                    showVoicePermissionAlert = false
                },
                onCancel: {
                    showVoicePermissionAlert = false
                }
            )
            Spacer()
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Actions

    private func startVoiceRecording() {
        if speechManager.checkPermissions() {
            isRecordingMode = true
            // 약간의 딜레이 후 녹음 시작 (toggleRecording 내부에서 try-catch 처리됨)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                speechManager.toggleRecording()
            }
        } else {
            speechManager.requestAllPermissions { granted in
                if granted {
                    isRecordingMode = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        speechManager.toggleRecording()
                    }
                } else {
                    showVoicePermissionAlert = true
                }
            }
        }
    }

    private func performAISummarization() {
        guard !speechManager.recognizedText.isEmpty else { return }

        isAIProcessing = true
        aiErrorMessage = nil

        Task {
            do {
                if #available(iOS 26.0, *) {
                    let result = try await AISummarizationManager.shared.summarize(text: speechManager.recognizedText)
                    await MainActor.run {
                        summarizedText = result
                        isAIProcessing = false
                        showAISummaryPreview = true
                    }
                } else {
                    await MainActor.run {
                        aiErrorMessage = L.AI.errorRequiresiOS26
                        isAIProcessing = false
                    }
                }
            } catch {
                await MainActor.run {
                    aiErrorMessage = error.localizedDescription
                    isAIProcessing = false
                }
            }
        }
    }
}

// MARK: - iPad Add Prayer Detail View (넓은 영역 - 폼)

struct iPadAddPrayerDetailView: View {
    @Binding var recordedText: String
    @State private var dummyTab: Int = 0

    var body: some View {
        AddPrayerView(selectedTab: $dummyTab, externalRecordedText: $recordedText)
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
    var selectedTab: Int = 0
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Query private var allPrayers: [Prayer]
    @State private var selectedStorage: PrayerStorage = .wait
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var prayerViewModel: PrayerViewModel?
    @State private var scrollOffset: CGFloat = 0
    @State private var navigationPath = NavigationPath()

    // 공유 기능
    @State private var isShareMode: Bool = false
    @State private var selectedPrayersForShare: Set<String> = []  // Prayer ID
    @State private var showShareSheet: Bool = false

    // 선택된 보관소에 따른 기도 목록 필터링
    private var filteredPrayers: [Prayer] {
        allPrayers.filter { $0.storage == selectedStorage }
            .sorted { $0.createdDate > $1.createdDate }
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
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
                        // 헤더 공간 확보를 위한 상단 여백 + 스크롤 오프셋 감지
                        Section {
                            Color.clear.frame(height: 24)
                                .overlay(alignment: .top) {
                                    ScrollOffsetDetector()
                                }
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

                        ForEach(filteredPrayers, id: \Prayer.id) { (prayer: Prayer) in
                            if isShareMode {
                                // 공유 모드: 선택 가능한 행
                                let prayerIdString = String(describing: prayer.id)
                                ShareSelectablePrayerRow(
                                    prayer: prayer,
                                    isSelected: selectedPrayersForShare.contains(prayerIdString)
                                ) {
                                    if selectedPrayersForShare.contains(prayerIdString) {
                                        selectedPrayersForShare.remove(prayerIdString)
                                    } else {
                                        selectedPrayersForShare.insert(prayerIdString)
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
                            } else {
                                // 일반 모드: 네비게이션 가능한 행
                                ZStack {
                                    // 투명한 NavigationLink로 네비게이션 기능만 유지
                                    NavigationLink(value: prayer) {
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
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        scrollOffset = value
                    }
                }

                // 고정 헤더 오버레이 (iOS 전화 앱 스타일)
                VStack(spacing: 0) {
                    HStack {
                        // 공유 모드 취소 버튼
                        if isShareMode {
                            Button(action: {
                                withAnimation {
                                    isShareMode = false
                                    selectedPrayersForShare.removeAll()
                                }
                            }) {
                                Text(L.Share.cancel)
                                    .font(DesignSystem.Typography.callout)
                                    .foregroundColor(DesignSystem.Colors.primary)
                            }
                            .padding(.leading, DesignSystem.Spacing.lg)
                        } else {
                            Color.clear.frame(width: 60)
                        }

                        Spacer()

                        Text(isShareMode ? L.Share.selectPrayers : L.Nav.prayerList)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(DesignSystem.Colors.primaryText)

                        Spacer()

                        // 공유 버튼
                        if isShareMode {
                            Button(action: {
                                if !selectedPrayersForShare.isEmpty {
                                    showShareSheet = true
                                }
                            }) {
                                Text(L.Share.share)
                                    .font(DesignSystem.Typography.callout)
                                    .fontWeight(.semibold)
                                    .foregroundColor(selectedPrayersForShare.isEmpty ? DesignSystem.Colors.tertiaryText : DesignSystem.Colors.primary)
                            }
                            .disabled(selectedPrayersForShare.isEmpty)
                            .padding(.trailing, DesignSystem.Spacing.lg)
                        } else if !filteredPrayers.isEmpty {
                            Button(action: {
                                withAnimation {
                                    isShareMode = true
                                }
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 17))
                                    .foregroundColor(DesignSystem.Colors.primary)
                            }
                            .padding(.trailing, DesignSystem.Spacing.lg)
                        } else {
                            Color.clear.frame(width: 60)
                        }
                    }
                    .frame(height: 44)
                    .background(DesignSystem.Colors.background)

                    // 페이드 그라데이션
                    LinearGradient(
                        gradient: Gradient(colors: [
                            DesignSystem.Colors.background,
                            DesignSystem.Colors.background.opacity(0.8),
                            DesignSystem.Colors.background.opacity(0.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 16)
                    .opacity(min(1.0, max(0.0, -scrollOffset / 30.0)))
                    .allowsHitTesting(false)

                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: Prayer.self) { prayer in
                PrayerDetailView(prayer: prayer)
            }
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
            .sheet(isPresented: $showShareSheet, onDismiss: {
                // 공유 완료 후 일반 모드로 복귀
                withAnimation {
                    isShareMode = false
                    selectedPrayersForShare.removeAll()
                }
            }) {
                ShareSheet(activityItems: [generateShareText()])
                    .presentationDetents([.medium, .large])
            }
        }
        .onChange(of: selectedTab) {
            navigationPath = NavigationPath()
            // 탭 변경 시 공유 모드 종료
            if isShareMode {
                isShareMode = false
                selectedPrayersForShare.removeAll()
            }
        }
    }

    // MARK: - Share Functions

    private func generateShareText() -> String {
        let selectedPrayers = filteredPrayers.filter { (prayer: Prayer) -> Bool in
            selectedPrayersForShare.contains(String(describing: prayer.id))
        }

        let lines = selectedPrayers.map { prayer in
            let targetName = prayer.target.isEmpty ? L.Target.myself : prayer.target
            return "\(targetName) - \(prayer.content)"
        }

        return lines.joined(separator: "\n\n")
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
