import Foundation
import StoreKit
import SwiftUI

/// 앱스토어 리뷰 요청 관리자
/// 하이브리드 전략: 기도 응답 시(Primary) + 기도 생성 마일스톤(Fallback)
final class ReviewRequestManager {
    static let shared = ReviewRequestManager()

    // MARK: - AppStorage Keys

    private let totalPrayerCountKey = "ReviewRequest_totalPrayerCount"
    private let answeredPrayerCountKey = "ReviewRequest_answeredPrayerCount"
    private let lastVersionPromptedKey = "ReviewRequest_lastVersionPrompted"
    private let lastPromptDateKey = "ReviewRequest_lastPromptDate"

    // MARK: - Milestones

    /// 기도 응답 마일스톤 (Primary - 감사의 순간)
    private let answeredMilestones: Set<Int> = [1, 3, 5]

    /// 기도 생성 마일스톤 (Fallback - 응답 표시 안 하는 사용자용)
    private let prayerMilestones: Set<Int> = [10, 25, 50]

    /// 리뷰 요청 최소 간격 (일)
    private let minimumDaysBetweenPrompts = 90

    private init() {}

    // MARK: - Computed Properties

    private var totalPrayerCount: Int {
        get { UserDefaults.standard.integer(forKey: totalPrayerCountKey) }
        set { UserDefaults.standard.set(newValue, forKey: totalPrayerCountKey) }
    }

    private var answeredPrayerCount: Int {
        get { UserDefaults.standard.integer(forKey: answeredPrayerCountKey) }
        set { UserDefaults.standard.set(newValue, forKey: answeredPrayerCountKey) }
    }

    private var lastVersionPrompted: String {
        get { UserDefaults.standard.string(forKey: lastVersionPromptedKey) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: lastVersionPromptedKey) }
    }

    private var lastPromptDate: Date? {
        get {
            let interval = UserDefaults.standard.double(forKey: lastPromptDateKey)
            return interval > 0 ? Date(timeIntervalSince1970: interval) : nil
        }
        set {
            UserDefaults.standard.set(newValue?.timeIntervalSince1970 ?? 0, forKey: lastPromptDateKey)
        }
    }

    private var currentAppVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    // MARK: - Public Methods

    /// 기도 생성 후 호출 - 카운트 증가 및 리뷰 요청 여부 반환
    func recordPrayerCreated() -> Bool {
        totalPrayerCount += 1
        let count = totalPrayerCount

        #if DEBUG
        print("📊 리뷰 매니저: 기도 생성 \(count)번째")
        #endif

        guard prayerMilestones.contains(count) else { return false }
        return canRequestReview()
    }

    /// 기도 응답(yes) 후 호출 - 카운트 증가 및 리뷰 요청 여부 반환
    func recordPrayerAnswered() -> Bool {
        answeredPrayerCount += 1
        let count = answeredPrayerCount

        #if DEBUG
        print("📊 리뷰 매니저: 기도 응답 \(count)번째")
        #endif

        guard answeredMilestones.contains(count) else { return false }
        return canRequestReview()
    }

    /// 리뷰 요청 실행 후 호출 - 상태 업데이트
    func didRequestReview() {
        lastVersionPrompted = currentAppVersion
        lastPromptDate = Date()

        #if DEBUG
        print("📊 리뷰 매니저: 리뷰 요청 완료 (버전: \(currentAppVersion))")
        #endif
    }

    // MARK: - Private Methods

    /// 리뷰 요청 가능 여부 확인
    private func canRequestReview() -> Bool {
        // 1. 같은 버전에서 이미 요청했는지 확인
        guard currentAppVersion != lastVersionPrompted else {
            #if DEBUG
            print("📊 리뷰 매니저: 이 버전에서 이미 요청함 - 건너뜀")
            #endif
            return false
        }

        // 2. 최소 간격 확인 (90일)
        if let lastDate = lastPromptDate {
            let daysSinceLastPrompt = Calendar.current.dateComponents(
                [.day], from: lastDate, to: Date()
            ).day ?? 0

            guard daysSinceLastPrompt >= minimumDaysBetweenPrompts else {
                #if DEBUG
                print("📊 리뷰 매니저: 최소 간격 미충족 (\(daysSinceLastPrompt)/\(minimumDaysBetweenPrompts)일) - 건너뜀")
                #endif
                return false
            }
        }

        return true
    }
}
