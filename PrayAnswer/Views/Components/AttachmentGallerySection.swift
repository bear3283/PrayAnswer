//
//  AttachmentGallerySection.swift
//  PrayAnswer
//
//  첨부 파일 갤러리 섹션 뷰 - 복수 이미지 + PDF 지원
//

import SwiftUI
import PhotosUI

/// 첨부 파일 갤러리 섹션
struct AttachmentGallerySection: View {
    /// 저장된 첨부 파일 목록 (보기/편집 모드)
    @Binding var attachments: [Attachment]

    /// 임시 첨부 파일 목록 (추가 모드)
    @Binding var pendingAttachments: [PendingAttachment]

    /// 읽기 전용 모드 (상세 보기)
    let readOnly: Bool

    /// 최대 첨부 개수
    let maxAttachments: Int

    /// 탭 액션 (전체화면 미리보기)
    let onTapAttachment: ((Int) -> Void)?

    /// OCR 텍스트 추출 액션
    let onExtractText: ((UIImage) -> Void)?

    /// 전체 OCR 추출 액션
    let onExtractAllText: (() -> Void)?

    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var isLoadingImages = false
    @State private var showDocumentPicker = false
    @State private var showMaxAttachmentAlert = false

    private var totalCount: Int {
        attachments.count + pendingAttachments.count
    }

    private var canAddMore: Bool {
        totalCount < maxAttachments
    }

    private var remainingSlots: Int {
        max(0, maxAttachments - totalCount)
    }

    init(
        attachments: Binding<[Attachment]> = .constant([]),
        pendingAttachments: Binding<[PendingAttachment]> = .constant([]),
        readOnly: Bool = false,
        maxAttachments: Int = 10,
        onTapAttachment: ((Int) -> Void)? = nil,
        onExtractText: ((UIImage) -> Void)? = nil,
        onExtractAllText: (() -> Void)? = nil
    ) {
        self._attachments = attachments
        self._pendingAttachments = pendingAttachments
        self.readOnly = readOnly
        self.maxAttachments = maxAttachments
        self.onTapAttachment = onTapAttachment
        self.onExtractText = onExtractText
        self.onExtractAllText = onExtractAllText
    }

    var body: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                // 헤더
                headerView

                // 갤러리 또는 빈 상태
                if totalCount > 0 {
                    galleryView
                } else if !readOnly {
                    emptyStateView
                }

                // 추가 버튼 (편집 모드, 공간이 있을 때)
                if !readOnly && canAddMore && totalCount > 0 {
                    addButtonsView
                }

