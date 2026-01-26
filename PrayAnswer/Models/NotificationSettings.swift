import Foundation

/// 알림 반복 유형
enum NotificationRepeatType: String, Codable, CaseIterable {
    case none = "none"
    case daily = "daily"
    case weekdays = "weekdays"
    case weekly = "weekly"
    case custom = "custom"

    var displayName: String {
        switch self {
        case .none: return L.Notification.repeatNone
        case .daily: return L.Notification.repeatDaily
        case .weekdays: return L.Notification.repeatWeekdays
        case .weekly: return L.Notification.repeatWeekly
        case .custom: return L.Notification.repeatCustom
        }
    }

    var description: String {
        switch self {
        case .none: return L.Notification.repeatNoneDesc
        case .daily: return L.Notification.repeatDailyDesc
        case .weekdays: return L.Notification.repeatWeekdaysDesc
        case .weekly: return L.Notification.repeatWeeklyDesc
        case .custom: return L.Notification.repeatCustomDesc
        }
    }
}

/// 요일 선택 (반복 알림용)
struct WeekdaySelection: Codable, Equatable {
    var sunday: Bool = false
    var monday: Bool = false
    var tuesday: Bool = false
    var wednesday: Bool = false
    var thursday: Bool = false
    var friday: Bool = false
    var saturday: Bool = false

    var selectedDays: [Int] {
        var days: [Int] = []
        if sunday { days.append(1) }
        if monday { days.append(2) }
        if tuesday { days.append(3) }
        if wednesday { days.append(4) }
        if thursday { days.append(5) }
        if friday { days.append(6) }
        if saturday { days.append(7) }
        return days
    }

    var displayText: String {
        let dayNames = [
            (sunday, L.Weekday.sunday),
            (monday, L.Weekday.monday),
            (tuesday, L.Weekday.tuesday),
            (wednesday, L.Weekday.wednesday),
            (thursday, L.Weekday.thursday),
            (friday, L.Weekday.friday),
            (saturday, L.Weekday.saturday)
        ]
        let selected = dayNames.filter { $0.0 }.map { $0.1 }
        return selected.isEmpty ? L.Notification.noSelectedDays : selected.joined(separator: ", ")
    }

    static var weekdays: WeekdaySelection {
        return WeekdaySelection(
            sunday: false,
            monday: true,
            tuesday: true,
            wednesday: true,
            thursday: true,
            friday: true,
            saturday: false
        )
    }

    static var everyday: WeekdaySelection {
        return WeekdaySelection(
            sunday: true,
            monday: true,
            tuesday: true,
            wednesday: true,
            thursday: true,
            friday: true,
            saturday: true
        )
    }
}

/// 기도 알림 설정
struct NotificationSettings: Codable, Equatable {
    /// 알림 활성화 여부
    var isEnabled: Bool = false

    /// 알림 시간 (시, 분)
    var notificationHour: Int = 9
    var notificationMinute: Int = 0

    /// D-Day 알림 일정 (D-n일 목록)
    /// 예: [7, 3, 1, 0] = D-7, D-3, D-1, D-Day에 알림
    var reminderDays: [Int] = [7, 3, 1, 0]

    /// 반복 유형
    var repeatType: NotificationRepeatType = .none

    /// 사용자 지정 요일 선택 (repeatType == .custom일 때 사용)
    var customWeekdays: WeekdaySelection = WeekdaySelection()

    /// 반복 알림 종료 날짜 (nil이면 무기한)
    var repeatEndDate: Date? = nil

    /// 반복 알림 최대 횟수 (nil이면 무제한)
    var maxRepeatCount: Int? = nil

    // MARK: - Computed Properties

    /// 알림 시간 Date 객체 (오늘 날짜 기준)
    var notificationTime: Date {
        get {
            var components = DateComponents()
            components.hour = notificationHour
            components.minute = notificationMinute
            return Calendar.current.date(from: components) ?? Date()
        }
        set {
            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            notificationHour = components.hour ?? 9
            notificationMinute = components.minute ?? 0
        }
    }

    /// 알림 시간 표시 텍스트
    var timeDisplayText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "a h:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: notificationTime)
    }

    /// D-Day 알림 일정 표시 텍스트
    var reminderDaysDisplayText: String {
        if reminderDays.isEmpty {
            return L.Notification.noDaysSelected
        }

        let sortedDays = reminderDays.sorted(by: >)
        let dayTexts = sortedDays.map { day -> String in
            if day == 0 {
                return "D-Day"
            } else {
                return "D-\(day)"
            }
        }
        return dayTexts.joined(separator: ", ")
    }

    /// 반복 설정 표시 텍스트
    var repeatDisplayText: String {
        switch repeatType {
        case .none:
            return repeatType.displayName
        case .daily:
            return repeatType.displayName
        case .weekdays:
            return repeatType.displayName
        case .weekly:
            return repeatType.displayName
        case .custom:
            return customWeekdays.displayText
        }
    }

    // MARK: - Presets

    /// 기본 설정 (D-7, D-3, D-1, D-Day, 오전 9시)
    static var `default`: NotificationSettings {
        return NotificationSettings()
    }

    /// 간단 설정 (D-1, D-Day만)
    static var simple: NotificationSettings {
        var settings = NotificationSettings()
        settings.reminderDays = [1, 0]
        return settings
    }

    /// 집중 설정 (매일 반복)
    static var intensive: NotificationSettings {
        var settings = NotificationSettings()
        settings.reminderDays = [7, 3, 1, 0]
        settings.repeatType = .daily
        return settings
    }
}

// MARK: - Reminder Day Presets

extension NotificationSettings {
    /// 사용 가능한 알림 일정 옵션
    static var availableReminderDays: [Int] {
        return [30, 14, 7, 5, 3, 2, 1, 0]
    }

    /// 알림 일정 토글
    mutating func toggleReminderDay(_ day: Int) {
        if reminderDays.contains(day) {
            reminderDays.removeAll { $0 == day }
        } else {
            reminderDays.append(day)
            reminderDays.sort(by: >)
        }
    }

    /// 특정 일이 선택되어 있는지 확인
    func isReminderDaySelected(_ day: Int) -> Bool {
        return reminderDays.contains(day)
    }
}
