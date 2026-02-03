//
//  ImageStorageManager.swift
//  PrayAnswer
//
//  이미지 파일 저장/로드/삭제 관리
//

import Foundation
import UIKit

/// 이미지 저장 관련 에러 타입
enum ImageStorageError: Error, LocalizedError {
    case directoryCreationFailed
    case saveFailed
    case loadFailed
    case deleteFailed
    case invalidImage

    var errorDescription: String? {
        switch self {
        case .directoryCreationFailed:
            return L.Image.errorDirectoryCreation
        case .saveFailed:
            return L.Image.errorSaveFailed
        case .loadFailed:
            return L.Image.errorLoadFailed
        case .deleteFailed:
            return L.Image.errorDeleteFailed
        case .invalidImage:
            return L.Image.errorInvalidImage
        }
    }
}

/// 이미지 저장 관리자 - Documents/PrayerImages/ 디렉토리에 이미지 저장
@Observable
final class ImageStorageManager {
    static let shared = ImageStorageManager()

    // MARK: - Constants

    private let imageDirectoryName = "PrayerImages"
    private let compressionQuality: CGFloat = 0.7

    // MARK: - Properties

    /// 이미지 저장 디렉토리 URL
    private var imageDirectoryURL: URL? {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentsURL.appendingPathComponent(imageDirectoryName)
    }

    // MARK: - Initialization

    private init() {
        createImageDirectoryIfNeeded()
    }

    // MARK: - Public Methods

    /// 이미지 저장 - JPEG 70% 압축
    /// - Parameter image: 저장할 UIImage
    /// - Returns: 저장된 파일명 (UUID.jpg)
    func saveImage(_ image: UIImage) -> Result<String, ImageStorageError> {
        guard let directoryURL = imageDirectoryURL else {
            return .failure(.directoryCreationFailed)
        }

        // JPEG 데이터로 변환
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else {
            return .failure(.invalidImage)
        }

        // UUID 기반 파일명 생성
        let fileName = "\(UUID().uuidString).jpg"
        let fileURL = directoryURL.appendingPathComponent(fileName)

        do {
            try imageData.write(to: fileURL)
            PrayerLogger.shared.userAction("이미지 저장: \(fileName)")
            return .success(fileName)
        } catch {
            PrayerLogger.shared.dataOperationFailed("이미지 저장", error: error)
            return .failure(.saveFailed)
        }
    }

    /// 이미지 로드
    /// - Parameter fileName: 파일명
    /// - Returns: UIImage 또는 nil
    func loadImage(fileName: String) -> UIImage? {
        guard let directoryURL = imageDirectoryURL else {
            return nil
        }

        let fileURL = directoryURL.appendingPathComponent(fileName)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        return UIImage(contentsOfFile: fileURL.path)
    }

    /// 이미지 삭제
    /// - Parameter fileName: 파일명
    /// - Returns: 성공 여부
    @discardableResult
    func deleteImage(fileName: String) -> Result<Void, ImageStorageError> {
        guard let directoryURL = imageDirectoryURL else {
            return .failure(.directoryCreationFailed)
        }

        let fileURL = directoryURL.appendingPathComponent(fileName)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            // 파일이 없으면 이미 삭제된 것으로 간주
            return .success(())
        }

        do {
            try FileManager.default.removeItem(at: fileURL)
            PrayerLogger.shared.userAction("이미지 삭제: \(fileName)")
            return .success(())
        } catch {
            PrayerLogger.shared.dataOperationFailed("이미지 삭제", error: error)
            return .failure(.deleteFailed)
        }
    }

    /// 이미지 파일 존재 여부 확인
    /// - Parameter fileName: 파일명
    /// - Returns: 존재 여부
    func imageExists(fileName: String) -> Bool {
        guard let directoryURL = imageDirectoryURL else {
            return false
        }

        let fileURL = directoryURL.appendingPathComponent(fileName)
        return FileManager.default.fileExists(atPath: fileURL.path)
    }

    /// 이미지 파일 URL 반환
    /// - Parameter fileName: 파일명
    /// - Returns: 파일 URL 또는 nil
    func imageURL(fileName: String) -> URL? {
        guard let directoryURL = imageDirectoryURL else {
            return nil
        }

        let fileURL = directoryURL.appendingPathComponent(fileName)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        return fileURL
    }

    /// 모든 이미지 파일 삭제 (디버그/초기화용)
    func deleteAllImages() {
        guard let directoryURL = imageDirectoryURL else { return }

        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
            }
            PrayerLogger.shared.userAction("모든 이미지 삭제")
        } catch {
            PrayerLogger.shared.dataOperationFailed("모든 이미지 삭제", error: error)
        }
    }

    // MARK: - Private Methods

    /// 이미지 디렉토리 생성
    private func createImageDirectoryIfNeeded() {
        guard let directoryURL = imageDirectoryURL else { return }

        if !FileManager.default.fileExists(atPath: directoryURL.path) {
            do {
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
                PrayerLogger.shared.userAction("이미지 디렉토리 생성")
            } catch {
                PrayerLogger.shared.dataOperationFailed("이미지 디렉토리 생성", error: error)
            }
        }
    }
}
