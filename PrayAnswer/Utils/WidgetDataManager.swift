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
    
    // 보관소별 즐겨찾기 기도 데이터를 위젯과 공유 (값 타입만 수신 - @Model 참조 전달 금지)
    func shareFavoritePrayersByStorage(_ dataByStorage: [PrayerStorage: [PrayerWidgetData]]) {
        let pairs: [(String, [PrayerWidgetData])] = dataByStorage.map { (storage, data) in
            ("\(favoritePrayersKey)_\(storage.rawValue)", Array(data.prefix(5)))
        }

        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }
            for (key, data) in pairs {
                if let encoded = try? JSONEncoder().encode(data) {
                    self.userDefaults?.set(encoded, forKey: key)
                }
            }
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
    
    // 전체 보관소 즐겨찾기 기도 로드 (최신순 정렬)
    func loadAllFavorites() -> [PrayerWidgetData] {
        var all: [PrayerWidgetData] = []
        for storage in PrayerStorage.allCases {
            let key = "\(favoritePrayersKey)_\(storage.rawValue)"
            if let data = userDefaults?.data(forKey: key),
               let prayers = try? JSONDecoder().decode([PrayerWidgetData].self, from: data) {
                all.append(contentsOf: prayers)
            }
        }
        return all.sorted { $0.createdDate > $1.createdDate }
    }

    // 위젯 업데이트 요청
    func requestWidgetUpdate() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}

// MARK: - Prayer → Widget Data 변환 헬퍼
// @Model 속성 접근은 항상 ModelContext가 유효한 시점(메인 스레드, fetch 직후)에 수행해야 함
extension Prayer {
    func toWidgetData() -> PrayerWidgetData {
        PrayerWidgetData(
            title: String(title.prefix(50)),
            content: String(content.prefix(100)),
            category: category.rawValue,
            target: target,
            storage: storage.rawValue,
            createdDate: createdDate
        )
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