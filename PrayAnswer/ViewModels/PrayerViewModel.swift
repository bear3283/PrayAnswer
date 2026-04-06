import Foundation
import SwiftData
import WidgetKit

/// 기도 관련 에러 타입
enum PrayerError: Error {
    case invalidState
}

@Observable
@MainActor
final class PrayerViewModel {
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    deinit {
        PrayerLogger.shared.viewModelDeallocated("PrayerViewModel")
    }

    // 기도 추가 - 에러를 외부로 전파, Prayer 객체 반환
    @discardableResult
    func addPrayer(title: String, content: String, category: PrayerCategory = .personal, target: String = "", targetDate: Date? = nil, notificationEnabled: Bool = false, notificationSettings: NotificationSettings? = nil, imageFileName: String? = nil) throws -> Prayer {
        let newPrayer = Prayer(title: title, content: content, category: category, target: target, targetDate: targetDate, notificationEnabled: notificationEnabled, notificationSettings: notificationSettings, imageFileName: imageFileName)
        modelContext.insert(newPrayer)

        do {
            try modelContext.save()
            PrayerLogger.shared.prayerCreated(title: title)

            // 위젯 데이터 업데이트
            updateWidgetData()

            return newPrayer
        } catch {
            PrayerLogger.shared.prayerOperationFailed("저장", error: error)
            throw error
        }
    }

    // 기도 수정
    func updatePrayer(_ prayer: Prayer, title: String, content: String, category: PrayerCategory, target: String, targetDate: Date? = nil, notificationEnabled: Bool = false, notificationSettings: NotificationSettings? = nil, imageFileName: String? = nil) throws {
        prayer.updateContent(title: title, content: content, category: category, target: target, targetDate: targetDate, notificationEnabled: notificationEnabled, notificationSettings: notificationSettings, imageFileName: imageFileName)

        // D-Day 알림 업데이트
        if notificationEnabled, let date = targetDate {
            NotificationManager.shared.scheduleNotifications(for: prayer, targetDate: date)
        } else {
            NotificationManager.shared.cancelAllNotifications(for: prayer)
        }

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
        // D-Day 알림 취소 (기본 + 커스텀 + 반복 알림 모두)
        NotificationManager.shared.cancelAllNotifications(for: prayer)

        #if !WIDGET_EXTENSION
        // 첨부 파일 삭제 (이미지, PDF)
        let fileNames = (prayer.attachments ?? []).map { $0.fileName }
        AttachmentStorageManager.shared.deleteFiles(fileNames: fileNames)

        // 레거시 이미지 파일 삭제
        if let legacyFileName = prayer.imageFileName {
            ImageStorageManager.shared.deleteImage(fileName: legacyFileName)
        }
        #endif

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
    
    // MARK: - Target-related Methods
    
    // 특정 기도대상자의 기도 목록 반환
    func prayersByTarget(_ target: String) -> [Prayer] {
        let descriptor = FetchDescriptor<Prayer>(
            predicate: #Predicate { prayer in
                prayer.target == target
            },
            sortBy: [SortDescriptor(\Prayer.createdDate, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            PrayerLogger.shared.dataOperationFailed("대상자별 기도 목록 조회", error: error)
            return []
        }
    }
    
    // 모든 기도대상자 목록 반환 (중복 제거)
    func allTargets() -> [String] {
        let descriptor = FetchDescriptor<Prayer>(
            predicate: #Predicate { prayer in
                !prayer.target.isEmpty
            }
        )
        
        do {
            let prayers = try modelContext.fetch(descriptor)
            let targets = prayers.map { $0.target }
            return Array(Set(targets)).sorted() // 중복 제거 후 정렬
        } catch {
            PrayerLogger.shared.dataOperationFailed("기도대상자 목록 조회", error: error)
            return []
        }
    }
    
    // 기도대상자별 기도 개수 반환
    func prayerCountByTarget(_ target: String) -> Int {
        let descriptor = FetchDescriptor<Prayer>(
            predicate: #Predicate { prayer in
                prayer.target == target
            }
        )
        
        do {
            let prayers = try modelContext.fetch(descriptor)
            return prayers.count
        } catch {
            PrayerLogger.shared.dataOperationFailed("대상자별 기도 개수 조회", error: error)
            return 0
        }
    }
    
    // 기도대상자별 기도 상태별 개수 반환
    func prayerCountByTargetAndStorage(_ target: String, storage: PrayerStorage) -> Int {
        let descriptor = FetchDescriptor<Prayer>(
            predicate: #Predicate { prayer in
                prayer.target == target && prayer.storage == storage
            }
        )
        
        do {
            let prayers = try modelContext.fetch(descriptor)
            return prayers.count
        } catch {
            PrayerLogger.shared.dataOperationFailed("대상자별 상태별 기도 개수 조회", error: error)
            return 0
        }
    }
    
    // 기도대상자별 최근 기도 날짜 반환
    func latestPrayerDateByTarget(_ target: String) -> Date? {
        var descriptor = FetchDescriptor<Prayer>(
            predicate: #Predicate { prayer in
                prayer.target == target
            },
            sortBy: [SortDescriptor(\Prayer.createdDate, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        
        do {
            let prayers = try modelContext.fetch(descriptor)
            return prayers.first?.createdDate
        } catch {
            PrayerLogger.shared.dataOperationFailed("대상자별 최근 기도 날짜 조회", error: error)
            return nil
        }
    }
    
    // MARK: - Widget Data Update
    
    // 위젯 데이터 업데이트 (ModelContext는 메인 스레드에서만 접근)
    private func updateWidgetData() {
        // fetch 직후 즉시 값 타입 변환 (Prayer @Model 참조를 외부로 전달 금지)
        let allFavorites = favoritePrayers()
        var dataByStorage: [PrayerStorage: [PrayerWidgetData]] = [:]
        for prayer in allFavorites {
            let storage = prayer.storage
            dataByStorage[storage, default: []].append(prayer.toWidgetData())
        }
        WidgetDataManager.shared.shareFavoritePrayersByStorage(dataByStorage)
    }
}
