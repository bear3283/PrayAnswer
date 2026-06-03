import Foundation
import Speech
import AVFoundation
import Accelerate

/// 음성 인식 관리자 - Speech Framework를 사용한 음성→텍스트 변환
/// 개선 사항: 블루투스 마이크 지원, 1분 자동 청킹, 오디오 레벨 미터, 일시정지/재개
@Observable
final class SpeechRecognitionManager: NSObject {
    static let shared = SpeechRecognitionManager()

    // MARK: - Observable Properties

    var recognizedText: String = ""
    var isRecording: Bool = false
    var isPaused: Bool = false
    var errorMessage: String?
    var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
    var microphonePermissionGranted: Bool = false

    /// 실시간 오디오 입력 레벨 (0.0 ~ 1.0) — 파형 시각화용
    var audioLevel: Float = 0.0

    /// 녹음 경과 시간 (초)
    var elapsedSeconds: Int = 0

    // MARK: - Private Properties

    private let speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    /// 청킹: 이전 청크에서 누적된 텍스트
    private var accumulatedText: String = ""

    /// 청킹 타이머 — 55초마다 새 recognitionRequest로 교체
    private var chunkTimer: Timer?
    private let chunkInterval: TimeInterval = 55

    /// 녹음 경과 시간 타이머
    private var elapsedTimer: Timer?

    /// 일시정지 시점의 누적 텍스트 스냅샷
    private var pauseSnapshot: String = ""

    // MARK: - Initialization

    private override init() {
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ko-KR"))
        super.init()
        self.speechRecognizer?.delegate = self
    }

    // MARK: - Permission Requests

