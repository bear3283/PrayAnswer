# PrayAnswer 개발 로드맵

> 작성일: 2025-01-25
> 브랜치: feature/ux-improvements

## 개요

PrayAnswer 앱의 추가 기능 개발 계획서입니다.

### 개발 예정 기능
1. **Phase 1**: 알람 세부설정 (날짜, 시간, 반복 횟수 커스터마이징)
2. **Phase 2**: D-Day 캘린더 연동 (iOS 캘린더 앱에 이벤트 추가)
3. **Phase 3**: AI 음성 요약 (Apple Foundation Models 활용) - iOS 26+ 필요

---

## 현재 상태 분석

### 기존 구현 현황

| 기능 | 상태 | 구현 파일 | 설명 |
|------|------|----------|------|
| D-Day 알림 | ✅ 완료 | `NotificationManager.swift` | D-7, D-3, D-1, D-Day 고정 알림 (오전 9시) |
| D-Day 추적 | ✅ 완료 | `Prayer.swift` | targetDate 속성, 앱 내부 저장만 |
| 음성 녹음 | ✅ 완료 | `SpeechRecognitionManager.swift` | 실시간 Speech-to-Text (한국어) |
| 위젯 | ✅ 완료 | `WidgetDataManager.swift` | 즐겨찾기 기도 표시 |

### 기술 스택
- **UI**: SwiftUI
- **데이터**: SwiftData
- **알림**: UserNotifications
- **음성**: Speech Framework, AVFoundation
- **위젯**: WidgetKit + App Groups

---

## Phase 1: 알람 세부설정 기능

### 목표
사용자가 알림 날짜, 시간, 반복 횟수를 자유롭게 설정할 수 있도록 개선

### 현재 한계
- 알림 일정 고정: D-7, D-3, D-1, D-Day
- 알림 시간 고정: 오전 9시
- 반복 알림 미지원

### 구현 항목

#### 1.1 NotificationSettings 모델 추가
```swift
// 새 파일: Models/NotificationSettings.swift
struct NotificationSettings: Codable {
    var isEnabled: Bool = false
    var notificationTime: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0))!
    var reminderDays: [Int] = [7, 3, 1, 0]  // D-n일 목록
    var repeatType: RepeatType = .none
    var repeatCount: Int? = nil

    enum RepeatType: String, Codable, CaseIterable {
        case none = "없음"
        case daily = "매일"
        case weekly = "매주"
        case custom = "사용자 지정"
    }
}
```

#### 1.2 Prayer 모델 확장
```swift
// Prayer.swift에 추가
var notificationSettingsData: Data?  // NotificationSettings JSON 저장

var notificationSettings: NotificationSettings {
    get {
        guard let data = notificationSettingsData else { return NotificationSettings() }
        return (try? JSONDecoder().decode(NotificationSettings.self, from: data)) ?? NotificationSettings()
    }
    set {
        notificationSettingsData = try? JSONEncoder().encode(newValue)
    }
}
```

#### 1.3 NotificationSettingsView 화면 생성
```swift
// 새 파일: Views/NotificationSettingsView.swift
struct NotificationSettingsView: View {
    @Binding var settings: NotificationSettings

    var body: some View {
        Form {
            // 알림 활성화 토글
            Section("알림 설정") {
                Toggle("알림 받기", isOn: $settings.isEnabled)
            }

            // 알림 시간 선택
            Section("알림 시간") {
                DatePicker("시간", selection: $settings.notificationTime, displayedComponents: .hourAndMinute)
            }

            // D-n일 선택 (멀티 선택)
            Section("알림 일정") {
                // D-30 ~ D-Day 체크박스
            }

            // 반복 설정
            Section("반복") {
                Picker("반복 유형", selection: $settings.repeatType) { ... }
            }
        }
    }
}
```

#### 1.4 NotificationManager 확장
```swift
// NotificationManager.swift 수정
func scheduleCustomNotifications(for prayer: Prayer) {
    let settings = prayer.notificationSettings
    guard settings.isEnabled, let targetDate = prayer.targetDate else { return }

    cancelNotifications(for: prayer)

    for daysBefore in settings.reminderDays {
        // 커스텀 시간으로 알림 생성
        scheduleNotification(
            for: prayer,
            daysBefore: daysBefore,
            time: settings.notificationTime
        )
    }

    // 반복 알림 처리
    if settings.repeatType != .none {
        scheduleRepeatingNotifications(for: prayer, settings: settings)
    }
}
```

#### 1.5 UI 통합
- `AddPrayerView`: 알림 설정 섹션에 "세부 설정" 버튼 추가
- `PrayerDetailView`: 알림 설정 편집 기능 추가

