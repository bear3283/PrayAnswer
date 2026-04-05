import Foundation
import SwiftData
import UserNotifications

// MARK: - 기도 습관 모델

/// 반복 기도 시간 스케줄. 매일 또는 특정 요일에 알림을 보내고 체크인을 기록한다.
@Model
final class PrayerHabit {
    var label: String = ""      // 예: "아침 기도", "저녁 기도"
    var time: Date = Date()    // 시각만 사용 (날짜 부분은 무시)
    var weekdaysData: Data?     // WeekdaySelection JSON
    var notificationEnabled: Bool = false
    var isActive: Bool = true
    var createdDate: Date = Date()

    @Relationship(deleteRule: .cascade)
    var logs: [PrayerHabitLog]?

    init(label: String, time: Date, weekdays: WeekdaySelection = .everyday, notificationEnabled: Bool = true) {
        self.label = label
        self.time = time
        self.notificationEnabled = notificationEnabled
        self.isActive = true
        self.createdDate = Date()
        self.weekdays = weekdays
    }

    // MARK: - 요일 설정 (computed, JSON 직렬화)

    var weekdays: WeekdaySelection {
        get {
            guard let data = weekdaysData,
                  let decoded = try? JSONDecoder().decode(WeekdaySelection.self, from: data) else {
                return .everyday
            }
            return decoded
        }
        set {
            weekdaysData = try? JSONEncoder().encode(newValue)
        }
    }

    /// 알림 identifier prefix (습관별 고유)
    var notificationIdentifierPrefix: String {
        "habit_\(persistentModelID.hashValue)"
    }

    // MARK: - 체크인 헬퍼

    /// 특정 날짜의 로그
    func log(for date: Date) -> PrayerHabitLog? {
        let target = Calendar.current.startOfDay(for: date)
        return (logs ?? []).first { Calendar.current.startOfDay(for: $0.date) == target }
    }

    /// 오늘 완료 여부
    var isCompletedToday: Bool {
        log(for: Date())?.isCompleted ?? false
    }

    /// 오늘 이 습관이 활성화되어야 하는지 (요일 체크)
    var isScheduledToday: Bool {
        let weekday = Calendar.current.component(.weekday, from: Date())
        return weekdays.selectedDays.contains(weekday)
    }

    // MARK: - 연속 달성 (streak)

    /// 현재 연속 달성 일수
    var currentStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        // 오늘 미완료면 어제부터 체크
        if !isCompletedToday {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate) else { return 0 }
            checkDate = yesterday
        }

        while true {
            let dayLog = (logs ?? []).first { calendar.startOfDay(for: $0.date) == checkDate }
            guard dayLog?.isCompleted == true else { break }
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = prev
        }
        return streak
    }

    /// 전체 완료 횟수
    var totalCompletedCount: Int {
        (logs ?? []).filter { $0.isCompleted }.count
    }

    /// 이번 주 완료 횟수
    var thisWeekCount: Int {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        return (logs ?? []).filter { $0.isCompleted && $0.date >= startOfWeek }.count
    }
}

// MARK: - 기도 습관 체크인 로그

@Model
final class PrayerHabitLog {
    var date: Date = Date()
    var completedAt: Date?
    var isCompleted: Bool = false

    var habit: PrayerHabit?

    init(date: Date = Date()) {
        self.date = Calendar.current.startOfDay(for: date)
        self.isCompleted = false
    }
}

// MARK: - 습관 알림 관리 (NotificationManager 확장)

extension NotificationManager {
    /// 습관 알림 스케줄링 (인용구 포함)
    func scheduleHabitNotifications(for habit: PrayerHabit) {
        cancelHabitNotifications(for: habit)
        guard habit.notificationEnabled && habit.isActive else { return }

        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: habit.time)
        let habitIDHash = abs(habit.notificationIdentifierPrefix.hashValue)
        let quote = PrayerQuoteManager.shared.quoteForNotification(habitID: habitIDHash)

        for weekday in habit.weekdays.selectedDays {
            var components = DateComponents()
            components.weekday = weekday
            components.hour = timeComponents.hour
            components.minute = timeComponents.minute

            let identifier = "\(habit.notificationIdentifierPrefix)_wd\(weekday)"

            let content = UNMutableNotificationContent()
            content.title = habit.label.isEmpty ? L.Habit.notificationTitle : "🙏 \(habit.label)"
            content.subtitle = quote.notificationLine
            content.body = L.Habit.notificationBody
            content.sound = .default
            content.userInfo = ["habitAction": "checkin"]

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            let center = UNUserNotificationCenter.current()
            center.add(request) { error in
                #if DEBUG
                if let error { print("습관 알림 등록 오류 (\(identifier)): \(error)") }
                else { print("습관 알림 등록 성공: \(identifier)") }
                #endif
            }
        }
    }

    /// 습관 알림 전체 취소
    func cancelHabitNotifications(for habit: PrayerHabit) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let prefix = habit.notificationIdentifierPrefix
            let ids = requests.map { $0.identifier }.filter { $0.hasPrefix(prefix) }
            if !ids.isEmpty {
                center.removePendingNotificationRequests(withIdentifiers: ids)
            }
        }
    }
}
