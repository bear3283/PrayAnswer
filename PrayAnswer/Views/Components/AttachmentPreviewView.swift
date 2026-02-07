//
//  AttachmentPreviewView.swift
//  PrayAnswer
//
//  첨부 파일 전체화면 미리보기 뷰 - 이미지 줌, PDF 뷰어
//

import SwiftUI
import PDFKit

/// 첨부 파일 전체화면 미리보기
struct AttachmentPreviewView: View {
    let attachments: [Attachment]
    @Binding var selectedIndex: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                TabView(selection: $selectedIndex) {
                    ForEach(Array(attachments.enumerated()), id: \.element.fileName) { index, attachment in
                        AttachmentContentView(attachment: attachment)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }

                ToolbarItem(placement: .principal) {
                    if attachments.indices.contains(selectedIndex) {
                        Text(attachments[selectedIndex].originalName)
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if attachments.indices.contains(selectedIndex) {
                        ShareLink(item: shareURL(for: attachments[selectedIndex])) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .toolbarBackground(.black.opacity(0.8), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    private func shareURL(for attachment: Attachment) -> URL {
        AttachmentStorageManager.shared.fileURL(fileName: attachment.fileName) ?? URL(fileURLWithPath: "")
    }
}

/// 개별 첨부 파일 컨텐츠 뷰
struct AttachmentContentView: View {
    let attachment: Attachment
    @State private var image: UIImage?
    @State private var isLoading = true

    var body: some View {
        Group {
            if attachment.isImage {
                imageContentView
            } else if attachment.isPDF {
                pdfContentView
            }
        }
    }

    // MARK: - Image Content

    @ViewBuilder
    private var imageContentView: some View {
        if isLoading {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
        } else if let image = image {
            ZoomableImageView(image: image)
        } else {
            errorView
        }
    }

    // MARK: - PDF Content

    private var pdfContentView: some View {
        PDFKitView(fileName: attachment.fileName)
    }

    // MARK: - Error View

    private var errorView: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text(L.Image.errorLoadFailed)
                .font(DesignSystem.Typography.callout)
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Zoomable Image View

struct ZoomableImageView: UIViewRepresentable {
    let image: UIImage

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .clear

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.tag = 100
        scrollView.addSubview(imageView)

        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        guard let imageView = uiView.viewWithTag(100) as? UIImageView else { return }
        imageView.image = image

        // 이미지 크기에 맞게 imageView 프레임 설정
        imageView.frame = CGRect(origin: .zero, size: image.size)
        uiView.contentSize = image.size

        // 초기 줌 스케일 계산
        let widthScale = uiView.bounds.width / image.size.width
        let heightScale = uiView.bounds.height / image.size.height
        let minScale = min(widthScale, heightScale)

        uiView.minimumZoomScale = minScale
        uiView.zoomScale = minScale

        // 중앙 정렬
        centerImage(in: uiView, imageView: imageView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    private func centerImage(in scrollView: UIScrollView, imageView: UIImageView) {
        let boundsSize = scrollView.bounds.size
        var frameToCenter = imageView.frame

        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
        } else {
            frameToCenter.origin.x = 0
        }

        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
        } else {
            frameToCenter.origin.y = 0
        }

        imageView.frame = frameToCenter
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        let parent: ZoomableImageView

        init(_ parent: ZoomableImageView) {
            self.parent = parent
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            scrollView.viewWithTag(100)
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            guard let imageView = scrollView.viewWithTag(100) else { return }
            parent.centerImage(in: scrollView, imageView: imageView as! UIImageView)
        }
    }
}

// MARK: - PDF Kit View

struct PDFKitView: UIViewRepresentable {
    let fileName: String

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = .black

        if let url = AttachmentStorageManager.shared.documentURL(fileName: fileName),
           let document = PDFDocument(url: url) {
            pdfView.document = document
        }

        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        if uiView.document == nil {
            if let url = AttachmentStorageManager.shared.documentURL(fileName: fileName),
               let document = PDFDocument(url: url) {
                uiView.document = document
            }
        }
    }
}

// MARK: - Legacy Image Viewer (for single image)

/// 레거시 단일 이미지 뷰어 (imageFileName용)
struct LegacyImagePreviewView: View {
    let imageFileName: String
    @Environment(\.dismiss) private var dismiss
    @State private var image: UIImage?

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                if let image = image {
                    ZoomableImageView(image: image)
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if let url = ImageStorageManager.shared.imageURL(fileName: imageFileName) {
                        ShareLink(item: url) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .toolbarBackground(.black.opacity(0.8), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            image = ImageStorageManager.shared.loadImage(fileName: imageFileName)
        }
    }
}