### 파일 변경 목록
| 파일 | 작업 |
|------|------|
| `Models/NotificationSettings.swift` | 🆕 새로 생성 |
| `Models/Prayer.swift` | 📝 notificationSettings 속성 추가 |
| `Views/NotificationSettingsView.swift` | 🆕 새로 생성 |
| `Utils/NotificationManager.swift` | 📝 커스텀 스케줄링 로직 추가 |
| `Views/AddPrayerView.swift` | 📝 세부 설정 버튼 추가 |
| `Views/PrayerDetailView.swift` | 📝 알림 설정 편집 UI 추가 |
| `Utils/LocalizationKeys.swift` | 📝 새 로컬라이제이션 키 추가 |

---

## Phase 2: D-Day 캘린더 연동

### 목표
D-Day를 iOS 캘린더 앱에 이벤트로 추가하여 시스템 캘린더와 통합

### 필요 프레임워크
- **EventKit**: 캘린더 접근 및 이벤트 생성
- **EventKitUI** (선택): 네이티브 이벤트 편집 UI

### 구현 항목

#### 2.1 CalendarManager 유틸리티 생성
```swift
// 새 파일: Utils/CalendarManager.swift
import EventKit

final class CalendarManager {
    static let shared = CalendarManager()
    private let eventStore = EKEventStore()

    // MARK: - Permission
    func requestAccess() async -> Bool {
        do {
            return try await eventStore.requestFullAccessToEvents()
        } catch {
            return false
        }
    }

    // MARK: - Calendar Operations
    func availableCalendars() -> [EKCalendar] {
        return eventStore.calendars(for: .event)
    }

    // MARK: - Event Operations
    func addEvent(for prayer: Prayer, to calendar: EKCalendar) throws -> String {
        let event = EKEvent(eventStore: eventStore)
        event.title = "🙏 \(prayer.title)"
        event.notes = prayer.content
        event.startDate = prayer.targetDate
        event.endDate = prayer.targetDate
        event.isAllDay = true
        event.calendar = calendar

        // 알림 추가 (D-1, D-Day)
        event.addAlarm(EKAlarm(relativeOffset: -86400)) // 1일 전
        event.addAlarm(EKAlarm(relativeOffset: 0))       // 당일

        try eventStore.save(event, span: .thisEvent)
        return event.eventIdentifier
    }

    func removeEvent(identifier: String) throws { ... }
    func updateEvent(identifier: String, with prayer: Prayer) throws { ... }
}
```

#### 2.2 Prayer 모델 확장
```swift
// Prayer.swift에 추가
var calendarEventIdentifier: String?  // 캘린더 이벤트 ID 저장
var isAddedToCalendar: Bool { calendarEventIdentifier != nil }
```

#### 2.3 Info.plist 권한 추가
```xml
<key>NSCalendarsFullAccessUsageDescription</key>
<string>D-Day를 캘린더에 추가하기 위해 캘린더 접근 권한이 필요합니다.</string>
```

#### 2.4 CalendarPickerView 생성
```swift
// 새 파일: Views/Components/CalendarPickerView.swift
struct CalendarPickerView: View {
    @State private var calendars: [EKCalendar] = []
    @State private var selectedCalendar: EKCalendar?
    var onSelect: (EKCalendar) -> Void

    var body: some View {
        List(calendars, id: \.calendarIdentifier) { calendar in
            Button {
                onSelect(calendar)
            } label: {
                HStack {
                    Circle().fill(Color(cgColor: calendar.cgColor)).frame(width: 12)
                    Text(calendar.title)
                }
            }
        }
    }
}
```

#### 2.5 PrayerDetailView 통합
```swift
// PrayerDetailView.swift에 추가
Button {
    showCalendarPicker = true
} label: {
    Label(
        prayer.isAddedToCalendar ? "캘린더에서 보기" : "캘린더에 추가",
        systemImage: "calendar.badge.plus"
    )
}
.sheet(isPresented: $showCalendarPicker) {
    CalendarPickerView { calendar in
        addToCalendar(calendar: calendar)
    }
}
```

### 파일 변경 목록
| 파일 | 작업 |
|------|------|
| `Utils/CalendarManager.swift` | 🆕 새로 생성 |
| `Models/Prayer.swift` | 📝 calendarEventIdentifier 추가 |
| `Views/Components/CalendarPickerView.swift` | 🆕 새로 생성 |
| `Views/PrayerDetailView.swift` | 📝 캘린더 추가 버튼 |
| `Info.plist` | 📝 캘린더 권한 설명 추가 |
| `Utils/LocalizationKeys.swift` | 📝 새 로컬라이제이션 키 |

---

## Phase 3: AI 음성 요약 (Apple Foundation Models)

### ⚠️ 중요 요구사항
```
🔴 iOS 26.0+ 필요 (2025년 가을 출시 예정)
🔴 Apple Intelligence 지원 기기: A17 Pro, M1 이상
🔴 현재(2025년 1월) 개발 불가 - iOS 26 베타 출시 후 진행
```

### 목표
음성으로 녹음한 내용을 AI가 기도문 형식으로 자동 정리

### 기술 스택
- **Foundation Models Framework**: 온디바이스 LLM
- **LanguageModelSession**: 텍스트 생성 API

