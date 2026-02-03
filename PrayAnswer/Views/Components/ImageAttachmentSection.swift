//
//  ImageAttachmentSection.swift
//  PrayAnswer
//
//  이미지 첨부 UI 컴포넌트 - PhotosPicker + 미리보기 + OCR 버튼
//

import SwiftUI
import PhotosUI

/// 이미지 첨부 섹션 뷰
/// PhotosPicker를 사용하여 이미지 선택, 미리보기 표시, OCR 텍스트 추출 기능 제공
struct ImageAttachmentSection: View {
    @Binding var selectedImage: UIImage?
    @Binding var imageFileName: String?
    let onExtractText: (UIImage) -> Void

    @State private var selectedItem: PhotosPickerItem?
    @State private var isLoadingImage = false

    var body: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                // 섹션 헤더
                HStack {
                    Label(L.Image.attachImage, systemImage: "photo")
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                        .fontWeight(.medium)

                    Spacer()

                    if selectedImage != nil {
                        // 이미지 삭제 버튼
                        Button(action: removeImage) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(DesignSystem.Colors.tertiaryText)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }

                if let image = selectedImage {
                    // 이미지 미리보기
                    imagePreviewView(image: image)
                } else {
                    // 이미지 선택 버튼
                    imagePickerButton
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }
    }

    // MARK: - Image Preview View

    @ViewBuilder
    private func imagePreviewView(image: UIImage) -> some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // 이미지 미리보기
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 200)
                .cornerRadius(DesignSystem.CornerRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                        .stroke(DesignSystem.Colors.primary.opacity(0.2), lineWidth: 1)
                )
                .accessibilityLabel(L.Image.accessibilityAttachedImage)

            // 액션 버튼들
            HStack(spacing: DesignSystem.Spacing.md) {
                // 이미지 변경 버튼
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: "photo.badge.arrow.down")
                            .font(.caption)
                        Text(L.Image.changeImage)
                            .font(DesignSystem.Typography.caption)
                    }
                    .foregroundColor(DesignSystem.Colors.primary)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                    .background(DesignSystem.Colors.primary.opacity(0.1))
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()

                // 텍스트 추출 버튼
                Button(action: {
                    onExtractText(image)
                }) {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: "text.viewfinder")
                            .font(.caption)
                        Text(L.Image.extractText)
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
                .accessibilityLabel(L.Image.accessibilityExtractText)
            }
        }
        .onChange(of: selectedItem) { oldValue, newValue in
            Task {
                await loadImage(from: newValue)
            }
        }
    }

    // MARK: - Image Picker Button

    private var imagePickerButton: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            VStack(spacing: DesignSystem.Spacing.md) {
                if isLoadingImage {
                    ProgressView()
                        .scaleEffect(1.2)
                } else {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 32))
                        .foregroundColor(DesignSystem.Colors.primary)

                    Text(L.Image.selectImage)
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.primary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(DesignSystem.Colors.primary.opacity(0.05))
            .cornerRadius(DesignSystem.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .stroke(DesignSystem.Colors.primary.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [8]))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(L.Image.accessibilitySelectImage)
        .onChange(of: selectedItem) { oldValue, newValue in
            Task {
                await loadImage(from: newValue)
            }
        }
    }

    // MARK: - Helper Methods

    private func loadImage(from item: PhotosPickerItem?) async {
        guard let item = item else { return }

        isLoadingImage = true
        defer { isLoadingImage = false }

        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    // 이전 이미지 파일 삭제
                    if let oldFileName = imageFileName {
                        ImageStorageManager.shared.deleteImage(fileName: oldFileName)
                    }

                    // 새 이미지 저장
                    let result = ImageStorageManager.shared.saveImage(uiImage)
                    switch result {
                    case .success(let fileName):
                        self.imageFileName = fileName
                        self.selectedImage = uiImage
                    case .failure:
                        // 저장 실패해도 메모리에는 이미지 유지
                        self.selectedImage = uiImage
                        self.imageFileName = nil
                    }

                    self.selectedItem = nil
                }
            }
        } catch {
            PrayerLogger.shared.dataOperationFailed("이미지 로드", error: error)
        }
    }

    private func removeImage() {
        // 저장된 이미지 파일 삭제
        if let fileName = imageFileName {
            ImageStorageManager.shared.deleteImage(fileName: fileName)
        }

        selectedImage = nil
        imageFileName = nil
        selectedItem = nil
    }
}
