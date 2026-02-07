import Foundation
import Speech
import AVFoundation

/// 음성 인식 관리자 - Speech Framework를 사용한 음성→텍스트 변환
@Observable
final class SpeechRecognitionManager: NSObject {
    static let shared = SpeechRecognitionManager()

    // MARK: - Published Properties

    /// 현재 인식된 텍스트
    var recognizedText: String = ""

    /// 녹음 중 여부
    var isRecording: Bool = false

    /// 에러 메시지
    var errorMessage: String?

    /// 권한 상태
    var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined

    /// 마이크 권한 상태
    var microphonePermissionGranted: Bool = false

    // MARK: - Private Properties

    private let speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    // MARK: - Initialization

    private override init() {
        // 한국어 음성 인식기 초기화
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ko-KR"))
        super.init()
        self.speechRecognizer?.delegate = self
    }

    // MARK: - Permission Requests

    /// 음성 인식 권한 요청
    func requestSpeechAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.authorizationStatus = status
                completion(status == .authorized)
            }
        }
    }

    /// 마이크 권한 요청
    func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        AVAudioApplication.requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                self?.microphonePermissionGranted = granted
                completion(granted)
            }
        }
    }

    /// 모든 권한 요청
    func requestAllPermissions(completion: @escaping (Bool) -> Void) {
        requestSpeechAuthorization { [weak self] speechGranted in
            guard speechGranted else {
                completion(false)
                return
            }

            self?.requestMicrophonePermission { micGranted in
                completion(micGranted)
            }
        }
    }

    /// 권한 상태 확인
    func checkPermissions() -> Bool {
        return authorizationStatus == .authorized && microphonePermissionGranted
    }

    // MARK: - Recording Control

    /// 녹음 시작
    func startRecording() throws {
        // 이전 작업 정리
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }

        // 오디오 세션 설정
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        // 인식 요청 생성
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        guard let recognitionRequest = recognitionRequest else {
            throw SpeechRecognitionError.requestCreationFailed
        }

        // 실시간 결과 반환 설정
        recognitionRequest.shouldReportPartialResults = true

        // 음성 인식기 확인
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            throw SpeechRecognitionError.recognizerNotAvailable
        }

        // 인식 작업 시작
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }

            var isFinal = false

            if let result = result {
                DispatchQueue.main.async {
                    self.recognizedText = result.bestTranscription.formattedString
                }
                isFinal = result.isFinal
            }

            // 에러 또는 최종 결과일 때 정리
            if error != nil || isFinal {
                // 인식 완료 후 리소스 정리
                self.recognitionRequest = nil
                self.recognitionTask = nil

                // 오디오 엔진이 아직 실행 중이면 중지
                if self.audioEngine.isRunning {
                    self.audioEngine.stop()
                    self.audioEngine.inputNode.removeTap(onBus: 0)
                }

                try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)

                DispatchQueue.main.async {
                    self.isRecording = false
                }
            }
        }

        // 오디오 입력 노드 설정
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        // 오디오 엔진 시작
        audioEngine.prepare()
        try audioEngine.start()

        DispatchQueue.main.async {
            self.isRecording = true
            self.errorMessage = nil
        }
    }

    /// 녹음 중지
    func stopRecording() {
        stopRecordingInternal()
    }

    private func stopRecordingInternal() {
        // 이미 중지 상태면 무시
        guard audioEngine.isRunning || recognitionRequest != nil else {
            DispatchQueue.main.async {
                self.isRecording = false
            }
            return
        }

        // 오디오 엔진 중지
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        // 인식 요청 종료 (최종 결과를 받기 위해 endAudio만 호출)
        recognitionRequest?.endAudio()

        // 오디오 세션 비활성화
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)

        DispatchQueue.main.async {
            self.isRecording = false
        }

        // 인식 작업은 취소하지 않음 - 자연스럽게 완료되도록 함
        // recognitionTask가 완료되면 콜백에서 정리됨
    }

    /// 녹음 토글
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            do {
                try startRecording()
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = L.Voice.errorRecordingFailed
                }
            }
        }
    }

    /// 텍스트 초기화
    func clearText() {
        recognizedText = ""
    }
}

// MARK: - SFSpeechRecognizerDelegate

extension SpeechRecognitionManager: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if !available {
            DispatchQueue.main.async {
                self.errorMessage = L.Voice.errorRecognizerUnavailable
            }
        }
    }
}

// MARK: - Error Types

enum SpeechRecognitionError: Error, LocalizedError {
    case requestCreationFailed
    case recognizerNotAvailable
    case permissionDenied
    case audioSessionFailed

    var errorDescription: String? {
        switch self {
        case .requestCreationFailed:
            return L.Voice.errorRequestFailed
        case .recognizerNotAvailable:
            return L.Voice.errorRecognizerUnavailable
        case .permissionDenied:
            return L.Voice.errorPermissionDenied
        case .audioSessionFailed:
            return L.Voice.errorAudioSession
        }
    }
}
