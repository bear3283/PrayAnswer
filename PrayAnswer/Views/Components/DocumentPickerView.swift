//
//  DocumentPickerView.swift
//  PrayAnswer
//
//  UIDocumentPicker를 SwiftUI에서 사용하기 위한 래퍼
//

import SwiftUI
import UniformTypeIdentifiers

/// 문서 선택 결과
struct DocumentPickerResult: Identifiable {
    let id = UUID()
    let url: URL
    let fileName: String
}

/// 문서 선택기 뷰 (UIKit 래퍼)
struct DocumentPickerView: UIViewControllerRepresentable {
    let allowedTypes: [UTType]
    let allowsMultipleSelection: Bool
    let onPick: ([URL]) -> Void
    let onCancel: () -> Void

    init(
        allowedTypes: [UTType] = [.pdf],
        allowsMultipleSelection: Bool = true,
        onPick: @escaping ([URL]) -> Void,
        onCancel: @escaping () -> Void = {}
    ) {
        self.allowedTypes = allowedTypes
        self.allowsMultipleSelection = allowsMultipleSelection
        self.onPick = onPick
        self.onCancel = onCancel
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedTypes)
        picker.allowsMultipleSelection = allowsMultipleSelection
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPickerView

        init(_ parent: DocumentPickerView) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.onPick(urls)
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.onCancel()
        }
    }
}

/// 문서 선택기 시트 뷰
struct DocumentPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onPick: ([URL]) -> Void

    var body: some View {
        DocumentPickerView(
            allowedTypes: [.pdf],
            allowsMultipleSelection: true,
            onPick: { urls in
                onPick(urls)
                dismiss()
            },
            onCancel: {
                dismiss()
            }
        )
    }
}
