//
//  CalendarManager.swift
//  PrayAnswer
//
//  Created for D-Day Calendar Integration
//

import Foundation
import EventKit

/// D-Day 캘린더 연동 관리자
final class CalendarManager {
    static let shared = CalendarManager()

    private let eventStore = EKEventStore()

    private init() {}

    // MARK: - Permission

    /// 캘린더 권한 상태 확인
    var authorizationStatus: EKAuthorizationStatus {
        if #available(iOS 17.0, *) {
            return EKEventStore.authorizationStatus(for: .event)
        } else {
            return EKEventStore.authorizationStatus(for: .event)
        }
    }

    /// 캘린더 접근 권한이 있는지 확인
    var hasCalendarAccess: Bool {
        let status = authorizationStatus
        if #available(iOS 17.0, *) {
            return status == .fullAccess || status == .writeOnly
        } else {
            return status == .authorized
        }
    }

    /// 캘린더 권한 요청
    func requestAccess(completion: @escaping (Bool, Error?) -> Void) {
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents { granted, error in
                DispatchQueue.main.async {
                    completion(granted, error)
                }
            }
        } else {
            eventStore.requestAccess(to: .event) { granted, error in
                DispatchQueue.main.async {
                    completion(granted, error)
                }
            }
        }
    }

    // MARK: - Calendar Events

    /// D-Day 이벤트를 캘린더에 추가
    /// - Parameters:
    ///   - prayer: 기도 객체
    ///   - targetDate: D-Day 목표 날짜
    ///   - addReminder: 알림 추가 여부
    /// - Returns: 생성된 이벤트 식별자
    func addDDayEvent(
        for prayer: Prayer,
        targetDate: Date,
        addReminder: Bool = true,
        completion: @escaping (Result<String, CalendarError>) -> Void
    ) {
        guard hasCalendarAccess else {
            requestAccess { [weak self] granted, error in
                if granted {
                    self?.addDDayEvent(for: prayer, targetDate: targetDate, addReminder: addReminder, completion: completion)
                } else {
                    completion(.failure(.permissionDenied))
                }
            }
            return
        }

        // 이벤트 생성
        let event = EKEvent(eventStore: eventStore)

        // 이벤트 제목 설정
        let targetName = prayer.target.isEmpty ? L.Target.myself : prayer.target
        event.title = L.Calendar.eventTitle(targetName)

        // 이벤트 노트 설정
        event.notes = L.Calendar.eventNotes(prayer.title, prayer.content)

        // 시작/종료 시간 설정 (종일 이벤트)
        event.startDate = Calendar.current.startOfDay(for: targetDate)
        event.endDate = Calendar.current.startOfDay(for: targetDate)
        event.isAllDay = true

        // 기본 캘린더 설정 (nil 체크)
        guard let calendar = eventStore.defaultCalendarForNewEvents else {
            PrayerLogger.shared.dataOperationFailed("캘린더 이벤트 저장", error: NSError(domain: "CalendarManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "기본 캘린더 없음"]))
            completion(.failure(.unknownError))
            return
        }
        event.calendar = calendar

        // 알림 추가 (D-7, D-3, D-1)
        if addReminder {
            // D-7 알림 (7일 전 오전 9시)
            let alarm7Days = EKAlarm(relativeOffset: -7 * 24 * 60 * 60 + 9 * 60 * 60)
            event.addAlarm(alarm7Days)

            // D-3 알림 (3일 전 오전 9시)
            let alarm3Days = EKAlarm(relativeOffset: -3 * 24 * 60 * 60 + 9 * 60 * 60)
            event.addAlarm(alarm3Days)

            // D-1 알림 (1일 전 오전 9시)
            let alarm1Day = EKAlarm(relativeOffset: -1 * 24 * 60 * 60 + 9 * 60 * 60)
            event.addAlarm(alarm1Day)
        }

        // 이벤트 저장
        do {
            try eventStore.save(event, span: .thisEvent)
            PrayerLogger.shared.userAction("캘린더에 D-Day 이벤트 추가: \(prayer.title)")
            completion(.success(event.eventIdentifier))
        } catch {
            PrayerLogger.shared.dataOperationFailed("캘린더 이벤트 저장", error: error)
            completion(.failure(.saveFailed(error)))
        }
    }

    /// 캘린더에서 이벤트 삭제
    /// - Parameter eventIdentifier: 이벤트 식별자
    func removeEvent(withIdentifier eventIdentifier: String, completion: @escaping (Result<Void, CalendarError>) -> Void) {
        guard hasCalendarAccess else {
            completion(.failure(.permissionDenied))
            return
        }

        guard let event = eventStore.event(withIdentifier: eventIdentifier) else {
            completion(.failure(.eventNotFound))
            return
        }

        do {
            try eventStore.remove(event, span: .thisEvent)
            PrayerLogger.shared.userAction("캘린더에서 D-Day 이벤트 삭제")
            completion(.success(()))
        } catch {
            PrayerLogger.shared.dataOperationFailed("캘린더 이벤트 삭제", error: error)
            completion(.failure(.deleteFailed(error)))
        }
    }

    /// 이벤트 존재 여부 확인
    /// - Parameter eventIdentifier: 이벤트 식별자
    /// - Returns: 이벤트 존재 여부
    func eventExists(withIdentifier eventIdentifier: String) -> Bool {
        guard hasCalendarAccess else { return false }
        return eventStore.event(withIdentifier: eventIdentifier) != nil
    }

    /// 이벤트 업데이트
    /// - Parameters:
    ///   - eventIdentifier: 기존 이벤트 식별자
    ///   - prayer: 업데이트할 기도 객체
    ///   - targetDate: 새로운 목표 날짜
    func updateEvent(
        withIdentifier eventIdentifier: String,
        prayer: Prayer,
        targetDate: Date,
        addReminder: Bool = true,
        completion: @escaping (Result<String, CalendarError>) -> Void
    ) {
        // 기존 이벤트 삭제 후 새로 생성
        removeEvent(withIdentifier: eventIdentifier) { [weak self] result in
            switch result {
            case .success:
                self?.addDDayEvent(for: prayer, targetDate: targetDate, addReminder: addReminder, completion: completion)
            case .failure:
                // 기존 이벤트가 없어도 새로 생성
                self?.addDDayEvent(for: prayer, targetDate: targetDate, addReminder: addReminder, completion: completion)
            }
        }
    }
}

// MARK: - Calendar Error

enum CalendarError: Error, LocalizedError {
    case permissionDenied
    case saveFailed(Error)
    case deleteFailed(Error)
    case eventNotFound
    case unknownError

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return L.Calendar.errorPermissionDenied
        case .saveFailed(let error):
            return L.Calendar.errorSaveFailed(error.localizedDescription)
        case .deleteFailed(let error):
            return L.Calendar.errorDeleteFailed(error.localizedDescription)
        case .eventNotFound:
            return L.Calendar.errorEventNotFound
        case .unknownError:
            return L.Calendar.errorUnknown
        }
    }
}
