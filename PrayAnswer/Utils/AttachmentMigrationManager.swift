//
//  AttachmentMigrationManager.swift
//  PrayAnswer
//
//  기존 단일 이미지 데이터를 새 Attachment 모델로 마이그레이션
//

import Foundation
import SwiftData

/// 첨부 파일 마이그레이션 관리자
/// 기존 Prayer.imageFileName 데이터를 새 Attachment 모델로 1회성 마이그레이션
final class AttachmentMigrationManager {
    static let shared = AttachmentMigrationManager()

    // MARK: - Constants

    private let migrationKey = "AttachmentMigrationCompleted_v1"
    private let oldImageDirectoryName = "PrayerImages"
    private let newAttachmentDirectoryName = "PrayerAttachments"

    // MARK: - Properties

    private var hasMigrated: Bool {
        get { UserDefaults.standard.bool(forKey: migrationKey) }
        set { UserDefaults.standard.set(newValue, forKey: migrationKey) }
    }

    // MARK: - Initialization

    private init() {}

    // MARK: - Public Methods

    /// 마이그레이션 필요 여부 확인
    var needsMigration: Bool {
        !hasMigrated
    }

    /// 마이그레이션 실행
    /// - Parameter modelContext: SwiftData ModelContext
    @MainActor
    func migrateIfNeeded(modelContext: ModelContext) async {
        guard needsMigration else {
            PrayerLogger.shared.userAction("첨부 파일 마이그레이션 이미 완료됨")
            return
        }

        PrayerLogger.shared.userAction("첨부 파일 마이그레이션 시작")

        do {
            // 모든 기도 가져오기
            let descriptor = FetchDescriptor<Prayer>()
            let prayers = try modelContext.fetch(descriptor)

            var migratedCount = 0

            for prayer in prayers {
                // imageFileName이 있고, attachments가 비어있는 경우만 마이그레이션
                if let imageFileName = prayer.imageFileName,
                   !imageFileName.isEmpty,
                   prayer.attachments.isEmpty {

                    // 파일 복사 (PrayerImages -> PrayerAttachments)
                    if let copiedFileName = copyImageFile(from: imageFileName) {
                        // 파일 크기 확인
                        let fileSize = getFileSize(fileName: copiedFileName) ?? 0

                        // Attachment 생성
                        let attachment = Attachment(
                            fileName: copiedFileName,
                            originalName: "Image.jpg",
                            type: .image,
                            fileSize: fileSize,
                            order: 0
                        )

                        // Prayer에 추가
                        prayer.addAttachment(attachment)
                        migratedCount += 1

                        PrayerLogger.shared.userAction("기도 '\(prayer.title)' 이미지 마이그레이션 완료")
                    }
                }
            }

            // 변경사항 저장
            try modelContext.save()

            // 마이그레이션 완료 표시
            hasMigrated = true

            PrayerLogger.shared.userAction("첨부 파일 마이그레이션 완료: \(migratedCount)개 처리됨")

        } catch {
            PrayerLogger.shared.dataOperationFailed("첨부 파일 마이그레이션", error: error)
        }
    }

    /// 마이그레이션 상태 리셋 (디버그용)
    func resetMigration() {
        hasMigrated = false
        PrayerLogger.shared.userAction("첨부 파일 마이그레이션 상태 리셋")
    }

    // MARK: - Private Methods

    /// 이미지 파일 복사 (기존 디렉토리 -> 새 디렉토리)
    /// - Parameter fileName: 원본 파일명
    /// - Returns: 새 파일명 (복사 실패 시 nil)
    private func copyImageFile(from fileName: String) -> String? {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let oldDirectoryURL = documentsURL.appendingPathComponent(oldImageDirectoryName)
        let newDirectoryURL = documentsURL.appendingPathComponent(newAttachmentDirectoryName)

        let sourceURL = oldDirectoryURL.appendingPathComponent(fileName)

        // 원본 파일 존재 확인
        guard FileManager.default.fileExists(atPath: sourceURL.path) else {
            PrayerLogger.shared.dataOperationFailed("마이그레이션 원본 파일 없음", error: NSError(domain: "Migration", code: 404))
            return nil
        }

        // 새 디렉토리 생성
        if !FileManager.default.fileExists(atPath: newDirectoryURL.path) {
            do {
                try FileManager.default.createDirectory(at: newDirectoryURL, withIntermediateDirectories: true)
            } catch {
                PrayerLogger.shared.dataOperationFailed("마이그레이션 디렉토리 생성", error: error)
                return nil
            }
        }

        // 새 파일명 생성 (기존 파일명 유지 또는 새 UUID)
        let newFileName = fileName
        let destinationURL = newDirectoryURL.appendingPathComponent(newFileName)

        // 이미 존재하면 건너뛰기
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            return newFileName
        }

        do {
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            return newFileName
        } catch {
            PrayerLogger.shared.dataOperationFailed("마이그레이션 파일 복사", error: error)
            return nil
        }
    }

    /// 파일 크기 조회
    /// - Parameter fileName: 파일명
    /// - Returns: 파일 크기 (바이트)
    private func getFileSize(fileName: String) -> Int64? {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let fileURL = documentsURL
            .appendingPathComponent(newAttachmentDirectoryName)
            .appendingPathComponent(fileName)

        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            return attributes[.size] as? Int64
        } catch {
            return nil
        }
    }
}
