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
    @Environment(\.scenePhase) private var scenePhase

    // SwiftData ModelContainer
    let modelContainer: ModelContainer

    init() {
        let schema = Schema([Prayer.self, Attachment.self, PrayerCollection.self, PrayerHabit.self, PrayerHabitLog.self])
        modelContainer = Self.makeModelContainer(schema: schema)
    }

    private static func makeModelContainer(schema: Schema) -> ModelContainer {
        // 1차: CloudKit 동기화 활성화
        if let container = try? ModelContainer(
            for: schema,
            configurations: ModelConfiguration(schema: schema, cloudKitDatabase: .automatic)
        ) {
            #if DEBUG
            print("✅ ModelContainer(CloudKit) 초기화 성공")
            #endif
            return container
        }
        #if DEBUG
        print("⚠️ CloudKit 초기화 실패, 로컬 전용으로 재시도")
        #endif

        // 로컬 전용 — cloudKitDatabase: .none 명시로 entitlements의 CloudKit 키 무시
        let localConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .none)
        if let container = try? ModelContainer(for: schema, configurations: localConfig) {
            #if DEBUG
            print("✅ ModelContainer(로컬) 초기화 성공")
            #endif
            return container
        }
        #if DEBUG
        print("⚠️ 로컬 초기화 실패, 저장소 재생성 시도")
        #endif

        // 최후 수단: 기존 저장소를 삭제하지 않고 백업 이동 후 재생성
        // (삭제 대신 이동 → 복구 가능성 유지)
        if let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            let backupDir = appSupport.appendingPathComponent("StoreBackup_\(Int(Date().timeIntervalSince1970))")
            try? FileManager.default.createDirectory(at: backupDir, withIntermediateDirectories: true)
            for name in ["default.store", "default.store-shm", "default.store-wal"] {
                let src = appSupport.appendingPathComponent(name)
                let dst = backupDir.appendingPathComponent(name)
                try? FileManager.default.moveItem(at: src, to: dst)
            }
            #if DEBUG
            print("⚠️ 저장소를 백업으로 이동: \(backupDir.lastPathComponent)")
            #endif
        }
        do {
            let container = try ModelContainer(for: schema, configurations: localConfig)
            #if DEBUG
            print("✅ ModelContainer 저장소 재생성 성공")
            #endif
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
                    ).receive(on: DispatchQueue.main)
                ) { notification in
                    handleCloudKitEvent(notification)
                }
        }
        .modelContainer(modelContainer)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                SharedTextHandler.processPending(delay: 0.3)
            }
        }
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
        SharedTextHandler.processPending(delay: 0.5)
    }

}

// MARK: - App Delegate

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // 포그라운드에서 알림 표시
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }

    // 알림 탭 처리
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}

// MARK: - Share Extension 텍스트 공유 처리 (중복 제거용 헬퍼)

private enum SharedTextHandler {
    static func processPending(delay: Double) {
        let appGroupID = "group.prayAnswer.widget"
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }

        // 새 JSON 형식: URL scheme 전달이 실패한 경우를 대비해 알림으로도 fallback 처리
        if defaults.data(forKey: "pendingSharedPrayerData") != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                NotificationCenter.default.post(name: .pendingSharedPrayerDataAvailable, object: nil)
            }
            return
        }

        let key = "pendingSharedPrayerText"
        guard let text = defaults.string(forKey: key), !text.isEmpty else { return }

        defaults.removeObject(forKey: key)
        defaults.synchronize()

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            NotificationCenter.default.post(
                name: .sharedPrayerTextReceived,
                object: nil,
                userInfo: ["text": text]
            )
        }
    }
}
