import Foundation
import WidgetKit

// MARK: - Widget Data Manager
class WidgetDataManager {
    static let shared = WidgetDataManager()
    
    private let appGroupID = "group.prayAnswer.widget"
    private let favoritePrayersKey = "FavoritePrayers"
    
    private var userDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupID)
    }
    
    private init() {}
    
    // MARK: - Data Sharing Methods
    
    // 즐겨찾기 기도 데이터를 위젯과 공유
    func shareFavoritePrayers(_ prayers: [Prayer]) {
        let prayerData = prayers.map { prayer in
            PrayerWidgetData(
                title: prayer.title,
                content: prayer.content,
                category: prayer.category.rawValue,
                target: prayer.target,
                storage: prayer.storage.rawValue,
                createdDate: prayer.createdDate
            )
        }
        
        if let encoded = try? JSONEncoder().encode(prayerData) {
            userDefaults?.set(encoded, forKey: favoritePrayersKey)
            
            // 위젯 리로드 요청
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    // 보관소별 즐겨찾기 기도 데이터를 위젯과 공유
    func shareFavoritePrayersByStorage(_ prayersByStorage: [PrayerStorage: [Prayer]]) {
        for (storage, prayers) in prayersByStorage {
            let prayerData = prayers.map { prayer in
                PrayerWidgetData(
                    title: prayer.title,
                    content: prayer.content,
                    category: prayer.category.rawValue,
                    target: prayer.target,
                    storage: prayer.storage.rawValue,
                    createdDate: prayer.createdDate
                )
            }
            
            if let encoded = try? JSONEncoder().encode(prayerData) {
                let key = "\(favoritePrayersKey)_\(storage.rawValue)"
                userDefaults?.set(encoded, forKey: key)
            }
        }
        
        // 위젯 리로드 요청
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // 위젯에서 사용할 데이터 로드
    func loadFavoritePrayers() -> [PrayerWidgetData] {
        guard let data = userDefaults?.data(forKey: favoritePrayersKey),
              let prayers = try? JSONDecoder().decode([PrayerWidgetData].self, from: data) else {
            return []
        }
        return prayers
    }
    
    // 보관소별 즐겨찾기 기도 데이터 로드
    func loadFavoritePrayersForStorage(_ storage: PrayerStorage) -> [PrayerWidgetData] {
        let key = "\(favoritePrayersKey)_\(storage.rawValue)"
        
        guard let data = userDefaults?.data(forKey: key),
              let prayers = try? JSONDecoder().decode([PrayerWidgetData].self, from: data) else {
            return []
        }
        return prayers
    }
    
    // 위젯 업데이트 요청
    func requestWidgetUpdate() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}

// MARK: - Widget Data Model
struct PrayerWidgetData: Codable, Identifiable {
    let id = UUID()
    let title: String
    let content: String
    let category: String
    let target: String
    let storage: String
    let createdDate: Date
    
    // 편의 속성들
    var prayerCategory: PrayerCategory {
        return PrayerCategory(rawValue: category) ?? .personal
    }
    
    var prayerStorage: PrayerStorage {
        return PrayerStorage(rawValue: storage) ?? .wait
    }
    
    var formattedCreatedDate: String {
        return DateFormatter.compact.string(from: createdDate)
    }
    
    var hasTarget: Bool {
        return !target.isEmpty
    }
} 