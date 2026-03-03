import WidgetKit
import SwiftUI
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
        StoragePrayerEntry(date: Date(), prayers: [], selectedStorage: storage)
    }

    func getSnapshot(in context: Context, completion: @escaping (StoragePrayerEntry) -> ()) {
        completion(StoragePrayerEntry(date: Date(), prayers: [], selectedStorage: storage))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StoragePrayerEntry>) -> ()) {
        Task {
            let prayers = WidgetDataManager.shared.loadFavoritePrayersForStorage(storage)
            let entry = StoragePrayerEntry(date: Date(), prayers: prayers, selectedStorage: storage)
            completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600))))
        }
    }
}

// MARK: - Storage Widget Entry View
struct StoragePrayerWidgetEntryView: View {
    var entry: StoragePrayerEntry

    var body: some View {
        SharedWidgetEntryView(prayers: entry.prayers, storage: entry.selectedStorage)
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

// MARK: - Configurable Widget Entry (즐겨찾기 전체 포함)
struct ConfigurableEntry: TimelineEntry {
    let date: Date
    let prayers: [PrayerWidgetData]
    let selectedStorage: PrayerStorage
    let isFavorites: Bool
}

// MARK: - Configurable Widget Provider
struct ConfigurablePrayerProvider: AppIntentTimelineProvider {
    typealias Entry = ConfigurableEntry
    typealias Intent = SelectPrayerStorageIntent

    func placeholder(in context: Context) -> ConfigurableEntry {
        ConfigurableEntry(date: Date(), prayers: [], selectedStorage: .wait, isFavorites: false)
    }

    func snapshot(for configuration: SelectPrayerStorageIntent, in context: Context) async -> ConfigurableEntry {
        let isFavorites = configuration.storage.isFavorites
        return ConfigurableEntry(
            date: Date(),
            prayers: [],
            selectedStorage: isFavorites ? .wait : configuration.storage.toPrayerStorage,
            isFavorites: isFavorites
        )
    }

    func timeline(for configuration: SelectPrayerStorageIntent, in context: Context) async -> Timeline<ConfigurableEntry> {
        let isFavorites = configuration.storage.isFavorites
        let prayers: [PrayerWidgetData]
        let selectedStorage: PrayerStorage

        if isFavorites {
            prayers = WidgetDataManager.shared.loadAllFavorites()
            selectedStorage = .wait  // isFavorites=true 시 미사용
        } else {
            selectedStorage = configuration.storage.toPrayerStorage
            prayers = WidgetDataManager.shared.loadFavoritePrayersForStorage(selectedStorage)
        }

        let entry = ConfigurableEntry(
            date: Date(),
            prayers: prayers,
            selectedStorage: selectedStorage,
            isFavorites: isFavorites
        )
        return Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
    }
}

// MARK: - Configurable Widget Entry View
struct ConfigurablePrayerWidgetEntryView: View {
    var entry: ConfigurableEntry

    var body: some View {
        if entry.isFavorites {
            FavoritesWidgetEntryView(prayers: entry.prayers)
        } else {
            SharedWidgetEntryView(prayers: entry.prayers, storage: entry.selectedStorage)
        }
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
        .description("선택한 보관소 또는 즐겨찾기 전체를 확인하세요.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
