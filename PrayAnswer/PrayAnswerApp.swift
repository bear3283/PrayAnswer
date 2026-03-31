//
//  PrayAnswerApp.swift
//  PrayAnswer
//
//  Created by bear on 6/29/25.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct PrayAnswerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // SwiftData ModelContainer
    let modelContainer: ModelContainer

    init() {
        let schema = Schema([Prayer.self, Attachment.self, PrayerCollection.self, PrayerHabit.self, PrayerHabitLog.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            modelContainer = try ModelContainer(for: schema, configurations: config)
        } catch {
            // 스키마 마이그레이션 실패 시: 기존 저장소를 유지한 채 재시도
            // (데이터 삭제 없이 앱을 안전하게 구동)
            print("⚠️ ModelContainer 초기화 실패, 재시도: \(error)")
            do {
                modelContainer = try ModelContainer(for: schema)
            } catch {
                fatalError("ModelContainer 복구 실패: \(error)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // 앱 시작 시 알림 권한 요청
                    requestNotificationPermission()

                    // 첨부 파일 마이그레이션 실행
                    Task {
                        await AttachmentMigrationManager.shared.migrateIfNeeded(
                            modelContext: modelContainer.mainContext
                        )
                    }

                    // Share Extension에서 공유된 텍스트 처리
                    checkPendingSharedText()
                }
        }
        .modelContainer(modelContainer)
    }

    private func requestNotificationPermission() {
        NotificationManager.shared.checkAuthorizationStatus { status in
            switch status {
            case .notDetermined:
                NotificationManager.shared.requestAuthorization { _ in }
            case .authorized, .provisional, .ephemeral:
                break
            case .denied:
                break
            @unknown default:
                break
            }
        }
    }

    // MARK: - Share Extension 연동

    private func checkPendingSharedText() {
        let appGroupID = "group.prayAnswer.widget"
        let key = "pendingSharedPrayerText"

        guard let defaults = UserDefaults(suiteName: appGroupID),
              let text = defaults.string(forKey: key),
              !text.isEmpty else { return }

        // 읽은 즉시 삭제 (중복 처리 방지)
        defaults.removeObject(forKey: key)
        defaults.synchronize()

        // AddPrayerView에 content pre-fill 알림 발송
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NotificationCenter.default.post(
                name: .sharedPrayerTextReceived,
                object: nil,
                userInfo: ["text": text]
            )
        }
    }

}

// MARK: - App Delegate

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // Share Extension 완료 후 앱이 포그라운드로 올 때 감지
    func applicationDidBecomeActive(_ application: UIApplication) {
        checkPendingSharedText()
    }

    // 포그라운드에서 알림 표시
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }

    // 알림 탭 처리
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    private func checkPendingSharedText() {
        let appGroupID = "group.prayAnswer.widget"
        let key = "pendingSharedPrayerText"

        guard let defaults = UserDefaults(suiteName: appGroupID),
              let text = defaults.string(forKey: key),
              !text.isEmpty else { return }

        defaults.removeObject(forKey: key)
        defaults.synchronize()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            NotificationCenter.default.post(
                name: .sharedPrayerTextReceived,
                object: nil,
                userInfo: ["text": text]
            )
        }
    }
}
