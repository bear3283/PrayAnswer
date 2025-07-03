import Foundation
import SwiftUI
import SwiftData

@Observable
final class PrayerViewModel {
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // 기도 추가
    func addPrayer(title: String, content: String, category: PrayerCategory = .personal, target: String = "") {
        let newPrayer = Prayer(title: title, content: content, category: category, target: target)
        modelContext.insert(newPrayer)
        
        do {
            try modelContext.save()
            PrayerLogger.shared.prayerCreated(title: title)
        } catch {
            PrayerLogger.shared.prayerOperationFailed("저장", error: error)
        }
    }
    
    // 기도 수정
    func updatePrayer(_ prayer: Prayer, title: String, content: String, category: PrayerCategory, target: String) {
        prayer.updateContent(title: title, content: content, category: category, target: target)
        
        do {
            try modelContext.save()
            PrayerLogger.shared.prayerUpdated(title: prayer.title)
        } catch {
            PrayerLogger.shared.prayerOperationFailed("수정", error: error)
        }
    }
    
    // 기도 삭제
    func deletePrayer(_ prayer: Prayer) {
        modelContext.delete(prayer)
        
        do {
            try modelContext.save()
            PrayerLogger.shared.prayerDeleted(title: prayer.title)
        } catch {
            PrayerLogger.shared.prayerOperationFailed("삭제", error: error)
        }
    }
    
    // 기도 보관소 이동
    func movePrayer(_ prayer: Prayer, to storage: PrayerStorage) {
        prayer.moveToStorage(storage)
        
        do {
            try modelContext.save()
            PrayerLogger.shared.prayerMoved(title: prayer.title, to: storage)
        } catch {
            PrayerLogger.shared.prayerOperationFailed("이동", error: error)
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
} 