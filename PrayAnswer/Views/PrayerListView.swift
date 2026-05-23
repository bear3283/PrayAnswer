//
//  PrayerListView.swift
//  PrayAnswer
//

import SwiftUI
import SwiftData
import WidgetKit

// MARK: - Prayer List View

struct PrayerListView: View {
    var selectedTab: Int = 0
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Query private var allPrayers: [Prayer]
    @Query(sort: \PrayerCollection.sortOrder) private var collections: [PrayerCollection]
    @State private var selectedStorage: PrayerStorage = .wait
    @State private var selectedCollection: PrayerCollection? = nil
    @State private var showCollectionManager = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var prayerViewModel: PrayerViewModel?
    @State private var scrollOffset: CGFloat = 0
    @State private var navigationPath = NavigationPath()

    // 기도제목 보내기
    @State private var showMyPrayerExchange = false
    @State private var shareExtensionRefreshID: UUID = UUID()

    // 수동 정렬 모드
    @State private var isReorderMode = false
    @State private var listEditMode: EditMode = .inactive

    // 검색
    @State private var isSearchActive = false
    @State private var searchText = ""
    @State private var debouncedSearchText = ""   // 300ms debounce 적용된 검색어
    @State private var searchDebounceTask: Task<Void, Never>? = nil
    @FocusState private var isSearchFocused: Bool

    private var myRequestPrayers: [Prayer] {
        allPrayers.filter { $0.isMyRequest }
    }

