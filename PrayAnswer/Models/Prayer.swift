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
    var targetDate: Date? // D-Day 목표 날짜
    var notificationEnabled: Bool = false // 알림 활성화 여부 (기본값으로 마이그레이션 지원)
    var notificationSettingsData: Data? // 알림 세부설정 JSON 저장
    var calendarEventId: String? // 캘린더 이벤트 식별자

    // 기본 이니셜라이저 (위젯에서도 사용 가능)
    init(title: String, content: String, category: PrayerCategory = .personal, target: String = "", storage: PrayerStorage = .wait, isFavorite: Bool = false, targetDate: Date? = nil, notificationEnabled: Bool = false, notificationSettingsData: Data? = nil) {
        self.title = title
        self.content = content
        self.category = category
        self.target = target
        self.createdDate = Date()
        self.storage = storage
        self.isFavorite = isFavorite
        self.targetDate = targetDate
        self.notificationEnabled = notificationEnabled
        self.notificationSettingsData = notificationSettingsData
    }

    // 기본 업데이트 메서드 (위젯에서도 사용 가능)
    func updateContent(title: String, content: String, category: PrayerCategory, target: String, targetDate: Date? = nil, notificationEnabled: Bool = false, notificationSettingsData: Data? = nil) {
        self.title = title
        self.content = content
        self.category = category
        self.target = target
        self.targetDate = targetDate
        self.notificationEnabled = notificationEnabled
        if let data = notificationSettingsData {
            self.notificationSettingsData = data
        }
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

    func updateTargetDate(_ date: Date?) {
        self.targetDate = date
        self.modifiedDate = Date()
    }

    func toggleNotification() {
        self.notificationEnabled.toggle()
        self.modifiedDate = Date()
    }
}

// MARK: - Prayer Extensions

extension Prayer {

    #if !WIDGET_EXTENSION
    // MARK: - Convenience Initializer with NotificationSettings

    /// NotificationSettings를 사용하는 편의 이니셜라이저
    convenience init(title: String, content: String, category: PrayerCategory = .personal, target: String = "", storage: PrayerStorage = .wait, isFavorite: Bool = false, targetDate: Date? = nil, notificationEnabled: Bool = false, notificationSettings: NotificationSettings?) {
        let settingsData = notificationSettings.flatMap { try? JSONEncoder().encode($0) }
        self.init(title: title, content: content, category: category, target: target, storage: storage, isFavorite: isFavorite, targetDate: targetDate, notificationEnabled: notificationEnabled, notificationSettingsData: settingsData)
    }

    // MARK: - Notification Settings

    /// 알림 세부설정 (JSON에서 디코딩)
    var notificationSettings: NotificationSettings {
        get {
            guard let data = notificationSettingsData else { return NotificationSettings() }
            return (try? JSONDecoder().decode(NotificationSettings.self, from: data)) ?? NotificationSettings()
        }
        set {
            notificationSettingsData = try? JSONEncoder().encode(newValue)
        }
    }

    /// 알림 세부설정 업데이트
    func updateNotificationSettings(_ settings: NotificationSettings) {
        notificationSettingsData = try? JSONEncoder().encode(settings)
        notificationEnabled = settings.isEnabled
        modifiedDate = Date()
    }

    /// NotificationSettings를 사용하는 편의 업데이트 메서드
    func updateContent(title: String, content: String, category: PrayerCategory, target: String, targetDate: Date? = nil, notificationEnabled: Bool = false, notificationSettings: NotificationSettings?) {
        self.title = title
        self.content = content
        self.category = category
        self.target = target
        self.targetDate = targetDate
        self.notificationEnabled = notificationEnabled
        if let settings = notificationSettings {
            self.notificationSettingsData = try? JSONEncoder().encode(settings)
        }
        self.modifiedDate = Date()
    }
    #endif

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

    // MARK: - D-Day Helpers

    /// D-Day까지 남은 일수 (음수면 지난 날짜)
    var daysUntilTarget: Int? {
        guard let targetDate = targetDate else { return nil }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: targetDate)
        return calendar.dateComponents([.day], from: today, to: target).day
    }

    /// D-Day 표시 텍스트 ("D-7", "D-Day", "D+3")
    var dDayDisplayText: String? {
        guard let days = daysUntilTarget else { return nil }
        if days == 0 {
            return "D-Day"
        } else if days > 0 {
            return "D-\(days)"
        } else {
            return "D+\(abs(days))"
        }
    }

    /// D-Day가 설정되어 있는지 여부
    var hasTargetDate: Bool {
        return targetDate != nil
    }

    /// D-Day가 임박한지 여부 (7일 이내)
    var isDDayApproaching: Bool {
        guard let days = daysUntilTarget else { return false }
        return days >= 0 && days <= 7
    }

    /// D-Day가 오늘인지 여부
    var isDDay: Bool {
        guard let days = daysUntilTarget else { return false }
        return days == 0
    }

    /// D-Day가 지났는지 여부
    var isDDayPassed: Bool {
        guard let days = daysUntilTarget else { return false }
        return days < 0
    }

    /// 캘린더에 추가되어 있는지 여부
    var isAddedToCalendar: Bool {
        #if !WIDGET_EXTENSION
        guard let eventId = calendarEventId else { return false }
        return CalendarManager.shared.eventExists(withIdentifier: eventId)
        #else
        return calendarEventId != nil
        #endif
    }

    /// 캘린더 이벤트 ID 업데이트
    func updateCalendarEventId(_ eventId: String?) {
        self.calendarEventId = eventId
        self.modifiedDate = Date()
    }

    /// 포맷된 목표 날짜 문자열
    var formattedTargetDate: String? {
        guard let targetDate = targetDate else { return nil }
        return DateFormatter.compact.string(from: targetDate)
    }

    // MARK: - Validation
    
    var isValid: Bool {
        return !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Title Generation

    /// 기도대상자와 카테고리로부터 제목 자동 생성
    static func generateTitle(from target: String, category: PrayerCategory) -> String {
        let targetName = target.isEmpty ? L.Target.myself : target
        return L.Target.titleFormat(targetName, category.displayName)
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

    // MARK: - D-Day Statistics

    /// D-Day가 설정된 기도들
    var prayersWithDDay: [Prayer] {
        return filter { $0.hasTargetDate }
    }

    /// D-Day 임박순 정렬 (가까운 날짜가 먼저)
    var sortedByDDay: [Prayer] {
        return sorted { prayer1, prayer2 in
            guard let days1 = prayer1.daysUntilTarget else { return false }
            guard let days2 = prayer2.daysUntilTarget else { return true }
            return days1 < days2
        }
    }

    /// D-Day가 임박한 기도들 (7일 이내)
    var approachingDDayPrayers: [Prayer] {
        return filter { $0.isDDayApproaching }
    }

    /// 오늘이 D-Day인 기도들
    var todayDDayPrayers: [Prayer] {
        return filter { $0.isDDay }
    }

    /// D-Day가 지난 기도들
    var passedDDayPrayers: [Prayer] {
        return filter { $0.isDDayPassed }
    }

    /// 알림이 활성화된 기도들
    var notificationEnabledPrayers: [Prayer] {
        return filter { $0.notificationEnabled }
    }
} 
