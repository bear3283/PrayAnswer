//
//  ContentView.swift
//  PrayAnswer
//
//  Created by bear on 6/29/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 기도 목록 탭 (첫 번째 화면으로 변경)
            PrayerListView()
                .tabItem {
                    Image(systemName: "list.bullet.rectangle.portrait")
                    Text("기도 목록")
                }
                .tag(0)
            
            // 기도 추가 탭 (두 번째로 이동)
            AddPrayerView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "hands.clap")
                    Text("기도 추가")
                }
                .tag(1)
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
    
    // 선택된 보관소에 따른 기도 목록 필터링
    private var filteredPrayers: [Prayer] {
        allPrayers.filter { $0.storage == selectedStorage }
            .sorted { $0.createdDate > $1.createdDate }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 새로운 보관소 선택 섹션
                ModernStorageSelector(selectedStorage: $selectedStorage, allPrayers: allPrayers)
                
                // 기도 목록
                List {
                    if filteredPrayers.isEmpty {
                        EmptyStateView(storage: selectedStorage)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                    } else {
                        ForEach(filteredPrayers) { prayer in
                            ZStack {
                                // 투명한 NavigationLink로 네비게이션 기능만 유지
                                NavigationLink(destination: PrayerDetailView(prayer: prayer)) {
                                    EmptyView()
                                }
                                .opacity(0)
                                
                                // 실제 보이는 UI
                                ModernPrayerRow(prayer: prayer)
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
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("기도 목록")
            .navigationBarTitleDisplayMode(.large)
            .background(DesignSystem.Colors.background)
        }
    }
    
    private func deletePrayer(_ prayer: Prayer) {
        modelContext.delete(prayer)
        do {
            try modelContext.save()
            PrayerLogger.shared.prayerDeleted(title: prayer.title)
            PrayerLogger.shared.userAction("목록에서 기도 삭제")
        } catch {
            PrayerLogger.shared.prayerOperationFailed("삭제", error: error)
        }
    }
}

// 모던한 보관소 선택 섹션
struct ModernStorageSelector: View {
    @Binding var selectedStorage: PrayerStorage
    let allPrayers: [Prayer]
    
    // 각 보관소별 기도 개수 계산
    private var storageCounts: [PrayerStorage: Int] {
        var counts: [PrayerStorage: Int] = [:]
        for storage in PrayerStorage.allCases {
            counts[storage] = allPrayers.filter { $0.storage == storage }.count
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
        .background(
            LinearGradient(
                colors: [
                    DesignSystem.Colors.secondaryBackground,
                    DesignSystem.Colors.background
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}



#Preview {
    ContentView()
}