                // 전체 OCR 버튼 (이미지가 2개 이상일 때)
                if !readOnly && hasMultipleImages {
                    extractAllButton
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }
        .onChange(of: selectedPhotoItems) { _, newValue in
            Task {
                await loadSelectedImages(from: newValue)
            }
        }
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPickerSheet { urls in
                loadSelectedDocuments(from: urls)
            }
        }
        .alert(L.Attachment.maxReached, isPresented: $showMaxAttachmentAlert) {
            Button(L.Button.confirm) { }
        } message: {
            Text(L.Attachment.maxReachedMessage(maxAttachments))
        }
    }

    // MARK: - Header View

    private var headerView: some View {
        HStack {
            Label {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Text(L.Attachment.sectionTitle)
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                        .fontWeight(.medium)

                    if totalCount > 0 {
                        Text("\(totalCount)")
                            .font(DesignSystem.Typography.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(DesignSystem.Colors.primary)
                            .clipShape(Capsule())
                    }
                }
            } icon: {
                Image(systemName: "paperclip")
                    .foregroundColor(DesignSystem.Colors.primary)
            }

            Spacer()

            if !readOnly && totalCount > 0 {
                Text("\(totalCount)/\(maxAttachments)")
                    .font(DesignSystem.Typography.caption2)
                    .foregroundColor(DesignSystem.Colors.tertiaryText)
            }
        }
    }

    // MARK: - Gallery View

    private var galleryView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: DesignSystem.Spacing.md) {
                // 저장된 첨부 파일
                ForEach(Array(attachments.enumerated()), id: \.element.fileName) { index, attachment in
                    AttachmentThumbnailView(
                        attachment: attachment,
                        isEditing: !readOnly,
                        onTap: {
                            onTapAttachment?(index)
                        },
                        onDelete: {
                            removeAttachment(at: index)
                        },
                        onExtractText: attachment.isImage ? {
                            extractTextFromAttachment(attachment)
                        } : nil
                    )
                }

                // 임시 첨부 파일
                ForEach(Array(pendingAttachments.enumerated()), id: \.element.id) { index, pending in
                    PendingAttachmentThumbnailView(
                        pendingAttachment: pending,
                        onDelete: {
                            removePendingAttachment(at: index)
                        },
                        onExtractText: pending.type == .image ? {
                            if let thumbnail = pending.thumbnail {
                                onExtractText?(thumbnail)
                            }
                        } : nil
                    )
                }
            }
            .padding(.vertical, DesignSystem.Spacing.xs)
        }
    }

    // MARK: - Empty State View

    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // 점선 테두리 드롭존
            VStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: "plus.rectangle.on.folder")
                    .font(.system(size: 40))
                    .foregroundColor(DesignSystem.Colors.primary.opacity(0.6))

                Text(L.Attachment.addAttachment)
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(DesignSystem.Colors.primary.opacity(0.05))
            .cornerRadius(DesignSystem.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .stroke(DesignSystem.Colors.primary.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [8]))
            )

            // 추가 버튼
            addButtonsView
        }
    }

    // MARK: - Add Buttons View

    private var addButtonsView: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // 사진 추가 버튼
            PhotosPicker(
                selection: $selectedPhotoItems,
                maxSelectionCount: remainingSlots,
                matching: .images,
                photoLibrary: .shared()
            ) {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    if isLoadingImages {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "photo.badge.plus")
                            .font(.caption)
                    }
                    Text(L.Attachment.addImage)
                        .font(DesignSystem.Typography.caption)
                }
                .foregroundColor(DesignSystem.Colors.primary)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(DesignSystem.Colors.primary.opacity(0.1))
                .cornerRadius(DesignSystem.CornerRadius.medium)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!canAddMore || isLoadingImages)

            // 파일 추가 버튼
            Button(action: {
                if canAddMore {
                    showDocumentPicker = true
                } else {
                    showMaxAttachmentAlert = true
                }
            }) {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "doc.badge.plus")
                        .font(.caption)
                    Text(L.Attachment.addFile)
                        .font(DesignSystem.Typography.caption)
                }
                .foregroundColor(DesignSystem.Colors.primary)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(DesignSystem.Colors.primary.opacity(0.1))
                .cornerRadius(DesignSystem.CornerRadius.medium)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!canAddMore)

            Spacer()
        }
    }

    // MARK: - Extract All Button

    private var hasMultipleImages: Bool {
        let imageCount = attachments.filter { $0.isImage }.count + pendingAttachments.filter { $0.type == .image }.count
        return imageCount >= 2
    }

    private var extractAllButton: some View {
        Button(action: {
            onExtractAllText?()
        }) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "text.viewfinder")
                    .font(.caption)
                Text(L.Attachment.extractAllText)
                    .font(DesignSystem.Typography.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(DesignSystem.Colors.primary)
            .cornerRadius(DesignSystem.CornerRadius.medium)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Actions

    private func loadSelectedImages(from items: [PhotosPickerItem]) async {
        guard !items.isEmpty else { return }

        await MainActor.run {
            isLoadingImages = true
        }

        for item in items {
            do {
                if let data = try await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {

                    // 이미지 저장
                    let result = AttachmentStorageManager.shared.saveImage(uiImage)

                    await MainActor.run {
                        switch result {
                        case .success(let saveResult):
                            // 썸네일 생성
                            let thumbnail = AttachmentStorageManager.shared.loadImageThumbnail(fileName: saveResult.fileName)

                            let pending = PendingAttachment(
                                type: .image,
                                thumbnail: thumbnail ?? uiImage,
                                fileName: saveResult.fileName,
                                originalName: saveResult.originalName,
                                fileSize: saveResult.fileSize
                            )
                            pendingAttachments.append(pending)

                        case .failure(let error):
                            PrayerLogger.shared.dataOperationFailed("이미지 로드", error: error)
                        }
                    }
                }
            } catch {
                PrayerLogger.shared.dataOperationFailed("PhotosPicker 이미지 로드", error: error)
            }
        }

        await MainActor.run {
            selectedPhotoItems = []
            isLoadingImages = false
        }
    }

    private func loadSelectedDocuments(from urls: [URL]) {
        for url in urls {
            // 남은 슬롯 확인
            guard canAddMore else {
                showMaxAttachmentAlert = true
                break
            }

            let result = AttachmentStorageManager.shared.saveDocument(from: url)

            switch result {
            case .success(let saveResult):
                // PDF 썸네일 생성
                let thumbnail = AttachmentStorageManager.shared.loadPDFThumbnail(fileName: saveResult.fileName)

                let pending = PendingAttachment(
                    type: .pdf,
                    thumbnail: thumbnail,
                    fileName: saveResult.fileName,
                    originalName: saveResult.originalName,
                    fileSize: saveResult.fileSize
                )
                pendingAttachments.append(pending)

            case .failure(let error):
                PrayerLogger.shared.dataOperationFailed("문서 저장", error: error)
            }
        }
    }

    private func removeAttachment(at index: Int) {
        guard index < attachments.count else { return }

        let attachment = attachments[index]
        // 파일 삭제
        AttachmentStorageManager.shared.deleteFile(fileName: attachment.fileName)
        attachments.remove(at: index)
    }

    private func removePendingAttachment(at index: Int) {
        guard index < pendingAttachments.count else { return }

        let pending = pendingAttachments[index]
        // 파일 삭제
        AttachmentStorageManager.shared.deleteFile(fileName: pending.fileName)
        pendingAttachments.remove(at: index)
    }

    private func extractTextFromAttachment(_ attachment: Attachment) {
        guard attachment.isImage,
              let image = AttachmentStorageManager.shared.loadImage(fileName: attachment.fileName) else {
            return
        }
        onExtractText?(image)
    }
}

// MARK: - Preview Provider

#Preview {
    VStack {
        // 빈 상태
        AttachmentGallerySection(
            pendingAttachments: .constant([]),
            readOnly: false
        )

        // 읽기 전용
        AttachmentGallerySection(
            readOnly: true
        )
    }
    .padding()
    .background(DesignSystem.Colors.background)
}
