//
//  ImageTextRecognizer.swift
//  PrayAnswer
//
//  Vision OCR을 사용한 이미지 텍스트 인식
//

import Foundation
import UIKit
import Vision

/// OCR 관련 에러 타입
enum OCRError: Error, LocalizedError {
    case invalidImage
    case recognitionFailed
    case noTextFound

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return L.Image.errorInvalidImage
        case .recognitionFailed:
            return L.Image.errorOCRFailed
        case .noTextFound:
            return L.Image.errorNoTextFound
        }
    }
}

/// 이미지 텍스트 인식기 - Vision Framework 사용
@Observable
final class ImageTextRecognizer {
    static let shared = ImageTextRecognizer()

    // MARK: - Properties

    /// 처리 중 여부
    var isProcessing: Bool = false

    /// 에러 메시지
    var errorMessage: String?

    /// 마지막 인식 결과
    var lastRecognizedText: String = ""

    // MARK: - Initialization

    private init() {}

    // MARK: - Public Methods

    /// 이미지에서 텍스트 추출 (async/await)
    /// - Parameter image: 텍스트를 추출할 UIImage
    /// - Returns: 추출된 텍스트
    func recognizeText(from image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw OCRError.invalidImage
        }

        await MainActor.run {
            isProcessing = true
            errorMessage = nil
        }

        defer {
            Task { @MainActor in
                isProcessing = false
            }
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { [weak self] request, error in
                if let error = error {
                    Task { @MainActor in
                        self?.errorMessage = L.Image.errorOCRFailed
                    }
                    continuation.resume(throwing: OCRError.recognitionFailed)
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    Task { @MainActor in
                        self?.errorMessage = L.Image.errorNoTextFound
                    }
                    continuation.resume(throwing: OCRError.noTextFound)
                    return
                }

                // 인식된 텍스트 추출
                let recognizedStrings = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }

                let resultText = recognizedStrings.joined(separator: "\n")

                if resultText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Task { @MainActor in
                        self?.errorMessage = L.Image.errorNoTextFound
                    }
                    continuation.resume(throwing: OCRError.noTextFound)
                    return
                }

                Task { @MainActor in
                    self?.lastRecognizedText = resultText
                }

                continuation.resume(returning: resultText)
            }

            // 한국어 우선, 영어 지원
            request.recognitionLanguages = ["ko-KR", "en-US"]
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            do {
                try handler.perform([request])
            } catch {
                Task { @MainActor in
                    self.errorMessage = L.Image.errorOCRFailed
                }
                continuation.resume(throwing: OCRError.recognitionFailed)
            }
        }
    }

    /// 마지막 결과 초기화
    func clearResult() {
        lastRecognizedText = ""
        errorMessage = nil
    }
}
