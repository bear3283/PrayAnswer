//
//  PrayAnswerApp.swift
//  PrayAnswer
//
//  Created by bear on 6/29/25.
//

import SwiftUI
import SwiftData
import UserNotifications
import CoreData

@main
struct PrayAnswerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // SwiftData ModelContainer
    let modelContainer: ModelContainer

    init() {
        let schema = Schema([Prayer.self, Attachment.self, PrayerCollection.self, PrayerHabit.self, PrayerHabitLog.self])
        modelContainer = Self.makeModelContainer(schema: schema)
    }

    private static func makeModelContainer(schema: Schema) -> ModelContainer {
        // 1차: CloudKit 동기화 활성화 (iCloud 로그인 + 컨테이너 정상일 때)
        if let container = try? ModelContainer(
            for: schema,
            configurations: ModelConfiguration(schema: schema, cloudKitDatabase: .automatic)
        ) {
            print("✅ ModelContainer(CloudKit) 초기화 성공")
            return container
        }
        print("⚠️ CloudKit 초기화 실패, 로컬 전용으로 재시도")

        // 2차: 로컬 전용 (기존 저장소 그대로 사용)
        if let container = try? ModelContainer(
            for: schema,
            configurations: ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        ) {
            print("✅ ModelContainer(로컬) 초기화 성공")
            return container
        }
        print("⚠️ 로컬 초기화 실패, 기본 설정으로 재시도")

        // 3차: 설정 없이 기본값으로 시도
        if let container = try? ModelContainer(for: schema) {
            print("✅ ModelContainer(기본) 초기화 성공")
            return container
        }
        print("⚠️ 기본 초기화 실패, 저장소 초기화 후 재생성")

        // 4차: 기존 저장소 삭제 후 새로 생성 (최후 수단 — 데이터 손실 발생)
        let storeURL = URL.applicationSupportDirectory.appending(path: "default.store")
        for ext in ["", "-shm", "-wal"] {
            try? FileManager.default.removeItem(at: storeURL.appendingPathExtension(ext))
        }
        do {
            let container = try ModelContainer(for: schema)
            print("✅ ModelContainer 저장소 재생성 성공")
            return container
        } catch {
            fatalError("ModelContainer 완전 초기화 실패: \(error)")
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
                .onReceive(
                    NotificationCenter.default.publisher(
                        for: NSPersistentCloudKitContainer.eventChangedNotification
                    )
                ) { notification in
                    handleCloudKitEvent(notification)
                }
        }
        .modelContainer(modelContainer)
    }

    // MARK: - CloudKit 동기화 이벤트 처리

    private func handleCloudKitEvent(_ notification: Notification) {
        guard
            let event = notification.userInfo?[
                NSPersistentCloudKitContainer.eventNotificationUserInfoKey
            ] as? NSPersistentCloudKitContainer.Event,
            event.type == .import,
            event.endDate != nil,
            event.error == nil
        else { return }

        // 다른 기기에서 import 완료 → 위젯 데이터 갱신
        DispatchQueue.main.async {
            refreshWidgetData()
        }
    }

    private func refreshWidgetData() {
        let context = modelContainer.mainContext
        guard let prayers = try? context.fetch(FetchDescriptor<Prayer>()) else { return }

        var dataByStorage: [PrayerStorage: [PrayerWidgetData]] = [:]
        for storage in PrayerStorage.allCases {
            let filtered = prayers
                .filter { $0.storage == storage && $0.isFavorite }
                .sorted { $0.createdDate > $1.createdDate }
            dataByStorage[storage] = filtered.map { $0.toWidgetData() }
        }
        WidgetDataManager.shared.shareFavoritePrayersByStorage(dataByStorage)
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
