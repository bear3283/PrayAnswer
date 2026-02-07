//
//  AttachmentStorageManager.swift
//  PrayAnswer
//
//  첨부 파일 저장/로드/삭제 관리 - 이미지 및 PDF 지원
//

import Foundation
import UIKit
import PDFKit

/// 첨부 파일 저장 관련 에러 타입
enum AttachmentStorageError: Error, LocalizedError {
    case directoryCreationFailed
    case saveFailed
    case loadFailed
    case deleteFailed
    case invalidImage
    case invalidDocument
    case fileTooLarge
    case unsupportedFormat

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
        case .invalidDocument:
            return L.Attachment.errorInvalidDocument
        case .fileTooLarge:
            return L.Attachment.fileTooLarge
        case .unsupportedFormat:
            return L.Attachment.errorUnsupportedFormat
        }
    }
}

/// 첨부 파일 저장 결과
struct AttachmentSaveResult {
    let fileName: String
    let originalName: String
    let fileSize: Int64
    let type: AttachmentType
}

/// 첨부 파일 저장 관리자 - Documents/PrayerAttachments/ 디렉토리에 파일 저장
@Observable
final class AttachmentStorageManager {
    static let shared = AttachmentStorageManager()

    // MARK: - Constants

    private let attachmentDirectoryName = "PrayerAttachments"
    private let imageCompressionQuality: CGFloat = 0.7
    private let thumbnailSize: CGSize = CGSize(width: 200, height: 200)
    private let maxFileSize: Int64 = 20 * 1024 * 1024 // 20MB

    // MARK: - Properties

    /// 첨부 파일 저장 디렉토리 URL
    private var attachmentDirectoryURL: URL? {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentsURL.appendingPathComponent(attachmentDirectoryName)
    }

    // MARK: - Initialization

    private init() {
        createDirectoryIfNeeded()
    }

    // MARK: - Image Methods

    /// 이미지 저장 - JPEG 70% 압축
    /// - Parameter image: 저장할 UIImage
    /// - Returns: 저장 결과 (파일명, 파일 크기)
    func saveImage(_ image: UIImage) -> Result<AttachmentSaveResult, AttachmentStorageError> {
        guard let directoryURL = attachmentDirectoryURL else {
            return .failure(.directoryCreationFailed)
        }

        // JPEG 데이터로 변환
        guard let imageData = image.jpegData(compressionQuality: imageCompressionQuality) else {
            return .failure(.invalidImage)
        }

        // 파일 크기 확인
        let fileSize = Int64(imageData.count)
        if fileSize > maxFileSize {
            return .failure(.fileTooLarge)
        }

        // UUID 기반 파일명 생성
        let fileName = "\(UUID().uuidString).jpg"
        let fileURL = directoryURL.appendingPathComponent(fileName)

        do {
            try imageData.write(to: fileURL)
            PrayerLogger.shared.userAction("첨부 이미지 저장: \(fileName)")

            let result = AttachmentSaveResult(
                fileName: fileName,
                originalName: "Image.jpg",
                fileSize: fileSize,
                type: .image
            )
            return .success(result)
        } catch {
            PrayerLogger.shared.dataOperationFailed("첨부 이미지 저장", error: error)
            return .failure(.saveFailed)
        }
    }

    /// 이미지 로드
    /// - Parameter fileName: 파일명
    /// - Returns: UIImage 또는 nil
    func loadImage(fileName: String) -> UIImage? {
        guard let directoryURL = attachmentDirectoryURL else {
            return nil
        }

        let fileURL = directoryURL.appendingPathComponent(fileName)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        return UIImage(contentsOfFile: fileURL.path)
    }

    /// 이미지 썸네일 로드 (200x200)
    /// - Parameter fileName: 파일명
    /// - Returns: 썸네일 UIImage 또는 nil
    func loadImageThumbnail(fileName: String) -> UIImage? {
        guard let image = loadImage(fileName: fileName) else {
            return nil
        }
        return resizeImage(image, to: thumbnailSize)
    }

    // MARK: - Document Methods

