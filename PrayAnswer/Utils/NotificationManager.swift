import Foundation
import UserNotifications

/// D-Day 알림 관리자
final class NotificationManager {
    static let shared = NotificationManager()

    private let notificationCenter = UNUserNotificationCenter.current()

    /// 최대 스케줄링 가능한 알림 수 (iOS 제한: 64개)
    private let maxPendingNotifications = 60

    private init() {}

    // MARK: - Permission

    /// 알림 권한 요청
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("알림 권한 요청 오류: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    /// 현재 알림 권한 상태 확인
    func checkAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }

    // MARK: - Schedule Notifications

    /// 기도에 대한 D-Day 알림 스케줄링 (기본 설정 사용)
    /// - Parameters:
    ///   - prayer: 알림을 설정할 기도
    ///   - targetDate: D-Day 목표 날짜
    func scheduleNotifications(for prayer: Prayer, targetDate: Date) {
        // 세부설정이 있으면 커스텀 스케줄링 사용
        let settings = prayer.notificationSettings
        if settings.isEnabled {
            scheduleCustomNotifications(for: prayer, targetDate: targetDate, settings: settings)
        } else {
            // 기본 설정으로 스케줄링
            scheduleDefaultNotifications(for: prayer, targetDate: targetDate)
        }
    }

