import Foundation
import UserNotifications

/// D-Day 알림 관리자
final class NotificationManager {
    static let shared = NotificationManager()

    private let notificationCenter = UNUserNotificationCenter.current()

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

    /// 기도에 대한 D-Day 알림 스케줄링
    /// - Parameters:
    ///   - prayer: 알림을 설정할 기도
    ///   - targetDate: D-Day 목표 날짜
    func scheduleNotifications(for prayer: Prayer, targetDate: Date) {
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

    /// 기도에 대한 모든 알림 취소
    func cancelNotifications(for prayer: Prayer) {
        let identifiers = [7, 3, 1, 0].map { notificationIdentifier(for: prayer, daysBefore: $0) }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        print("알림 취소: \(identifiers)")
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

    private func createTrigger(for date: Date, hour: Int) -> UNCalendarNotificationTrigger {
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        dateComponents.hour = hour
        dateComponents.minute = 0

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
