import Foundation
import SwiftData

// Import localization extensions
// LocalizationKeys.swift에 정의된 PrayerStorage, PrayerCategory extensions 사용

// 기도 보관소 타입
enum PrayerStorage: String, CaseIterable, Codable {
    case wait = "wait"
    case yes = "yes"
    case no = "no"
    
    var displayName: String {
        return localizedDisplayName
    }
    
    var iconName: String {
        switch self {
        case .wait:
            return "clock"
        case .yes:
            return "checkmark.circle"
        case .no:
            return "xmark.circle"
        }
    }
}

// 기도 카테고리 타입
enum PrayerCategory: String, CaseIterable, Codable {
    case personal = "personal"
    case family = "family"
    case health = "health"
    case work = "work"
    case relationship = "relationship"
    case thanksgiving = "thanksgiving"
    case vision = "vision"
    case other = "other"
    
    var displayName: String {
        return localizedDisplayName
    }
}

// 기도 모델
@Model
final class Prayer {
    var title: String
    var content: String
    var createdDate: Date
    var modifiedDate: Date?
    var movedDate: Date?
    var storage: PrayerStorage
    var category: PrayerCategory
    var target: String // 기도 대상자
    var isFavorite: Bool // 즐겨찾기 여부
    
    init(title: String, content: String, category: PrayerCategory = .personal, target: String = "", storage: PrayerStorage = .wait, isFavorite: Bool = false) {
        self.title = title
        self.content = content
        self.category = category
        self.target = target
        self.createdDate = Date()
        self.storage = storage
        self.isFavorite = isFavorite
    }
    
    func updateContent(title: String, content: String, category: PrayerCategory, target: String) {
        self.title = title
        self.content = content
        self.category = category
        self.target = target
        self.modifiedDate = Date()
    }
    
    func moveToStorage(_ newStorage: PrayerStorage) {
        self.storage = newStorage
        self.movedDate = Date()
    }
    
    func toggleFavorite() {
        self.isFavorite.toggle()
        self.modifiedDate = Date()
    }
}

// MARK: - Prayer Extensions

extension Prayer {
    
    // MARK: - Accessibility
    
    var accessibilityLabel: String {
        let favoriteText = isFavorite ? ", \(L.Accessibility.favorite)" : ""
        return L.Accessibility.prayerFormat(title, category.displayName, storage.displayName, favoriteText)
    }

    var accessibilityHint: String {
        return "\(storage.localizedDescription) \(L.Accessibility.tapDetail)"
    }
    
    // MARK: - Display Helpers
    
    var formattedCreatedDate: String {
        return DateFormatter.compact.string(from: createdDate)
    }
    
    var formattedDetailedDate: String {
        return DateFormatter.detailed.string(from: createdDate)
    }
    
    var hasTarget: Bool {
        return !target.isEmpty
    }
    
    var isRecentlyCreated: Bool {
        return Calendar.current.isDateInToday(createdDate)
    }
    
    var isRecentlyModified: Bool {
        guard let modifiedDate = modifiedDate else { return false }
        return Calendar.current.isDateInToday(modifiedDate)
    }
    
    var daysSinceCreated: Int {
        return Calendar.current.dateComponents([.day], from: createdDate, to: Date()).day ?? 0
    }
    
    // MARK: - Validation
    
    var isValid: Bool {
        return !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var validationErrors: [String] {
        var errors: [String] = []

        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append(L.Validation.titleRequired)
        }

        if content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append(L.Validation.contentRequired)
        }

        if title.count > 100 {
            errors.append(L.Error.titleTooLong)
        }

        if content.count > 2000 {
            errors.append(L.Error.contentTooLong)
        }

        return errors
    }
}

// MARK: - Prayer Statistics

extension Array where Element == Prayer {
    
    var byStorage: [PrayerStorage: [Prayer]] {
        return Dictionary(grouping: self) { $0.storage }
    }
    
    var byCategory: [PrayerCategory: [Prayer]] {
        return Dictionary(grouping: self) { $0.category }
    }
    
    // 기도대상자별 그룹화
    var byTarget: [String: [Prayer]] {
        return Dictionary(grouping: self) { $0.target }
            .filter { !$0.key.isEmpty } // 빈 대상자 제외
    }
    
    // 기도대상자별 기도 개수
    var targetCounts: [String: Int] {
        return byTarget.mapValues { $0.count }
    }
    
    // 기도대상자별 최근 기도 날짜
    var targetLatestDates: [String: Date] {
        return byTarget.mapValues { prayers in
            prayers.max { $0.createdDate < $1.createdDate }?.createdDate ?? Date()
        }
    }
    
    var totalAnsweredPrayers: Int {
        return filter { $0.storage == .yes }.count
    }
    
    var totalWaitingPrayers: Int {
        return filter { $0.storage == .wait }.count
    }
    
    var recentPrayers: [Prayer] {
        let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return filter { $0.createdDate >= lastWeek }
    }
    
    var mostUsedCategory: PrayerCategory? {
        let categoryGroups = byCategory
        return categoryGroups.max { $0.value.count < $1.value.count }?.key
    }
    
    var favoritePrayers: [Prayer] {
        return filter { $0.isFavorite }
    }
    
    var favoritesByStorage: [PrayerStorage: [Prayer]] {
        return Dictionary(grouping: favoritePrayers) { $0.storage }
    }
    
    var totalFavoritePrayers: Int {
        return favoritePrayers.count
    }
} 
