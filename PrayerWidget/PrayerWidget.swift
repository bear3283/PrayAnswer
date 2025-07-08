//
//  PrayerWidget.swift
//  PrayerWidget
//
//  Created by bear on 7/4/25.
//

import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Widget Entry
struct PrayerEntry: TimelineEntry {
    let date: Date
    let prayers: [PrayerWidgetData]
    let selectedStorage: PrayerStorage
}

// MARK: - Widget Provider
struct PrayerProvider: TimelineProvider {
    func placeholder(in context: Context) -> PrayerEntry {
        PrayerEntry(
            date: Date(),
            prayers: [],
            selectedStorage: .wait
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (PrayerEntry) -> ()) {
        let entry = PrayerEntry(
            date: Date(),
            prayers: [],
            selectedStorage: .wait
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let prayers = await loadFavoritePrayers()
            let entry = PrayerEntry(
                date: Date(),
                prayers: prayers,
                selectedStorage: .wait
            )
            
            // 1시간마다 업데이트
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
            completion(timeline)
        }
    }
    
    private func loadFavoritePrayers() async -> [PrayerWidgetData] {
        return WidgetDataManager.shared.loadFavoritePrayers()
    }
}

// MARK: - Widget Entry View
struct PrayerWidgetEntryView: View {
    var entry: PrayerProvider.Entry
    
    var body: some View {
        SharedWidgetEntryView(
            prayers: entry.prayers,
            storage: entry.selectedStorage
        )
    }
}

// MARK: - Widget Configuration
struct PrayerWidget: Widget {
    let kind: String = "PrayerWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerProvider()) { entry in
            PrayerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("기도 즐겨찾기")
        .description("즐겨찾기한 기도들을 홈 화면에서 바로 확인하세요.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
