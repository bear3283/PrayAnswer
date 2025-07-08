import Foundation
import SwiftUI
import SwiftData
import WidgetKit

@Observable
final class PrayerViewModel {
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // 기도 추가 - 에러를 외부로 전파
    func addPrayer(title: String, content: String, category: PrayerCategory = .personal, target: String = "") throws {
        let newPrayer = Prayer(title: title, content: content, category: category, target: target)
        modelContext.insert(newPrayer)
        
        do {
            try modelContext.save()
            PrayerLogger.shared.prayerCreated(title: title)
            
            // 위젯 데이터 업데이트
            updateWidgetData()
        } catch {
            PrayerLogger.shared.prayerOperationFailed("저장", error: error)
            throw error
        }
    }
    
    // 기도 수정
    func updatePrayer(_ prayer: Prayer, title: String, content: String, category: PrayerCategory, target: String) throws {
        prayer.updateContent(title: title, content: content, category: category, target: target)
        
        do {
            try modelContext.save()
            PrayerLogger.shared.prayerUpdated(title: prayer.title)
            
            // 위젯 데이터 업데이트
            updateWidgetData()
        } catch {
            PrayerLogger.shared.prayerOperationFailed("수정", error: error)
            throw error
        }
    }
    
    // 기도 삭제
    func deletePrayer(_ prayer: Prayer) throws {
        modelContext.delete(prayer)
        
        do {
            try modelContext.save()
            PrayerLogger.shared.prayerDeleted(title: prayer.title)
            
            // 위젯 데이터 업데이트
            updateWidgetData()
        } catch {
            PrayerLogger.shared.prayerOperationFailed("삭제", error: error)
            throw error
        }
    }
    
    // 기도 보관소 이동
    func movePrayer(_ prayer: Prayer, to storage: PrayerStorage) throws {
        prayer.moveToStorage(storage)
        
        do {
            try modelContext.save()
            PrayerLogger.shared.prayerMoved(title: prayer.title, to: storage)
            
            // 위젯 데이터 업데이트
            updateWidgetData()
        } catch {
            PrayerLogger.shared.prayerOperationFailed("이동", error: error)
            throw error
        }
    }
    
    // 보관소별 기도 목록 반환
    func prayersInStorage(_ storage: PrayerStorage) -> [Prayer] {
        let descriptor = FetchDescriptor<Prayer>(
            predicate: #Predicate { prayer in
                prayer.storage == storage
            },
            sortBy: [SortDescriptor(\Prayer.createdDate, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            PrayerLogger.shared.dataOperationFailed("보관소별 기도 목록 조회", error: error)
            return []
        }
    }
    
    // 모든 기도 목록 반환
    func allPrayers() -> [Prayer] {
        let descriptor = FetchDescriptor<Prayer>(
            sortBy: [SortDescriptor(\Prayer.createdDate, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            PrayerLogger.shared.dataOperationFailed("전체 기도 목록 조회", error: error)
            return []
        }
    }
    
    // 카테고리별 기도 목록 반환
    func prayersInCategory(_ category: PrayerCategory) -> [Prayer] {
        let descriptor = FetchDescriptor<Prayer>(
            predicate: #Predicate { prayer in
                prayer.category == category
            },
            sortBy: [SortDescriptor(\Prayer.createdDate, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            PrayerLogger.shared.dataOperationFailed("카테고리별 기도 목록 조회", error: error)
            return []
        }
    }
    
    // 즐겨찾기 토글
    func toggleFavorite(_ prayer: Prayer) throws {
        prayer.toggleFavorite()
        
        do {
            try modelContext.save()
            let action = prayer.isFavorite ? "즐겨찾기 추가" : "즐겨찾기 제거"
            PrayerLogger.shared.userAction("\(prayer.title) - \(action)")
            
            // 위젯 데이터 업데이트
            updateWidgetData()
        } catch {
            PrayerLogger.shared.prayerOperationFailed("즐겨찾기 토글", error: error)
            throw error
        }
    }
    
    // 즐겨찾기 기도 목록 반환
    func favoritePrayers() -> [Prayer] {
        let descriptor = FetchDescriptor<Prayer>(
            predicate: #Predicate { prayer in
                prayer.isFavorite == true
            },
            sortBy: [SortDescriptor(\Prayer.createdDate, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            PrayerLogger.shared.dataOperationFailed("즐겨찾기 기도 목록 조회", error: error)
            return []
        }
    }
    
    // 보관소별 즐겨찾기 기도 목록 반환
    func favoritePrayersInStorage(_ storage: PrayerStorage) -> [Prayer] {
        let descriptor = FetchDescriptor<Prayer>(
            predicate: #Predicate { prayer in
                prayer.isFavorite == true && prayer.storage == storage
            },
            sortBy: [SortDescriptor(\Prayer.createdDate, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            PrayerLogger.shared.dataOperationFailed("보관소별 즐겨찾기 기도 목록 조회", error: error)
            return []
        }
    }
    
    // MARK: - Widget Data Update
    
    // 위젯 데이터 업데이트
    private func updateWidgetData() {
        // 모든 즐겨찾기 기도들을 가져와서 보관소별로 분류
        let allFavorites = favoritePrayers()
        let favoritesByStorage = Dictionary(grouping: allFavorites) { $0.storage }
        
        // 위젯 데이터 매니저를 통해 데이터 공유
        WidgetDataManager.shared.shareFavoritePrayersByStorage(favoritesByStorage)
    }
}
