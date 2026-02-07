//
//  AttachmentThumbnailView.swift
//  PrayAnswer
//
//  첨부 파일 썸네일 카드 뷰
//

import SwiftUI

/// 첨부 파일 썸네일 뷰
struct AttachmentThumbnailView: View {
    let attachment: Attachment
    let isEditing: Bool
    let onTap: () -> Void
    let onDelete: () -> Void
    let onExtractText: (() -> Void)?

    @State private var thumbnail: UIImage?
    @State private var isLoadingThumbnail = true

    private let thumbnailSize: CGFloat = 100

    init(
        attachment: Attachment,
        isEditing: Bool = false,
        onTap: @escaping () -> Void,
        onDelete: @escaping () -> Void,
        onExtractText: (() -> Void)? = nil
    ) {
        self.attachment = attachment
        self.isEditing = isEditing
        self.onTap = onTap
        self.onDelete = onDelete
        self.onExtractText = onExtractText
    }

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                // 썸네일 컨테이너
                VStack(spacing: DesignSystem.Spacing.xs) {
                    // 썸네일 이미지
                    thumbnailContent
                        .frame(width: thumbnailSize, height: thumbnailSize)
                        .background(DesignSystem.Colors.secondaryBackground)
                        .cornerRadius(DesignSystem.CornerRadius.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                .stroke(DesignSystem.Colors.primary.opacity(0.2), lineWidth: 1)
                        )

                    // 파일명
                    Text(attachment.originalName)
                        .font(DesignSystem.Typography.caption2)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .frame(width: thumbnailSize)
                }

                // 삭제 버튼 (편집 모드)
                if isEditing {
                    Button(action: onDelete) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .background(
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 22, height: 22)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .offset(x: 6, y: -6)
                }

                // OCR 버튼 (이미지만, 편집 모드)
                if isEditing && attachment.isImage && onExtractText != nil {
                    Button(action: { onExtractText?() }) {
                        Image(systemName: "text.viewfinder")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(DesignSystem.Colors.primary)
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .offset(x: 6, y: thumbnailSize - 22)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .task {
            await loadThumbnail()
        }
    }

    // MARK: - Thumbnail Content

    @ViewBuilder
    private var thumbnailContent: some View {
        if isLoadingThumbnail {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let thumbnail = thumbnail {
            Image(uiImage: thumbnail)
                .resizable()
                .scaledToFill()
                .frame(width: thumbnailSize, height: thumbnailSize)
                .clipped()
        } else {
            // 폴백 아이콘
            VStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: attachment.type.iconName)
                    .font(.system(size: 32))
                    .foregroundColor(DesignSystem.Colors.primary)

                Text(attachment.type.displayName)
                    .font(DesignSystem.Typography.caption2)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Load Thumbnail

    private func loadThumbnail() async {
        isLoadingThumbnail = true

        let loadedThumbnail = await Task.detached(priority: .userInitiated) {
            AttachmentStorageManager.shared.loadThumbnail(
                fileName: attachment.fileName,
                type: attachment.type
            )
        }.value

        await MainActor.run {
            thumbnail = loadedThumbnail
            isLoadingThumbnail = false
        }
    }
}

/// 임시 첨부 파일용 썸네일 뷰 (저장 전)
struct PendingAttachmentThumbnailView: View {
    let pendingAttachment: PendingAttachment
    let onDelete: () -> Void
    let onExtractText: (() -> Void)?

    private let thumbnailSize: CGFloat = 100

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: DesignSystem.Spacing.xs) {
                // 썸네일 이미지
                thumbnailContent
                    .frame(width: thumbnailSize, height: thumbnailSize)
                    .background(DesignSystem.Colors.secondaryBackground)
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                            .stroke(DesignSystem.Colors.primary.opacity(0.2), lineWidth: 1)
                    )

                // 파일명
                Text(pendingAttachment.originalName)
                    .font(DesignSystem.Typography.caption2)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .frame(width: thumbnailSize)
            }

            // 삭제 버튼
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(Color.red)
                            .frame(width: 22, height: 22)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .offset(x: 6, y: -6)

            // OCR 버튼 (이미지만)
            if pendingAttachment.type == .image && onExtractText != nil {
                Button(action: { onExtractText?() }) {
                    Image(systemName: "text.viewfinder")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(DesignSystem.Colors.primary)
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
                .offset(x: 6, y: thumbnailSize - 22)
            }
        }
    }

    @ViewBuilder
    private var thumbnailContent: some View {
        if let thumbnail = pendingAttachment.thumbnail {
            Image(uiImage: thumbnail)
                .resizable()
                .scaledToFill()
                .frame(width: thumbnailSize, height: thumbnailSize)
                .clipped()
        } else {
            VStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: pendingAttachment.type.iconName)
                    .font(.system(size: 32))
                    .foregroundColor(DesignSystem.Colors.primary)

                Text(pendingAttachment.type.displayName)
                    .font(DesignSystem.Typography.caption2)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

/// 임시 첨부 파일 구조체 (저장 전 상태)
struct PendingAttachment: Identifiable {
    let id = UUID()
    let type: AttachmentType
    let thumbnail: UIImage?
    let fileName: String
    let originalName: String
    let fileSize: Int64
}
