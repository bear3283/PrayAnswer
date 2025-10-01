# PrayAnswer 🙏

> 기도 요청을 체계적으로 관리하고 응답을 추적하는 iOS 앱

[![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)](https://www.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-blue.svg)](https://developer.apple.com/xcode/swiftui/)
[![SwiftData](https://img.shields.io/badge/SwiftData-Latest-green.svg)](https://developer.apple.com/xcode/swiftdata/)

## 📱 개요

**PrayAnswer**는 개인 및 공동체의 기도 생활을 돕기 위한 iOS 기도 관리 앱입니다. 기도 요청을 작성하고, 응답 상태를 추적하며, 기도 대상자별로 체계적으로 관리할 수 있습니다.

### 주요 특징

#### 🗂️ 스마트 보관소 시스템
- **대기 (Wait)**: 응답을 기다리는 기도
- **응답 (Yes)**: 긍정적으로 응답된 기도
- **미응답 (No)**: 다른 방식으로 응답된 기도
- 각 보관소별 시각적 구분과 통계 제공

#### 👥 기도 대상자 관리
- 가족, 친구, 동료 등 대상자별 기도 분류
- 대상자별 기도 내역 및 통계 확인
- 대상자별 최근 기도 날짜 추적

#### 🏷️ 카테고리 시스템
8가지 주제별 기도 분류:
- 개인 (Personal)
- 가족 (Family)
- 건강 (Health)
- 직장/업무 (Work)
- 관계 (Relationship)
- 감사 (Thanksgiving)
- 비전 (Vision)
- 기타 (Other)

#### ⭐ 즐겨찾기 기능
- 중요한 기도를 즐겨찾기로 표시
- 보관소별 즐겨찾기 기도 필터링
- 위젯에서 즐겨찾기 기도 빠른 확인

#### 🔍 강력한 검색 및 필터링
- 기도 대상자 이름 검색
- 보관소별 기도 필터링
- 카테고리별 기도 조회

#### 📊 홈 위젯 지원
- iOS 홈 화면에서 즐겨찾기 기도 확인
- 위젯 크기별 최적화된 레이아웃
- 보관소별 기도 표시

#### 🌍 다국어 지원
- 한국어 (Korean) - 기본
- 영어 (English)
- 스페인어 (Spanish)
- 타입 안전 로컬라이제이션 시스템

#### ♿ 접근성
- VoiceOver 완전 지원
- 동적 타입(Dynamic Type) 지원
- 고대비 모드 최적화
- 색상 구분 없는 시각적 피드백

---

## 🏗️ 기술 스택

### Core Technologies
- **Swift 5.9+**: 최신 Swift 언어 기능 활용
- **SwiftUI**: 선언적 UI 프레임워크
- **SwiftData**: 현대적인 데이터 지속성 프레임워크
- **Combine**: 반응형 프로그래밍

### Architecture
- **MVVM Pattern**: Model-View-ViewModel 아키텍처
- **Observable Objects**: 상태 관리 및 데이터 바인딩
- **Dependency Injection**: ModelContext 의존성 주입

### Features
- **WidgetKit**: iOS 홈 화면 위젯
- **App Groups**: 앱-위젯 간 데이터 공유
- **UserDefaults**: 위젯 데이터 동기화
- **Type-Safe Localization**: 컴파일 타임 안전성

---

## 📂 프로젝트 구조

```
PrayAnswer/
├── PrayAnswer/
│   ├── Models/
│   │   └── Prayer.swift                    # 기도 데이터 모델
│   ├── ViewModels/
│   │   └── PrayerViewModel.swift           # 비즈니스 로직
│   ├── Views/
│   │   ├── ContentView.swift               # 메인 탭 뷰
│   │   ├── AddPrayerView.swift             # 기도 추가 화면
│   │   ├── PrayerDetailView.swift          # 기도 상세 화면
│   │   ├── PeopleListView.swift            # 대상자 목록
│   │   ├── PersonDetailView.swift          # 대상자 상세
│   │   └── UIComponents.swift              # 재사용 가능한 UI 컴포넌트
│   ├── Utils/
│   │   ├── DesignSystem.swift              # 디자인 토큰 시스템
│   │   ├── LocalizationKeys.swift          # 타입 안전 로컬라이제이션
│   │   ├── Logger.swift                    # 로깅 유틸리티
│   │   └── WidgetDataManager.swift         # 위젯 데이터 관리
│   ├── en.lproj/
│   ├── ko.lproj/
│   ├── es.lproj/
│   └── PrayAnswerApp.swift                 # 앱 진입점
└── PrayerWidget/
    ├── PrayerWidget.swift                  # 위젯 구현
    └── PrayerWidgetBundle.swift            # 위젯 번들
```

---

## 🎨 디자인 시스템

### Design Tokens
- **Colors**: 시맨틱 컬러 시스템 (Primary, Secondary, Semantic)
- **Typography**: 일관된 텍스트 스타일 계층
- **Spacing**: 8pt 그리드 시스템 (xxs ~ huge)
- **Corner Radius**: 4단계 라운드 코너 (small ~ extraLarge)
- **Shadows**: 3단계 그림자 효과 (small, medium, large)
- **Animation**: 표준화된 애니메이션 속도

### UI Components
- `ModernCard`: 일관된 카드 스타일
- `ModernButton`: 3가지 스타일 (primary, secondary, destructive)
- `ModernTextField`: 커스텀 텍스트 필드
- `ModernTextEditor`: 멀티라인 에디터
- `ModernCategoryPicker`: 카테고리 선택기
- `StatusIndicator`: 보관소 상태 표시
- `CategoryTag`: 카테고리 뱃지
- `FavoriteButton`: 즐겨찾기 토글

---

## 🚀 주요 기능

### 1. 기도 관리
```swift
// 기도 생성
let prayer = Prayer(
    title: "가족의 건강",
    content: "부모님의 건강을 위해 기도합니다",
    category: .family,
    target: "부모님",
    storage: .wait
)

// 보관소 이동
prayer.moveToStorage(.yes)

// 즐겨찾기 토글
prayer.toggleFavorite()
```

### 2. 데이터 쿼리
```swift
// 보관소별 조회
let waitingPrayers = viewModel.prayersInStorage(.wait)

// 대상자별 조회
let prayersForMom = viewModel.prayersByTarget("엄마")

// 즐겨찾기 조회
let favorites = viewModel.favoritePrayers()
```

### 3. 위젯 통합
```swift
// 위젯 데이터 업데이트
WidgetDataManager.shared.shareFavoritePrayersByStorage(favoritesByStorage)

// 위젯 리프레시 요청
WidgetCenter.shared.reloadAllTimelines()
```

---

## 📊 데이터 모델

### Prayer Model
```swift
@Model
final class Prayer {
    var title: String           // 기도 제목
    var content: String         // 기도 내용
    var createdDate: Date       // 생성 날짜
    var modifiedDate: Date?     // 수정 날짜
    var movedDate: Date?        // 이동 날짜
    var storage: PrayerStorage  // 보관소 (wait/yes/no)
    var category: PrayerCategory // 카테고리
    var target: String          // 기도 대상자
    var isFavorite: Bool        // 즐겨찾기 여부
}
```

### Storage Types
- `wait`: 응답 대기 중인 기도
- `yes`: 긍정적으로 응답된 기도
- `no`: 다른 방식으로 응답된 기도

### Categories
- `personal`: 개인적 기도
- `family`: 가족 관련
- `health`: 건강 관련
- `work`: 직장/업무
- `relationship`: 관계
- `thanksgiving`: 감사
- `vision`: 비전/목표
- `other`: 기타

---

## 🌍 로컬라이제이션

### 타입 안전 로컬라이제이션 시스템
```swift
// ✅ 컴파일 타임 안전성
Text(L.Tab.prayerList)          // "기도 목록"
Text(L.Button.save)             // "저장"
Text(L.Error.emptyFields)       // "필수 항목을 입력해주세요"

// ✅ 동적 포맷팅
Text(L.Date.recentPrayerFormat(date))
Text(L.Counter.totalFormat(count))
```

### 지원 언어
- 🇰🇷 한국어 (Korean) - 기본 언어
- 🇺🇸 영어 (English)
- 🇪🇸 스페인어 (Spanish)

---

## 🎯 사용 흐름

### 기도 추가 플로우
1. **기도 추가** 탭 선택
2. 제목, 내용, 카테고리, 대상자 입력
3. 저장 버튼 클릭
4. 자동으로 "대기" 보관소에 추가
5. 위젯 자동 업데이트

### 기도 관리 플로우
1. **기도 목록** 탭에서 보관소 선택 (대기/응답/미응답)
2. 기도 항목 클릭하여 상세 화면 진입
3. 보관소 이동, 수정, 삭제, 즐겨찾기 추가 가능
4. 변경 사항 즉시 반영

### 대상자별 조회 플로우
1. **기도 대상자** 탭 선택
2. 대상자 목록에서 이름 선택
3. 해당 대상자의 모든 기도 확인
4. 보관소별 통계 확인

---

## 🔒 데이터 보안

### App Group Sandboxing
- 앱과 위젯 간 안전한 데이터 공유
- App Group ID: `group.prayAnswer.widget`
- UserDefaults를 통한 위젯 데이터 전달

### 데이터 지속성
- SwiftData를 사용한 로컬 저장소
- iCloud 백업 지원
- 앱 삭제 시 데이터 완전 제거

---

## 🛠️ 개발 환경 설정

### 요구사항
- macOS 14.0 이상
- Xcode 15.0 이상
- iOS 17.0 이상 (배포 타겟)
- Swift 5.9 이상

### 빌드 및 실행
1. Xcode에서 `PrayAnswer.xcodeproj` 열기
2. 타겟 선택: `PrayAnswer` (메인 앱) 또는 `PrayerWidgetExtension` (위젯)
3. 시뮬레이터 또는 실제 디바이스 선택
4. `Cmd + R` 로 빌드 및 실행

### App Group 설정
위젯 기능을 사용하려면 App Group을 설정해야 합니다:
1. Xcode > Signing & Capabilities
2. `+ Capability` 클릭
3. `App Groups` 추가
4. `group.prayAnswer.widget` 체크

---

## 📱 화면 구성

### 메인 화면
- **기도 목록**: 보관소별 기도 필터링 및 관리
- **기도 추가**: 직관적인 입력 폼
- **기도 대상자**: 대상자별 기도 통계 및 관리

### 상세 화면
- **기도 상세**: 기도 내용, 카테고리, 대상자, 날짜 정보
- **대상자 상세**: 대상자별 기도 목록 및 통계

### 위젯
- 소형: 최신 즐겨찾기 기도 1개
- 중형: 즐겨찾기 기도 목록
- 대형: 보관소별 즐겨찾기 기도

---

## 🧪 테스트

### 단위 테스트
- Prayer 모델 검증
- PrayerViewModel 로직 테스트
- 데이터 변환 및 포맷팅 테스트

### 통합 테스트
- SwiftData CRUD 작업
- 위젯 데이터 동기화
- 로컬라이제이션 키 검증

---

## 🔄 버전 관리

### Git 워크플로우
- `main`: 안정적인 릴리즈 브랜치
- `develop`: 개발 브랜치
- `feature/*`: 기능 개발 브랜치
- `bugfix/*`: 버그 수정 브랜치

---

## 📈 성능 최적화

### 메모리 관리
- `@Observable` 및 `ObservableObject` 활용
- 백그라운드 큐에서 위젯 데이터 처리
- 메모리 사용량 로깅 (`PrayerLogger`)

### 렌더링 최적화
- LazyVStack/LazyHStack 사용
- 이미지 및 에셋 최적화
- 애니메이션 성능 튜닝

---

## 🐛 디버깅 및 로깅

### PrayerLogger 유틸리티
```swift
// 사용자 액션 로깅
PrayerLogger.shared.userAction("기도 저장")

// 기도 생성 로깅
PrayerLogger.shared.prayerCreated(title: "새 기도")

// 에러 로깅
PrayerLogger.shared.prayerOperationFailed("저장", error: error)

// 메모리 사용량 모니터링
PrayerLogger.shared.logMemoryUsage()
```

---

## 🤝 기여하기

이 프로젝트는 개인 프로젝트이지만, 개선 제안이나 버그 리포트는 언제나 환영합니다.

### 코드 스타일
- Swift 표준 코딩 컨벤션 준수
- SwiftLint 규칙 적용
- 주석은 영어 또는 한국어로 작성

---

## 📄 라이선스

Copyright © 2025 PrayAnswer. All rights reserved.

---

## 👤 작성자

**bear**
- Apple Academy Student
- 개발 시작: 2025년 6월 29일

---

## 🙏 감사의 말

이 앱은 기도 생활을 더 체계적이고 의미 있게 만들기 위해 개발되었습니다. 사용자 여러분의 신앙 생활에 작은 도움이 되기를 바랍니다.

---

## 📚 추가 문서

- [로컬라이제이션 설정](./LOCALIZATION_SETUP.md)
- [디자인 시스템 가이드](./PrayAnswer/DesignSystem.swift)
- [위젯 구현 가이드](./PrayerWidget/)

---

**Made with ❤️ and 🙏**
