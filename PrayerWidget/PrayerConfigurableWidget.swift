import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

// MARK: - Simple Storage Widget Entry
struct StoragePrayerEntry: TimelineEntry {
    let date: Date
    let prayers: [PrayerWidgetData]
    let selectedStorage: PrayerStorage
}

// MARK: - Generic Storage Widget Provider
struct StoragePrayerProvider: TimelineProvider {
    let storage: PrayerStorage
    
    init(storage: PrayerStorage) {
        self.storage = storage
    }
    
    func placeholder(in context: Context) -> StoragePrayerEntry {
        StoragePrayerEntry(
            date: Date(),
            prayers: [],
            selectedStorage: storage
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (StoragePrayerEntry) -> ()) {
        let entry = StoragePrayerEntry(
            date: Date(),
            prayers: [],
            selectedStorage: storage
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<StoragePrayerEntry>) -> ()) {
        Task {
            let prayers = await loadFavoritePrayersForStorage(storage)
            let entry = StoragePrayerEntry(
                date: Date(),
                prayers: prayers,
                selectedStorage: storage
            )
            
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
            completion(timeline)
        }
    }
    
    private func loadFavoritePrayersForStorage(_ storage: PrayerStorage) async -> [PrayerWidgetData] {
        return WidgetDataManager.shared.loadFavoritePrayersForStorage(storage)
    }
}

// MARK: - Storage Widget Entry View
struct StoragePrayerWidgetEntryView: View {
    var entry: StoragePrayerEntry
    
    var body: some View {
        SharedWidgetEntryView(
            prayers: entry.prayers,
            storage: entry.selectedStorage
        )
    }
}

// MARK: - Storage-specific Widgets
struct WaitPrayerWidget: Widget {
    let kind: String = "WaitPrayerWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StoragePrayerProvider(storage: .wait)) { entry in
            StoragePrayerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Wait 보관소")
        .description("Wait 보관소의 즐겨찾기 기도들을 확인하세요.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct YesPrayerWidget: Widget {
    let kind: String = "YesPrayerWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StoragePrayerProvider(storage: .yes)) { entry in
            StoragePrayerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Yes 보관소")
        .description("Yes 보관소의 즐겨찾기 기도들을 확인하세요.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct NoPrayerWidget: Widget {
    let kind: String = "NoPrayerWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StoragePrayerProvider(storage: .no)) { entry in
            StoragePrayerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("No 보관소")
        .description("No 보관소의 즐겨찾기 기도들을 확인하세요.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Configurable Widget Entry
struct ConfigurableEntry: TimelineEntry {
    let date: Date
    let prayers: [PrayerWidgetData]
    let selectedStorage: PrayerStorage
}

// MARK: - Configurable Widget Provider
struct ConfigurablePrayerProvider: AppIntentTimelineProvider {
    typealias Entry = ConfigurableEntry
    typealias Intent = SelectPrayerStorageIntent
    
    func placeholder(in context: Context) -> ConfigurableEntry {
        ConfigurableEntry(
            date: Date(),
            prayers: [],
            selectedStorage: .wait
        )
    }
    
    func snapshot(for configuration: SelectPrayerStorageIntent, in context: Context) async -> ConfigurableEntry {
        return ConfigurableEntry(
            date: Date(),
            prayers: [],
            selectedStorage: configuration.storage.toPrayerStorage
        )
    }
    
    func timeline(for configuration: SelectPrayerStorageIntent, in context: Context) async -> Timeline<ConfigurableEntry> {
        let storage = configuration.storage.toPrayerStorage
        let prayers = await loadFavoritePrayersForStorage(storage)
        let entry = ConfigurableEntry(
            date: Date(),
            prayers: prayers,
            selectedStorage: storage
        )
        
        return Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
    }
    
    private func loadFavoritePrayersForStorage(_ storage: PrayerStorage) async -> [PrayerWidgetData] {
        return WidgetDataManager.shared.loadFavoritePrayersForStorage(storage)
    }
}

// MARK: - Configurable Widget Entry View
struct ConfigurablePrayerWidgetEntryView: View {
    var entry: ConfigurableEntry
    
    var body: some View {
        SharedWidgetEntryView(
            prayers: entry.prayers,
            storage: entry.selectedStorage
        )
    }
}

// MARK: - Configurable Widget
struct ConfigurablePrayerWidget: Widget {
    let kind: String = "ConfigurablePrayerWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectPrayerStorageIntent.self, provider: ConfigurablePrayerProvider()) { entry in
            ConfigurablePrayerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("기도 보관소")
        .description("선택한 보관소의 즐겨찾기 기도들을 확인하세요.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
} 