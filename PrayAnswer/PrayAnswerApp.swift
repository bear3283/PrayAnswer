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
        let config = ModelConfiguration(schema: schema, cloudKitDatabase: .automatic)
        do {
            modelContainer = try ModelContainer(for: schema, configurations: config)
        } catch {
            // CloudKit 초기화 실패 시 로컬 전용으로 재시도
            print("⚠️ ModelContainer(CloudKit) 초기화 실패, 로컬 전용으로 재시도: \(error)")
            do {
                let localConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
                modelContainer = try ModelContainer(for: schema, configurations: localConfig)
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
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }

        // 새 JSON 형식 (Share Extension에서 직접 저장) — URL scheme으로 처리 안 된 경우 대비
        // prayanswer://prayers URL로 앱이 열리면 ContentView에서 처리되므로 여기선 건너뜀
        if defaults.data(forKey: "pendingSharedPrayerData") != nil { return }

        // 구 형식 (텍스트만 공유) — AddPrayerView pre-fill
        let key = "pendingSharedPrayerText"
        guard let text = defaults.string(forKey: key), !text.isEmpty else { return }

        defaults.removeObject(forKey: key)
        defaults.synchronize()

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
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }

        // 새 JSON 형식은 URL scheme(prayanswer://prayers)으로 ContentView에서 처리
        if defaults.data(forKey: "pendingSharedPrayerData") != nil { return }

        // 구 형식 텍스트 처리
        let key = "pendingSharedPrayerText"
        guard let text = defaults.string(forKey: key), !text.isEmpty else { return }

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