### 구현 항목 (iOS 26 출시 후)

#### 3.1 AISummarizationManager 생성
```swift
// 새 파일: Utils/AISummarizationManager.swift
import FoundationModels

@available(iOS 26.0, *)
final class AISummarizationManager {
    static let shared = AISummarizationManager()

    private let instructions = """
    다음 음성 녹음 내용을 기도문으로 정리해주세요:
    1. 핵심 기도 내용을 추출합니다
    2. 불필요한 말(어, 음, 그...)을 제거합니다
    3. 문장을 자연스럽게 다듬습니다
    4. 기도문 형식으로 구성합니다 (감사/간구/결심)
    """

    var isAvailable: Bool {
        SystemLanguageModel.default.availability == .available
    }

    func summarize(text: String) async throws -> String {
        let session = LanguageModelSession(instructions: instructions)
        let response = try await session.respond(to: text)
        return response.content
    }
}
```

#### 3.2 VoiceRecordingOverlay 확장
```swift
// AddPrayerView.swift의 VoiceRecordingOverlay 수정
if #available(iOS 26.0, *), AISummarizationManager.shared.isAvailable {
    Button("AI로 정리하기") {
        Task {
            isProcessing = true
            let summarized = try await AISummarizationManager.shared.summarize(text: recognizedText)
            showSummaryPreview = true
            summarizedText = summarized
            isProcessing = false
        }
    }
}
```

#### 3.3 요약 결과 미리보기 UI
```swift
// 새 파일: Views/Components/AISummaryPreviewView.swift
struct AISummaryPreviewView: View {
    let originalText: String
    @Binding var summarizedText: String
    var onApply: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack {
            Text("AI 정리 결과").font(.headline)

            // 원본 vs 요약 비교
            HStack {
                VStack { Text("원본"); Text(originalText) }
                VStack { Text("정리됨"); TextEditor(text: $summarizedText) }
            }

            HStack {
                Button("취소", action: onCancel)
                Button("적용", action: onApply)
            }
        }
    }
}
```

### iOS 26 미만 대응
```swift
// 기능 비활성화 또는 안내 메시지 표시
if #unavailable(iOS 26.0) {
    Text("AI 정리 기능은 iOS 26 이상에서 사용 가능합니다")
        .foregroundColor(.secondary)
}
```

### 파일 변경 목록 (iOS 26 출시 후)
| 파일 | 작업 |
|------|------|
| `Utils/AISummarizationManager.swift` | 🆕 새로 생성 |
| `Views/Components/AISummaryPreviewView.swift` | 🆕 새로 생성 |
| `Views/AddPrayerView.swift` | 📝 AI 정리 버튼 추가 |
| `Utils/LocalizationKeys.swift` | 📝 새 로컬라이제이션 키 |

---

## 개발 일정

```
┌────────────────────────────────────────────────────────────────┐
│  Phase 1: 알람 세부설정                                         │
│  ├─ 예상 소요: 2-3일                                           │
│  ├─ 난이도: ⭐⭐☆☆☆                                           │
│  └─ 상태: ✅ 완료 (2025-01-25)                                 │
├────────────────────────────────────────────────────────────────┤
│  Phase 2: 캘린더 연동                                          │
│  ├─ 예상 소요: 2-3일                                           │
│  ├─ 난이도: ⭐⭐⭐☆☆                                          │
│  └─ 상태: ✅ 완료 (2025-01-25)                                 │
├────────────────────────────────────────────────────────────────┤
│  Phase 3: AI 음성 요약                                         │
│  ├─ 예상 소요: 3-4일                                           │
│  ├─ 난이도: ⭐⭐⭐⭐☆                                         │
│  └─ 상태: ✅ 완료 (2025-01-26) - iOS 26+ 조건부 컴파일 적용    │
└────────────────────────────────────────────────────────────────┘
```

---

## 테스트 체크리스트

### Phase 1 테스트
- [ ] 알림 시간 변경 후 정상 발송 확인
- [ ] 커스텀 D-n일 설정 동작 확인
- [ ] 반복 알림 정상 동작 확인
- [ ] 기존 알림 설정과의 호환성

### Phase 2 테스트
- [ ] 캘린더 권한 요청 정상 동작
- [ ] 이벤트 생성/수정/삭제 확인
- [ ] 여러 캘린더에 추가 테스트
- [ ] 기도 삭제 시 캘린더 이벤트 삭제

### Phase 3 테스트
- [ ] AI 모델 가용성 체크
- [ ] 요약 품질 검증 (한국어)
- [ ] iOS 26 미만 기기 대응
- [ ] 오프라인 상태 처리

---

## 참고 문서

- [Apple Foundation Models Documentation](https://developer.apple.com/documentation/foundationmodels)
- [EventKit Framework](https://developer.apple.com/documentation/eventkit)
- [UserNotifications Framework](https://developer.apple.com/documentation/usernotifications)
- [Speech Framework](https://developer.apple.com/documentation/speech)

---

**Made with Claude Code**