    /// 문서 저장 (PDF)
    /// - Parameter url: 원본 파일 URL (Security-Scoped Resource)
    /// - Returns: 저장 결과
    func saveDocument(from url: URL) -> Result<AttachmentSaveResult, AttachmentStorageError> {
        guard let directoryURL = attachmentDirectoryURL else {
            return .failure(.directoryCreationFailed)
        }

        // Security-Scoped Resource 접근 시작
        let accessing = url.startAccessingSecurityScopedResource()
        defer {
            if accessing {
                url.stopAccessingSecurityScopedResource()
            }
        }

        // 파일 확장자 확인
        let pathExtension = url.pathExtension.lowercased()
        guard pathExtension == "pdf" else {
            return .failure(.unsupportedFormat)
        }

        // 파일 크기 확인
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            let fileSize = attributes[.size] as? Int64 ?? 0

            if fileSize > maxFileSize {
                return .failure(.fileTooLarge)
            }

            // UUID 기반 파일명 생성
            let fileName = "\(UUID().uuidString).pdf"
            let destinationURL = directoryURL.appendingPathComponent(fileName)

            // 파일 복사
            try FileManager.default.copyItem(at: url, to: destinationURL)
            PrayerLogger.shared.userAction("첨부 문서 저장: \(fileName)")

            let originalName = url.lastPathComponent
            let result = AttachmentSaveResult(
                fileName: fileName,
                originalName: originalName,
                fileSize: fileSize,
                type: .pdf
            )
            return .success(result)

        } catch {
            PrayerLogger.shared.dataOperationFailed("첨부 문서 저장", error: error)
            return .failure(.saveFailed)
        }
    }

    /// PDF 썸네일 로드 (첫 페이지)
    /// - Parameter fileName: 파일명
    /// - Returns: 썸네일 UIImage 또는 nil
    func loadPDFThumbnail(fileName: String) -> UIImage? {
        guard let directoryURL = attachmentDirectoryURL else {
            return nil
        }

        let fileURL = directoryURL.appendingPathComponent(fileName)

        guard let pdfDocument = PDFDocument(url: fileURL),
              let pdfPage = pdfDocument.page(at: 0) else {
            return nil
        }

        let pageRect = pdfPage.bounds(for: .mediaBox)
        let scale = min(thumbnailSize.width / pageRect.width, thumbnailSize.height / pageRect.height)
        let scaledSize = CGSize(width: pageRect.width * scale, height: pageRect.height * scale)

        let renderer = UIGraphicsImageRenderer(size: scaledSize)
        let thumbnail = renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: scaledSize))

            context.cgContext.translateBy(x: 0, y: scaledSize.height)
            context.cgContext.scaleBy(x: scale, y: -scale)
            pdfPage.draw(with: .mediaBox, to: context.cgContext)
        }

        return thumbnail
    }

    /// 첨부 타입에 따른 썸네일 로드
    /// - Parameters:
    ///   - fileName: 파일명
    ///   - type: 첨부 타입
    /// - Returns: 썸네일 UIImage 또는 nil
    func loadThumbnail(fileName: String, type: AttachmentType) -> UIImage? {
        switch type {
        case .image:
            return loadImageThumbnail(fileName: fileName)
        case .pdf:
            return loadPDFThumbnail(fileName: fileName)
        }
    }

    /// 문서 URL 반환
    /// - Parameter fileName: 파일명
    /// - Returns: 파일 URL 또는 nil
    func documentURL(fileName: String) -> URL? {
        guard let directoryURL = attachmentDirectoryURL else {
            return nil
        }

        let fileURL = directoryURL.appendingPathComponent(fileName)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        return fileURL
    }

    // MARK: - File Management

    /// 파일 삭제
    /// - Parameter fileName: 파일명
    /// - Returns: 성공 여부
    @discardableResult
    func deleteFile(fileName: String) -> Result<Void, AttachmentStorageError> {
        guard let directoryURL = attachmentDirectoryURL else {
            return .failure(.directoryCreationFailed)
        }

        let fileURL = directoryURL.appendingPathComponent(fileName)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            // 파일이 없으면 이미 삭제된 것으로 간주
            return .success(())
        }

        do {
            try FileManager.default.removeItem(at: fileURL)
            PrayerLogger.shared.userAction("첨부 파일 삭제: \(fileName)")
            return .success(())
        } catch {
            PrayerLogger.shared.dataOperationFailed("첨부 파일 삭제", error: error)
            return .failure(.deleteFailed)
        }
    }

    /// 여러 파일 삭제
    /// - Parameter fileNames: 파일명 배열
    func deleteFiles(fileNames: [String]) {
        for fileName in fileNames {
            deleteFile(fileName: fileName)
        }
    }

    /// 파일 존재 여부 확인
    /// - Parameter fileName: 파일명
    /// - Returns: 존재 여부
    func fileExists(fileName: String) -> Bool {
        guard let directoryURL = attachmentDirectoryURL else {
            return false
        }

        let fileURL = directoryURL.appendingPathComponent(fileName)
        return FileManager.default.fileExists(atPath: fileURL.path)
    }

    /// 파일 URL 반환
    /// - Parameter fileName: 파일명
    /// - Returns: 파일 URL 또는 nil
    func fileURL(fileName: String) -> URL? {
        guard let directoryURL = attachmentDirectoryURL else {
            return nil
        }

        let fileURL = directoryURL.appendingPathComponent(fileName)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        return fileURL
    }

    /// 모든 첨부 파일 삭제 (디버그/초기화용)
    func deleteAllFiles() {
        guard let directoryURL = attachmentDirectoryURL else { return }

        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
            }
            PrayerLogger.shared.userAction("모든 첨부 파일 삭제")
        } catch {
            PrayerLogger.shared.dataOperationFailed("모든 첨부 파일 삭제", error: error)
        }
    }

    // MARK: - Private Methods

    /// 첨부 파일 디렉토리 생성
    private func createDirectoryIfNeeded() {
        guard let directoryURL = attachmentDirectoryURL else { return }

        if !FileManager.default.fileExists(atPath: directoryURL.path) {
            do {
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
                PrayerLogger.shared.userAction("첨부 파일 디렉토리 생성")
            } catch {
                PrayerLogger.shared.dataOperationFailed("첨부 파일 디렉토리 생성", error: error)
            }
        }
    }

    /// 이미지 리사이즈
    private func resizeImage(_ image: UIImage, to targetSize: CGSize) -> UIImage {
        let widthRatio = targetSize.width / image.size.width
        let heightRatio = targetSize.height / image.size.height
        let ratio = min(widthRatio, heightRatio)

        let newSize = CGSize(
            width: image.size.width * ratio,
            height: image.size.height * ratio
        )

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
