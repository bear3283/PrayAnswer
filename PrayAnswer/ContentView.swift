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
    @State private var selectedTab: Int = 0
    
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
        .tint(DesignSystem.Colors.primary) // 새로운 색상 시스템 적용
        .onAppear {
            setupTabBarAppearance()
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

// 개선된 기도 목록 뷰
struct PrayerListView: View {
    @Environment(\.modelContext) private var modelContext
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
            Group {
                if filteredPrayers.isEmpty {
                    VStack(spacing: 0) {
                        // 보관소 선택 섹션
                        ModernStorageSelector(selectedStorage: $selectedStorage, allPrayers: allPrayers)

                        EmptyStateView(storage: selectedStorage)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else {
                    List {
                        // 보관소 선택 섹션을 List 내부로 이동
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
            }
            .navigationTitle(L.Nav.prayerList)
            .navigationBarTitleDisplayMode(.large)
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
