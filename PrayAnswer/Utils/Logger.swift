import Foundation
import os.log

// MARK: - Prayer Logger

class PrayerLogger {
    static let shared = PrayerLogger()
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "PrayAnswer", category: "PrayerApp")
    
    private init() {}
    
    // MARK: - Success Logging
    
    func logSuccess(_ message: String, category: LogCategory = .general) {
        logger.info("✅ [\(category.rawValue)] \(message)")
    }
    
    // MARK: - Error Logging
    
    func logError(_ error: Error, context: String = "", category: LogCategory = .general) {
        let errorMessage = "❌ [\(category.rawValue)] \(context): \(error.localizedDescription)"
        logger.error("\(errorMessage)")
    }
    
    func logError(_ message: String, category: LogCategory = .general) {
        logger.error("❌ [\(category.rawValue)] \(message)")
    }
    
    // MARK: - Warning Logging
    
    func logWarning(_ message: String, category: LogCategory = .general) {
        logger.warning("⚠️ [\(category.rawValue)] \(message)")
    }
    
    // MARK: - Info Logging
    
    func logInfo(_ message: String, category: LogCategory = .general) {
        logger.info("ℹ️ [\(category.rawValue)] \(message)")
    }
    
    // MARK: - Debug Logging
    
    func logDebug(_ message: String, category: LogCategory = .general) {
        #if DEBUG
        logger.debug("🔍 [\(category.rawValue)] \(message)")
        #endif
    }
}

// MARK: - Log Categories

enum LogCategory: String, CaseIterable {
    case general = "General"
    case prayer = "Prayer"
    case storage = "Storage"
    case ui = "UI"
    case data = "Data"
    case network = "Network"
    case user = "User"
}

// MARK: - Convenient Extensions

extension PrayerLogger {
    
    // Prayer 관련 로깅
    func prayerCreated(title: String) {
        logSuccess("기도 생성: '\(title)'", category: .prayer)
    }
    
    func prayerUpdated(title: String) {
        logSuccess("기도 수정: '\(title)'", category: .prayer)
    }
    
    func prayerDeleted(title: String) {
        logSuccess("기도 삭제: '\(title)'", category: .prayer)
    }
    
    func prayerMoved(title: String, to storage: PrayerStorage) {
        logSuccess("기도 이동: '\(title)' → \(storage.displayName)", category: .storage)
    }
    
    // 에러 관련 로깅
    func prayerOperationFailed(_ operation: String, error: Error) {
        logError(error, context: "기도 \(operation) 실패", category: .prayer)
    }
    
    func dataOperationFailed(_ operation: String, error: Error) {
        logError(error, context: "데이터 \(operation) 실패", category: .data)
    }
    
    // UI 관련 로깅
    func viewDidAppear(_ viewName: String) {
        logDebug("뷰 표시: \(viewName)", category: .ui)
    }
    
    func userAction(_ action: String) {
        logInfo("사용자 액션: \(action)", category: .user)
    }
}

// MARK: - Error Handling Extension

extension PrayerLogger {
    
    func handleDataError(_ error: Error, operation: String) -> String {
        let userFriendlyMessage: String
        
        if let error = error as? CocoaError {
            switch error.code {
            case .validationMissingMandatoryProperty:
                userFriendlyMessage = "필수 정보가 누락되었습니다."
            case .validationMultipleErrors:
                userFriendlyMessage = "입력 정보에 오류가 있습니다."
            default:
                userFriendlyMessage = "데이터 처리 중 오류가 발생했습니다."
            }
        } else {
            userFriendlyMessage = "작업을 완료할 수 없습니다. 다시 시도해주세요."
        }
        
        dataOperationFailed(operation, error: error)
        return userFriendlyMessage
    }
}

// MARK: - Performance Measurement

extension PrayerLogger {
    
    func measurePerformance<T>(of operation: String, category: LogCategory = .general, _ block: () throws -> T) rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try block()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        logDebug("성능 측정 - \(operation): \(String(format: "%.4f", timeElapsed))초", category: category)
        return result
    }
}

// MARK: - Memory Usage Logging

extension PrayerLogger {
    
    func logMemoryUsage() {
        #if DEBUG
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            var info = mach_task_basic_info()
            var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
            
            let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
                $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                    task_info(mach_task_self_,
                             task_flavor_t(MACH_TASK_BASIC_INFO),
                             $0,
                             &count)
                }
            }
            
            if kerr == KERN_SUCCESS {
                let usedMB = Float(info.resident_size) / 1024.0 / 1024.0
                self.logDebug("메모리 사용량: \(String(format: "%.2f", usedMB)) MB", category: .general)
            }
        }
        #endif
    }
} 