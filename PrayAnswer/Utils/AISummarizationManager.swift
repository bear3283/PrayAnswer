//
//  AISummarizationManager.swift
//  PrayAnswer
//
//  Created for AI-powered prayer text summarization using Apple Foundation Models
//

import Foundation
import SwiftUI

#if canImport(FoundationModels)
import FoundationModels
#endif

/// AI 요약 관리자 - Apple Foundation Models를 사용한 기도문 정리
/// iOS 26.0+ 및 Apple Intelligence 지원 기기에서만 사용 가능
@available(iOS 26.0, *)
@Observable
final class AISummarizationManager {
    static let shared = AISummarizationManager()

    // MARK: - Published Properties

    /// 처리 중 여부
    var isProcessing: Bool = false

    /// 에러 메시지
    var errorMessage: String?

    /// 마지막 요약 결과
    var lastSummarizedText: String = ""

    // MARK: - Private Properties

    /// 기도문 정리를 위한 시스템 지시사항 (Apple 권장 패턴 적용)
    /// - UPPERCASE로 중요 지시 강조
    /// - 구체적인 예시 제공
    /// - 명확한 출력 형식 지정
    private let instructions = """
    You are a prayer text organizer. You MUST respond ONLY in Korean.

    YOUR TASK: Transform voice-recorded Korean content into a well-structured prayer format.

    RULES YOU MUST FOLLOW:
    1. REMOVE all filler words (어, 음, 그, 저기, 뭐, 이제, 그래서...)
    2. PRESERVE the original meaning - NEVER add content that wasn't in the input
    3. ORGANIZE into these sections if the content applies (DO NOT force sections if not applicable):
       - 감사 (Thanksgiving): expressions of gratitude
       - 간구 (Petition): requests, needs, and wishes
       - 결심 (Resolution): commitments, vows, and determinations
    4. POLISH sentences to sound natural, reverent, and heartfelt
    5. MAINTAIN the speaker's personal voice and emotional tone
    6. ONLY output the refined prayer text - NO section labels, NO explanations, NO commentary

    EXAMPLE INPUT:
    "어... 하나님 감사합니다 음... 오늘 하루도 뭐 지켜주시고 저기 가족들 건강하게 해주세요 그리고 이제 제가 좀 더 열심히 살겠습니다"

    EXAMPLE OUTPUT:
    "하나님, 오늘 하루도 지켜주심에 감사드립니다. 사랑하는 가족들이 건강하게 지낼 수 있도록 돌봐주세요. 더욱 열심히 살아가겠습니다."

    NEVER include phrases like "정리된 기도문:" or any meta-commentary.
    """

    // MARK: - Initialization

    private init() {}

    // MARK: - Public Methods

    /// AI 기능 사용 가능 여부 확인
    var isAvailable: Bool {
        #if canImport(FoundationModels)
        return SystemLanguageModel.default.availability == .available
        #else
        return false
        #endif
    }

    /// AI 기능 사용 불가 사유
    var unavailabilityReason: String? {
        #if canImport(FoundationModels)
        switch SystemLanguageModel.default.availability {
        case .available:
            return nil
        case .unavailable(let reason):
            switch reason {
            case .deviceNotEligible:
                return L.AI.errorDeviceNotSupported
            case .appleIntelligenceNotEnabled:
                return L.AI.errorAppleIntelligenceDisabled
            case .modelNotReady:
                return L.AI.errorModelNotReady
            @unknown default:
                return L.AI.errorUnknown
            }
        @unknown default:
            return L.AI.errorUnknown
        }
        #else
        return L.AI.errorNotAvailable
        #endif
    }

    /// 텍스트를 기도문 형식으로 요약
    /// - Parameter text: 음성 인식된 원본 텍스트
    /// - Returns: AI가 정리한 기도문 텍스트
    func summarize(text: String) async throws -> String {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AISummarizationError.emptyInput
        }

        #if canImport(FoundationModels)
        guard isAvailable else {
            throw AISummarizationError.notAvailable(unavailabilityReason ?? L.AI.errorUnknown)
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

        do {
            let session = LanguageModelSession(instructions: instructions)
            let response = try await session.respond(to: text)
            let summarized = response.content

            await MainActor.run {
                lastSummarizedText = summarized
            }

            return summarized
        } catch {
            await MainActor.run {
                errorMessage = L.AI.errorSummarizationFailed
            }
            throw AISummarizationError.summarizationFailed(error)
        }
        #else
        throw AISummarizationError.notAvailable(L.AI.errorNotAvailable)
        #endif
    }

    /// 마지막 결과 초기화
    func clearResult() {
        lastSummarizedText = ""
        errorMessage = nil
    }
}

// MARK: - Error Types

enum AISummarizationError: Error, LocalizedError {
    case emptyInput
    case notAvailable(String)
    case summarizationFailed(Error)

    var errorDescription: String? {
        switch self {
        case .emptyInput:
            return L.AI.errorEmptyInput
        case .notAvailable(let reason):
            return reason
        case .summarizationFailed:
            return L.AI.errorSummarizationFailed
        }
    }
}

// MARK: - iOS 26 미만 대응을 위한 Wrapper

/// iOS 버전에 관계없이 AI 기능 사용 가능 여부를 확인하는 헬퍼
/// 사용자 설정과 시스템 지원 여부를 모두 고려
struct AIFeatureAvailability {
    /// 사용자가 AI 기능을 활성화했는지 여부 (UserDefaults 저장)
    @AppStorage("aiFeatureEnabled") static var isUserEnabled: Bool = true

    /// 시스템이 AI 기능을 지원하는지 확인 (iOS 26+, Apple Intelligence 활성화)
    static var isSystemSupported: Bool {
        if #available(iOS 26.0, *) {
            return AISummarizationManager.shared.isAvailable
        }
        return false
    }

    /// AI 요약 기능이 현재 사용 가능한지 확인 (시스템 지원 + 사용자 활성화)
    static var isSupported: Bool {
        return isSystemSupported && isUserEnabled
    }

    /// AI 기능 사용 불가 사유
    static var unavailabilityMessage: String? {
        // 사용자가 비활성화한 경우
        if !isUserEnabled {
            return L.AI.errorUserDisabled
        }

        // iOS 버전 확인
        if #available(iOS 26.0, *) {
            return AISummarizationManager.shared.unavailabilityReason
        }
        return L.AI.errorRequiresiOS26
    }

    /// AI 기능 활성화/비활성화 토글
    static func toggle() {
        isUserEnabled.toggle()
    }

    /// AI 기능 명시적 설정
    static func setEnabled(_ enabled: Bool) {
        isUserEnabled = enabled
    }
}