    func requestSpeechAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.authorizationStatus = status
                completion(status == .authorized)
            }
        }
    }

    func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        AVAudioApplication.requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                self?.microphonePermissionGranted = granted
                completion(granted)
            }
        }
    }

    func requestAllPermissions(completion: @escaping (Bool) -> Void) {
        requestSpeechAuthorization { [weak self] speechGranted in
            guard speechGranted else { completion(false); return }
            self?.requestMicrophonePermission { micGranted in
                completion(micGranted)
            }
        }
    }

    func checkPermissions() -> Bool {
        authorizationStatus == .authorized && microphonePermissionGranted
    }

    // MARK: - Recording Control

    func startRecording() throws {
        guard !isRecording else { return }

        accumulatedText = ""
        elapsedSeconds = 0
        isPaused = false

        try startRecognitionSession()
        startElapsedTimer()
        startChunkTimer()

        DispatchQueue.main.async {
            self.isRecording = true
            self.errorMessage = nil
        }
    }

    func stopRecording() {
        stopChunkTimer()
        stopElapsedTimer()
        stopAudioEngine()
        recognitionRequest?.endAudio()

        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)

        DispatchQueue.main.async {
            self.isRecording = false
            self.isPaused = false
            self.audioLevel = 0
        }
    }

    func pauseRecording() {
        guard isRecording, !isPaused else { return }

        stopChunkTimer()
        stopElapsedTimer()

        // 현재 인식 중인 텍스트를 누적에 병합 후 스냅샷
        let current = recognizedText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !current.isEmpty {
            accumulatedText = accumulatedText.isEmpty ? current : accumulatedText + "\n" + current
        }
        pauseSnapshot = accumulatedText

        stopAudioEngine()
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil

        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)

        DispatchQueue.main.async {
            self.isPaused = true
            self.audioLevel = 0
            self.recognizedText = self.accumulatedText
        }
    }

    func resumeRecording() {
        guard isRecording, isPaused else { return }

        do {
            accumulatedText = pauseSnapshot
            try startRecognitionSession()
            startElapsedTimer()
            startChunkTimer()
            DispatchQueue.main.async {
                self.isPaused = false
                self.errorMessage = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = L.Voice.errorRecordingFailed
            }
        }
    }

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

    func togglePause() {
        if isPaused {
            resumeRecording()
        } else {
            pauseRecording()
        }
    }

    func clearText() {
        recognizedText = ""
        accumulatedText = ""
    }

    // MARK: - Private: Session Management

    private func startRecognitionSession() throws {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }

        let audioSession = AVAudioSession.sharedInstance()
        // 블루투스/에어팟 마이크(HFP) 지원 + 음성 최적화 모드 + 타 오디오 일시 감쇠.
        // 주의: .allowBluetoothA2DP는 .playAndRecord 카테고리에서만 유효하고
        //      A2DP는 출력 전용이라 녹음엔 무용 → 사용하지 않음.
        try audioSession.setCategory(
            .record,
            mode: .measurement,
            options: [.allowBluetooth, .duckOthers]
        )
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest else {
            throw SpeechRecognitionError.requestCreationFailed
        }
        recognitionRequest.shouldReportPartialResults = true

        // 자동 문장 부호 (iOS 16+): 마침표·쉼표 자동 삽입 → 기도문 가독성 향상
        recognitionRequest.addsPunctuation = UserDefaults.standard.bool(forKey: "autoPunctuation")

        // 받아쓰기 모드: 연속 구술 발화에 최적화 (기도 녹음 특성에 적합)
        recognitionRequest.taskHint = .dictation

        // 기기 내 인식: 사용자 설정에 따라 서버 전송 없이 처리
        recognitionRequest.requiresOnDeviceRecognition = UserDefaults.standard.bool(forKey: "onDeviceRecognition")

        // 기도 관련 한국어 어휘 힌트: 음성 인식 엔진이 이 단어들을 우선 인식
        recognitionRequest.contextualStrings = [
            "하나님", "예수님", "성령님", "아버지", "주님", "그리스도",
            "감사합니다", "간구합니다", "기도합니다", "용서해주세요",
            "축복해주세요", "인도해주세요", "치유해주세요", "도와주세요",
            "아멘", "할렐루야", "예수 그리스도", "성경", "말씀",
            "시편", "요한복음", "창세기", "십자가", "부활",
            "은혜", "평안", "회복", "구원", "믿음", "소망", "사랑",
            "교회", "성도", "찬양", "예배", "선교"
        ]

        guard let speechRecognizer, speechRecognizer.isAvailable else {
            throw SpeechRecognitionError.recognizerNotAvailable
        }

        let accumulated = accumulatedText

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self else { return }

            if let result {
                let chunk = result.bestTranscription.formattedString
                let full = accumulated.isEmpty ? chunk : accumulated + "\n" + chunk
                DispatchQueue.main.async {
                    self.recognizedText = full
                }

                if result.isFinal {
                    let finalChunk = result.bestTranscription.formattedString.trimmingCharacters(in: .whitespacesAndNewlines)
                    DispatchQueue.main.async {
                        self.accumulatedText = accumulated.isEmpty
                            ? finalChunk
                            : accumulated + "\n" + finalChunk
                    }
                }
            }

            if error != nil && !self.isPaused {
                if self.audioEngine.isRunning {
                    self.audioEngine.stop()
                    self.audioEngine.inputNode.removeTap(onBus: 0)
                }
                try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
                DispatchQueue.main.async {
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                    if !self.isRecording { return }
                    self.isRecording = false
                    self.audioLevel = 0
                }
            }
        }

        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
            self?.updateAudioLevel(buffer: buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
    }

    private func stopAudioEngine() {
        guard audioEngine.isRunning else { return }
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }

    // MARK: - Private: Chunking

    private func startChunkTimer() {
        chunkTimer?.invalidate()
        chunkTimer = Timer.scheduledTimer(withTimeInterval: chunkInterval, repeats: false) { [weak self] _ in
            self?.rotateChunk()
        }
    }

    private func stopChunkTimer() {
        chunkTimer?.invalidate()
        chunkTimer = nil
    }

    /// 55초 경과 시 현재 텍스트를 누적하고 새 인식 세션 시작 (무중단)
    private func rotateChunk() {
        guard isRecording, !isPaused else { return }

        // 현재 인식 중인 텍스트 누적
        let current = recognizedText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !current.isEmpty {
            accumulatedText = accumulatedText.isEmpty ? current : accumulatedText + "\n" + current
        }

        // 기존 세션 정리
        stopAudioEngine()
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil

        // 새 세션 즉시 시작
        do {
            try startRecognitionSession()
            startChunkTimer() // 다시 55초 타이머
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = L.Voice.errorRecordingFailed
            }
        }
    }

    // MARK: - Private: Elapsed Timer

    private func startElapsedTimer() {
        elapsedTimer?.invalidate()
        elapsedTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.elapsedSeconds += 1
            }
        }
    }

    private func stopElapsedTimer() {
        elapsedTimer?.invalidate()
        elapsedTimer = nil
    }

    // MARK: - Private: Audio Level Metering

    private func updateAudioLevel(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameCount = vDSP_Length(buffer.frameLength)
        guard frameCount > 0 else { return }

        var rms: Float = 0.0
        vDSP_rmsqv(channelData, 1, &rms, frameCount)

        // 로그 스케일 정규화: -50dB~-10dB → 0.0~1.0
        // 선형 스케일(×20)은 작은 소리에 과민·큰 소리에 클리핑 발생
        // 로그 스케일은 사람 청각 특성과 일치해 파형 시각화가 더 자연스러움
        let db = rms > 1e-7 ? 20.0 * log10(rms) : -140.0
        let normalized = min(1.0, max(0.0, (db + 50.0) / 40.0))

        DispatchQueue.main.async {
            self.audioLevel = normalized
        }
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
        case .requestCreationFailed:   return L.Voice.errorRequestFailed
        case .recognizerNotAvailable:  return L.Voice.errorRecognizerUnavailable
        case .permissionDenied:        return L.Voice.errorPermissionDenied
        case .audioSessionFailed:      return L.Voice.errorAudioSession
        }
    }
}
