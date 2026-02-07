//
//  Attachment.swift
//  PrayAnswer
//
//  첨부 파일 모델 - 이미지 및 PDF 지원
//

import Foundation
import SwiftData

/// 첨부 파일 타입
enum AttachmentType: String, Codable, CaseIterable {
    case image
    case pdf

    var displayName: String {
        switch self {
        case .image:
            return L.Attachment.typeImage
        case .pdf:
            return L.Attachment.typePDF
        }
    }

    var iconName: String {
        switch self {
        case .image:
            return "photo.fill"
        case .pdf:
            return "doc.richtext.fill"
        }
    }
}

/// 첨부 파일 모델
@Model
final class Attachment {
    /// 저장된 파일명 (UUID 기반, PrayerAttachments/ 디렉토리)
    var fileName: String

    /// 표시용 원본 파일명
    var originalName: String

    /// 첨부 타입 (이미지 또는 PDF)
    var typeRawValue: String

    /// 파일 크기 (바이트)
    var fileSize: Int64

    /// 생성 날짜
    var createdDate: Date

    /// 표시 순서
    var order: Int

    /// OCR 추출 텍스트 (이미지만 해당)
    var ocrText: String?

    /// 연결된 기도
    @Relationship(inverse: \Prayer.attachments)
    var prayer: Prayer?

    // MARK: - Computed Properties

    var type: AttachmentType {
        get { AttachmentType(rawValue: typeRawValue) ?? .image }
        set { typeRawValue = newValue.rawValue }
    }

    var isImage: Bool {
        type == .image
    }

    var isPDF: Bool {
        type == .pdf
    }

    /// 파일 크기 표시 문자열 (KB, MB)
    var formattedFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }

    // MARK: - Initialization

    init(fileName: String, originalName: String, type: AttachmentType, fileSize: Int64, order: Int = 0, ocrText: String? = nil) {
        self.fileName = fileName
        self.originalName = originalName
        self.typeRawValue = type.rawValue
        self.fileSize = fileSize
        self.createdDate = Date()
        self.order = order
        self.ocrText = ocrText
    }

    // MARK: - Methods

    /// OCR 텍스트 업데이트
    func updateOCRText(_ text: String?) {
        self.ocrText = text
    }
}

// MARK: - Attachment Comparable

extension Attachment: Comparable {
    static func < (lhs: Attachment, rhs: Attachment) -> Bool {
        lhs.order < rhs.order
    }
}