    /// 기본 알림 스케줄링 (D-7, D-3, D-1, D-Day, 오전 9시)
    private func scheduleDefaultNotifications(for prayer: Prayer, targetDate: Date) {
        // 기존 알림 취소
        cancelNotifications(for: prayer)

        // 알림 시간 계산 (오전 9시)
        let notificationHour = 9

        // D-7, D-3, D-1, D-Day 알림 스케줄링
        let notificationDays = [7, 3, 1, 0]

        for daysBefore in notificationDays {
            guard let notificationDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: targetDate) else {
                continue
            }

            // 과거 날짜는 스케줄링하지 않음
            let today = Calendar.current.startOfDay(for: Date())
            let scheduleDate = Calendar.current.startOfDay(for: notificationDate)

            if scheduleDate < today {
                continue
            }

            let identifier = notificationIdentifier(for: prayer, daysBefore: daysBefore)
            let content = createNotificationContent(for: prayer, daysBefore: daysBefore)
            let trigger = createTrigger(for: notificationDate, hour: notificationHour)

            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            notificationCenter.add(request) { error in
                if let error = error {
                    print("알림 스케줄링 오류 (\(identifier)): \(error.localizedDescription)")
                } else {
                    print("알림 스케줄링 성공: \(identifier)")
                }
            }
        }
    }

    /// 커스텀 알림 스케줄링 (세부설정 적용)
    /// - Parameters:
    ///   - prayer: 알림을 설정할 기도
    ///   - targetDate: D-Day 목표 날짜
    ///   - settings: 알림 세부설정
    func scheduleCustomNotifications(for prayer: Prayer, targetDate: Date, settings: NotificationSettings) {
        // 기존 알림 취소
        cancelAllNotifications(for: prayer)

        guard settings.isEnabled else { return }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // 1. D-Day 기반 알림 스케줄링
        for daysBefore in settings.reminderDays {
            guard let notificationDate = calendar.date(byAdding: .day, value: -daysBefore, to: targetDate) else {
                continue
            }

            let scheduleDate = calendar.startOfDay(for: notificationDate)

            // 과거 날짜는 스케줄링하지 않음
            if scheduleDate < today {
                continue
            }

            let identifier = customNotificationIdentifier(for: prayer, daysBefore: daysBefore, type: "dday")
            let content = createNotificationContent(for: prayer, daysBefore: daysBefore)
            let trigger = createTrigger(
                for: notificationDate,
                hour: settings.notificationHour,
                minute: settings.notificationMinute
            )

            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            notificationCenter.add(request) { error in
                if let error = error {
                    print("커스텀 알림 스케줄링 오류 (\(identifier)): \(error.localizedDescription)")
                } else {
                    print("커스텀 알림 스케줄링 성공: \(identifier)")
                }
            }
        }

        // 2. 반복 알림 스케줄링 (D-Day까지)
        if settings.repeatType != .none {
            scheduleRepeatingNotifications(for: prayer, targetDate: targetDate, settings: settings)
        }
    }

    /// 반복 알림 스케줄링
    private func scheduleRepeatingNotifications(for prayer: Prayer, targetDate: Date, settings: NotificationSettings) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let targetDay = calendar.startOfDay(for: targetDate)

        // 반복 종료 날짜 (D-Day 또는 설정된 종료일 중 빠른 날짜)
        var endDate = targetDay
        if let repeatEndDate = settings.repeatEndDate {
            endDate = min(targetDay, repeatEndDate)
        }

        // 반복할 요일 결정
        let weekdaysToNotify: [Int]
        switch settings.repeatType {
        case .none:
            return
        case .daily:
            weekdaysToNotify = [1, 2, 3, 4, 5, 6, 7] // 모든 요일
        case .weekdays:
            weekdaysToNotify = [2, 3, 4, 5, 6] // 월~금
        case .weekly:
            // 현재 요일에만 알림 (주 1회)
            let currentWeekday = calendar.component(.weekday, from: today)
            weekdaysToNotify = [currentWeekday]
        case .custom:
            weekdaysToNotify = settings.customWeekdays.selectedDays
        }

        guard !weekdaysToNotify.isEmpty else { return }

        // 최대 알림 수 제한을 위한 카운터
        var scheduledCount = 0
        let maxRepeats = min(settings.maxRepeatCount ?? 30, 30) // 최대 30개

        // 시작일부터 종료일까지 반복
        var currentDate = today
        while currentDate <= endDate && scheduledCount < maxRepeats {
            let weekday = calendar.component(.weekday, from: currentDate)

            if weekdaysToNotify.contains(weekday) {
                // D-Day 알림과 중복되지 않도록 체크
                let daysUntilTarget = calendar.dateComponents([.day], from: currentDate, to: targetDay).day ?? 0
                if !settings.reminderDays.contains(daysUntilTarget) {
                    let identifier = customNotificationIdentifier(
                        for: prayer,
                        daysBefore: daysUntilTarget,
                        type: "repeat_\(scheduledCount)"
                    )

                    let content = createRepeatingNotificationContent(for: prayer, daysRemaining: daysUntilTarget)
                    let trigger = createTrigger(
                        for: currentDate,
                        hour: settings.notificationHour,
                        minute: settings.notificationMinute
                    )

                    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

                    notificationCenter.add(request) { error in
                        if let error = error {
                            print("반복 알림 스케줄링 오류: \(error.localizedDescription)")
                        }
                    }

                    scheduledCount += 1
                }
            }

            // 다음 날로 이동
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }

        print("반복 알림 \(scheduledCount)개 스케줄링 완료")
    }

    /// 반복 알림 내용 생성
    private func createRepeatingNotificationContent(for prayer: Prayer, daysRemaining: Int) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        let targetName = prayer.target.isEmpty ? L.Target.myself : prayer.target

        content.title = L.DDay.notificationTitle

        if daysRemaining == 0 {
            content.body = L.DDay.notificationDDay(targetName)
        } else if daysRemaining > 0 {
            content.body = L.DDay.notificationGeneric(targetName, daysRemaining)
        } else {
            content.body = "\(targetName)님을 위한 기도를 기억해주세요"
        }

        content.sound = .default

        return content
    }

    /// 기도에 대한 기본 알림 취소
    func cancelNotifications(for prayer: Prayer) {
        let identifiers = [7, 3, 1, 0].map { notificationIdentifier(for: prayer, daysBefore: $0) }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        print("기본 알림 취소: \(identifiers)")
    }

    /// 기도에 대한 모든 알림 취소 (기본 + 커스텀 + 반복)
    func cancelAllNotifications(for prayer: Prayer) {
        // 먼저 기존 알림 취소
        cancelNotifications(for: prayer)

        // 커스텀 알림 및 반복 알림도 취소
        notificationCenter.getPendingNotificationRequests { [weak self] requests in
            let prayerIdHash = prayer.persistentModelID.hashValue
            let identifiersToRemove = requests
                .map { $0.identifier }
                .filter { $0.contains("prayer_\(prayerIdHash)") }

            if !identifiersToRemove.isEmpty {
                self?.notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
                print("커스텀/반복 알림 취소: \(identifiersToRemove.count)개")
            }
        }
    }

    /// 모든 기도 알림 취소
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        print("모든 알림 취소됨")
    }

    // MARK: - Private Helpers

    private func notificationIdentifier(for prayer: Prayer, daysBefore: Int) -> String {
        return "prayer_dday_\(prayer.persistentModelID.hashValue)_d\(daysBefore)"
    }

    private func customNotificationIdentifier(for prayer: Prayer, daysBefore: Int, type: String) -> String {
        return "prayer_\(prayer.persistentModelID.hashValue)_\(type)_d\(daysBefore)"
    }

    private func createNotificationContent(for prayer: Prayer, daysBefore: Int) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()

        let targetName = prayer.target.isEmpty ? L.Target.myself : prayer.target

        switch daysBefore {
        case 7:
            content.title = L.DDay.notificationTitle
            content.body = L.DDay.notificationWeekBefore(targetName)
        case 3:
            content.title = L.DDay.notificationTitle
            content.body = L.DDay.notification3DaysBefore(targetName)
        case 1:
            content.title = L.DDay.notificationTitle
            content.body = L.DDay.notification1DayBefore(targetName)
        case 0:
            content.title = L.DDay.notificationDDayTitle
            content.body = L.DDay.notificationDDay(targetName)
        default:
            content.title = L.DDay.notificationTitle
            content.body = L.DDay.notificationGeneric(targetName, daysBefore)
        }

        content.sound = .default

        return content
    }

    private func createTrigger(for date: Date, hour: Int, minute: Int = 0) -> UNCalendarNotificationTrigger {
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        dateComponents.hour = hour
        dateComponents.minute = minute

        return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
    }

    // MARK: - Debugging

    /// 스케줄된 알림 목록 출력 (디버깅용)
    func printPendingNotifications() {
        notificationCenter.getPendingNotificationRequests { requests in
            print("스케줄된 알림 (\(requests.count)개):")
            for request in requests {
                print("  - \(request.identifier): \(request.content.title)")
            }
        }
    }
}

// MARK: - Prayer Extension for Notifications

extension Prayer {
    /// D-Day 알림 스케줄링/취소 업데이트
    func updateNotificationSchedule() {
        if notificationEnabled, let targetDate = targetDate {
            NotificationManager.shared.scheduleNotifications(for: self, targetDate: targetDate)
        } else {
            NotificationManager.shared.cancelNotifications(for: self)
        }
    }
}