    // 선택된 보관소 + 컬렉션 필터링 (검색 시 전체 보관소 대상)
    // debouncedSearchText를 사용해 타이핑마다 필터링하지 않음
    private var filteredPrayers: [Prayer] {
        _ = shareExtensionRefreshID  // Share Extension 저장 후 강제 재평가 의존성

        // 검색 모드: 전체 보관소에서 키워드 검색
        if isSearchActive && !debouncedSearchText.trimmingCharacters(in: .whitespaces).isEmpty {
            let q = debouncedSearchText.lowercased()
            return allPrayers
                .filter { prayer in
                    prayer.title.lowercased().contains(q) ||
                    prayer.content.lowercased().contains(q) ||
                    prayer.target.lowercased().contains(q)
                }
                .sorted { $0.createdDate > $1.createdDate }
        }

        var result = allPrayers.filter { $0.storage == selectedStorage }
        if let col = selectedCollection {
            result = result.filter { $0.collection?.persistentModelID == col.persistentModelID }
        }
        if isReorderMode {
            return result.sorted { a, b in
                if a.sortOrder != b.sortOrder { return a.sortOrder < b.sortOrder }
                return a.createdDate > b.createdDate
            }
        }
        return result.sorted { $0.createdDate > $1.createdDate }
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .top) {
                // 메인 컨텐츠
                if filteredPrayers.isEmpty && !isSearchActive {
                    VStack(spacing: 0) {
                        Color.clear.frame(height: 68)
                        MyPrayerBannerView(prayers: myRequestPrayers)
                            .padding(.horizontal, DesignSystem.Spacing.md)
                        ModernStorageSelector(selectedStorage: $selectedStorage, allPrayers: allPrayers)
                        CollectionFilterBar(
                            collections: collections,
                            selectedCollection: $selectedCollection,
                            onManage: { showCollectionManager = true }
                        )
                        EmptyStateView(storage: selectedStorage)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else {
                    List {
                        Section {
                            Color.clear.frame(height: 24)
                                .overlay(alignment: .top) {
                                    ScrollOffsetDetector()
                                }
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())

                        if !isSearchActive {
                            Section {
                                MyPrayerBannerView(prayers: myRequestPrayers)
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(
                                top: 0,
                                leading: DesignSystem.Spacing.md,
                                bottom: DesignSystem.Spacing.lg,
                                trailing: DesignSystem.Spacing.md
                            ))

                            Section {
                                ModernStorageSelector(selectedStorage: $selectedStorage, allPrayers: allPrayers)
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())

                            Section {
                                CollectionFilterBar(
                                    collections: collections,
                                    selectedCollection: $selectedCollection,
                                    onManage: { showCollectionManager = true },
                                    onDropToCollection: { collection, id in
                                        assignPrayer(transferID: id, to: collection)
                                    },
                                    onDropToAll: { id in
                                        assignPrayer(transferID: id, to: nil)
                                    }
                                )
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                        }

                        // 검색 결과 없음
                        if isSearchActive && !debouncedSearchText.trimmingCharacters(in: .whitespaces).isEmpty && filteredPrayers.isEmpty {
                            Section {
                                VStack(spacing: DesignSystem.Spacing.md) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 40))
                                        .foregroundColor(DesignSystem.Colors.tertiaryText)
                                    Text("'\(debouncedSearchText)'에 대한 검색 결과가 없습니다")
                                        .font(DesignSystem.Typography.body)
                                        .foregroundColor(DesignSystem.Colors.secondaryText)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, DesignSystem.Spacing.xl)
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }

                        ForEach(filteredPrayers, id: \Prayer.id) { (prayer: Prayer) in
                            ZStack {
                                if !isReorderMode {
                                    NavigationLink(value: prayer) { EmptyView() }
                                        .opacity(0)
                                }
                                ModernPrayerRow(prayer: prayer) {
                                    toggleFavorite(prayer)
                                }
                            }
                            .draggable(prayer.transferID)
                            .contextMenu {
                                Button {
                                    let text = [prayer.title, prayer.content]
                                        .filter { !$0.isEmpty }
                                        .joined(separator: "\n")
                                    UIPasteboard.general.string = text
                                } label: {
                                    Label("기도내용 복사", systemImage: "doc.on.doc")
                                }

                                Divider()

                                if prayer.storage != .yes {
                                    Button { changeStorage(prayer, to: .yes) } label: {
                                        Label("'YES' 보관함으로 이동", systemImage: "checkmark.circle")
                                    }
                                }
                                if prayer.storage != .no {
                                    Button { changeStorage(prayer, to: .no) } label: {
                                        Label("'NO' 보관함으로 이동", systemImage: "clock.arrow.circlepath")
                                    }
                                }
                                if prayer.storage != .wait {
                                    Button { changeStorage(prayer, to: .wait) } label: {
                                        Label("'WAIT' 보관함으로 이동", systemImage: "hands.sparkles")
                                    }
                                }

                                Divider()

                                Button { navigationPath.append(prayer) } label: {
                                    Label("편집", systemImage: "pencil")
                                }
                                Button(role: .destructive) { deletePrayer(prayer) } label: {
                                    Label("삭제", systemImage: "trash")
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
                        .onMove(perform: reorderPrayers)
                        .onDelete { indexSet in
                            let prayers = filteredPrayers
                            for index in indexSet {
                                guard index < prayers.count else { continue }
                                deletePrayer(prayers[index])
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                    .environment(\.editMode, $listEditMode)
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        scrollOffset = value
                    }
                }

                // 고정 헤더 오버레이
                VStack(spacing: 0) {
                    ZStack {
                        if isSearchActive {
                            HStack(spacing: DesignSystem.Spacing.sm) {
                                HStack(spacing: DesignSystem.Spacing.sm) {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(DesignSystem.Colors.secondaryText)
                                        .font(.system(size: 14))
                                    TextField("기도제목, 내용, 이름 검색", text: $searchText)
                                        .font(DesignSystem.Typography.body)
                                        .foregroundColor(DesignSystem.Colors.primaryText)
                                        .focused($isSearchFocused)
                                        .submitLabel(.search)
                                    if !searchText.isEmpty {
                                        Button {
                                            searchText = ""
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(DesignSystem.Colors.tertiaryText)
                                                .font(.system(size: 14))
                                        }
                                    }
                                }
                                .padding(.horizontal, DesignSystem.Spacing.sm)
                                .padding(.vertical, 8)
                                .background(DesignSystem.Colors.secondaryBackground)
                                .cornerRadius(DesignSystem.CornerRadius.medium)
                                .padding(.leading, DesignSystem.Spacing.lg)

                                Button("취소") {
                                    withAnimation {
                                        isSearchActive = false
                                        searchText = ""
                                        isSearchFocused = false
                                    }
                                }
                                .font(DesignSystem.Typography.callout)
                                .foregroundColor(DesignSystem.Colors.primary)
                                .padding(.trailing, DesignSystem.Spacing.lg)
                            }
                        } else {
                            Text(L.Nav.prayerList)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(DesignSystem.Colors.primaryText)
                                .frame(maxWidth: .infinity, alignment: .center)

                            HStack {
                                Button {
                                    withAnimation {
                                        isReorderMode.toggle()
                                        listEditMode = isReorderMode ? .active : .inactive
                                    }
                                } label: {
                                    Image(systemName: isReorderMode ? "checkmark" : "arrow.up.arrow.down")
                                        .font(.system(size: 19, weight: .medium))
                                        .foregroundColor(isReorderMode ? DesignSystem.Colors.answered : DesignSystem.Colors.primary)
                                }
                                .padding(.leading, DesignSystem.Spacing.lg)

                                Spacer()

                                if !isReorderMode {
                                    HStack(spacing: DesignSystem.Spacing.md) {
                                        Button {
                                            withAnimation {
                                                isSearchActive = true
                                                isSearchFocused = true
                                            }
                                        } label: {
                                            Image(systemName: "magnifyingglass")
                                                .font(.system(size: 19, weight: .medium))
                                                .foregroundColor(DesignSystem.Colors.primary)
                                                .frame(width: 36, height: 36)
                                        }
                                        Button {
                                            showMyPrayerExchange = true
                                        } label: {
                                            Image(systemName: "square.and.arrow.up")
                                                .font(.system(size: 19, weight: .medium))
                                                .foregroundColor(DesignSystem.Colors.primary)
                                                .frame(width: 36, height: 36)
                                        }
                                    }
                                    .padding(.trailing, DesignSystem.Spacing.lg)
                                }
                            }
                        }
                    }
                    .frame(height: 44)
                    .background(DesignSystem.Colors.background)

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
                updateWidgetDataOnAppear()
                PrayerLogger.shared.logMemoryUsage()
            }
            .onDisappear {
                PrayerLogger.shared.viewDidAppear("PrayerListView - onDisappear")
            }
            .alert(L.Alert.error, isPresented: $showingErrorAlert) {
                Button(L.Button.confirm) { }
            } message: {
                Text(errorMessage)
            }
            .sheet(isPresented: $showCollectionManager) {
                CollectionManagerView()
            }
            .sheet(isPresented: $showMyPrayerExchange) {
                PrayerExchangeView()
            }
            .onReceive(NotificationCenter.default.publisher(for: .prayerSavedFromShareExtension)) { _ in
                shareExtensionRefreshID = UUID()
            }
        }
        .onChange(of: selectedTab) {
            navigationPath = NavigationPath()
        }
        .onChange(of: collections) { _, newCollections in
            if let sel = selectedCollection,
               !newCollections.contains(where: { $0.persistentModelID == sel.persistentModelID }) {
                selectedCollection = nil
            }
        }
        .onChange(of: selectedStorage) {
            if isReorderMode {
                isReorderMode = false
                listEditMode = .inactive
            }
        }
        .onChange(of: selectedCollection) {
            if isReorderMode {
                isReorderMode = false
                listEditMode = .inactive
            }
        }
        .onChange(of: isSearchActive) {
            if isSearchActive && isReorderMode {
                isReorderMode = false
                listEditMode = .inactive
            }
            if !isSearchActive {
                searchDebounceTask?.cancel()
                debouncedSearchText = ""
            }
        }
        .onChange(of: searchText) { _, newValue in
            searchDebounceTask?.cancel()
            if newValue.trimmingCharacters(in: .whitespaces).isEmpty {
                debouncedSearchText = ""
                return
            }
            searchDebounceTask = Task {
                try? await Task.sleep(for: .milliseconds(300))
                guard !Task.isCancelled else { return }
                await MainActor.run { debouncedSearchText = newValue }
            }
        }
    }

    // MARK: - Private Helpers

    private func assignPrayer(transferID: String, to collection: PrayerCollection?) {
        guard let prayer = Prayer.find(by: transferID, in: allPrayers) else { return }
        prayer.collection = collection
        try? modelContext.save()
    }

    private func reorderPrayers(from source: IndexSet, to destination: Int) {
        var reordered = filteredPrayers
        reordered.move(fromOffsets: source, toOffset: destination)
        for (index, prayer) in reordered.enumerated() {
            prayer.sortOrder = index
        }
        try? modelContext.save()
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

    private func changeStorage(_ prayer: Prayer, to storage: PrayerStorage) {
        prayer.storage = storage
        try? modelContext.save()
        updateWidgetDataOnAppear()
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
        let allFavorites = allPrayers.filter { $0.isFavorite }
        var dataByStorage: [PrayerStorage: [PrayerWidgetData]] = [:]
        for prayer in allFavorites {
            let storage = prayer.storage
            dataByStorage[storage, default: []].append(prayer.toWidgetData())
        }
        WidgetDataManager.shared.shareFavoritePrayersByStorage(dataByStorage)
    }
}

// MARK: - Modern Storage Selector

struct ModernStorageSelector: View {
    @Binding var selectedStorage: PrayerStorage
    let allPrayers: [Prayer]

    @State private var storageCounts: [PrayerStorage: Int] = [:]

    private func rebuildCounts(_ prayers: [Prayer]) {
        let grouped = Dictionary(grouping: prayers) { $0.storage }
        var counts: [PrayerStorage: Int] = [:]
        for storage in PrayerStorage.allCases {
            counts[storage] = grouped[storage]?.count ?? 0
        }
        storageCounts = counts
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
        .onAppear { rebuildCounts(allPrayers) }
        .onChange(of: allPrayers) { rebuildCounts(allPrayers) }
    }
}
