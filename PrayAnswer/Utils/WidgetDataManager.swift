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
    
    // 보관소별 즐겨찾기 기도 데이터를 위젯과 공유 (성능 최적화: 백그라운드 처리)
    func shareFavoritePrayersByStorage(_ prayersByStorage: [PrayerStorage: [Prayer]]) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }
            
            for (storage, prayers) in prayersByStorage {
                // 최대 5개의 최신 기도만 위젯에 전달 (메모리 최적화)
                let limitedPrayers = prayers.prefix(5)
                let prayerData = limitedPrayers.map { prayer in
                    PrayerWidgetData(
                        title: String(prayer.title.prefix(50)), // 제목 길이 제한
                        content: String(prayer.content.prefix(100)), // 내용 길이 제한
                        category: prayer.category.rawValue,
                        target: prayer.target,
                        storage: prayer.storage.rawValue,
                        createdDate: prayer.createdDate
                    )
                }
                
                if let encoded = try? JSONEncoder().encode(prayerData) {
                    let key = "\(self.favoritePrayersKey)_\(storage.rawValue)"
                    self.userDefaults?.set(encoded, forKey: key)
                }
            }
            
            // 메인 큐에서 위젯 리로드 요청
            DispatchQueue.main.async {
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
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
    let id: UUID
    let title: String
    let content: String
    let category: String
    let target: String
    let storage: String
    let createdDate: Date

    init(id: UUID = UUID(), title: String, content: String, category: String, target: String, storage: String, createdDate: Date) {
        self.id = id
        self.title = title
        self.content = content
        self.category = category
        self.target = target
        self.storage = storage
        self.createdDate = createdDate
    }
    
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