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
        do {
            modelContainer = try ModelContainer(for: Prayer.self, Attachment.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
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

                    #if DEBUG
                    // 스크린샷용 더미 데이터 1회 자동 생성
                    generateScreenshotDataOnce()
                    #endif
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

    #if DEBUG
    /// 스크린샷용 더미 데이터 1회 자동 생성 (UserDefaults로 중복 실행 방지)
    private func generateScreenshotDataOnce() {
        let key = "ScreenshotDataGenerated_v1.10"
        guard !UserDefaults.standard.bool(forKey: key) else {
            print("📸 스크린샷 데이터 이미 생성됨 - 건너뜀")
            return
        }

        ScreenshotDataGenerator.generateSampleData(in: modelContainer.mainContext)
        UserDefaults.standard.set(true, forKey: key)
        print("📸 스크린샷 데이터 1회 생성 완료")
    }

    /// 더미 데이터 재생성이 필요할 때 호출 (디버그용)
    private func resetScreenshotDataFlag() {
        UserDefaults.standard.removeObject(forKey: "ScreenshotDataGenerated_v1.7")
        print("📸 스크린샷 데이터 플래그 초기화됨")
    }
    #endif
}

// MARK: - App Delegate

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 알림 델리게이트 설정
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // 포그라운드에서 알림 표시
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }

    // 알림 탭 처리
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // 알림을 탭했을 때의 처리
        completionHandler()
    }
}
