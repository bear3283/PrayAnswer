# PrayAnswer 다국어 설정 가이드

## ✅ 완료된 작업

다음 언어에 대한 다국어 지원이 구현되었습니다:
- 🇰🇷 한국어 (Korean)
- 🇺🇸 영어 (English)
- 🇨🇳 중국어 간체 (Simplified Chinese)
- 🇪🇸 스페인어 (Spanish)

## 📁 생성된 파일

### 다국어 리소스 파일
```
PrayAnswer/
├── ko.lproj/
│   └── Localizable.strings     # 한국어
├── en.lproj/
│   └── Localizable.strings     # 영어
├── zh-Hans.lproj/
│   └── Localizable.strings     # 중국어 간체
├── es.lproj/
│   └── Localizable.strings     # 스페인어
└── Utils/
    └── LocalizationKeys.swift  # 타입 안전 다국어 헬퍼
```

### 업데이트된 Swift 파일
- `Models/Prayer.swift` - 모델 다국어화
- `ContentView.swift` - 메인 화면
- `Views/AddPrayerView.swift` - 기도 추가 화면
- `Views/PeopleListView.swift` - 기도대상자 화면
- `Views/PrayerDetailView.swift` - 기도 상세 화면
- `Views/UIComponents.swift` - UI 컴포넌트

## 🔧 Xcode 프로젝트 설정

### 1. 다국어 파일을 Xcode에 추가

1. Xcode에서 프로젝트 열기
2. Project Navigator에서 `PrayAnswer` 폴더 우클릭
3. "Add Files to PrayAnswer..." 선택
4. 다음 폴더들을 선택하고 추가:
   - `ko.lproj`
   - `en.lproj`
   - `zh-Hans.lproj`
   - `es.lproj`
5. "Create groups" 옵션 선택
6. "Add" 클릭

### 2. 프로젝트에 지원 언어 추가

1. Project Navigator에서 최상위 프로젝트 선택
2. "PrayAnswer" 프로젝트 선택 (타겟 아님)
3. "Info" 탭 선택
4. "Localizations" 섹션 찾기
5. `+` 버튼 클릭하여 언어 추가:
   - English
   - Korean
   - Chinese (Simplified)
   - Spanish
6. 각 언어 추가 시 "Finish" 클릭

### 3. LocalizationKeys.swift 추가

1. `Utils/LocalizationKeys.swift` 파일을 Xcode 프로젝트에 추가
2. Target Membership에서 "PrayAnswer" 체크 확인

### 4. 빌드 및 테스트

1. Command + B로 프로젝트 빌드
2. 빌드 에러가 있다면 확인 및 수정
3. 시뮬레이터 또는 기기에서 실행

## 📱 언어 변경 테스트

### iOS 시뮬레이터에서 테스트

1. Settings 앱 열기
2. General > Language & Region
3. "Preferred Languages" 선택
4. 원하는 언어 추가 및 우선순위 변경
5. PrayAnswer 앱 재실행

### 지원 언어 확인

앱이 다음 언어로 자동 전환됩니다:
- **한국어**: 기본 언어
- **English**: 영어권 사용자
- **中文（简体）**: 중국 본토 사용자
- **Español**: 스페인어권 사용자

## 💡 사용 방법

### 코드에서 다국어 문자열 사용

```swift
// ✅ 올바른 방법 (타입 안전)
Text(L.Tab.prayerList)
Button(L.Button.save) { }
.alert(L.Alert.error, isPresented: $showAlert) { }

// ❌ 잘못된 방법 (하드코딩)
Text("기도 목록")
Button("저장") { }
.alert("오류", isPresented: $showAlert) { }
```

### LocalizationKeys 구조

```swift
L.Tab.prayerList           // 탭바 텍스트
L.Nav.prayerDetail         // 네비게이션 제목
L.Button.save              // 버튼 텍스트
L.Label.title              // 폼 레이블
L.Placeholder.content      // 플레이스홀더
L.Alert.error              // 알림 제목
L.Error.saveFailed         // 에러 메시지
L.Info.prayerInfo          // 정보 레이블
L.Empty.storageTitle       // 빈 상태 제목
```

## 🌍 새로운 언어 추가하기

다른 언어를 추가하려면:

1. 새 폴더 생성 (예: `ja.lproj` for Japanese)
2. `Localizable.strings` 파일 복사 및 번역
3. Xcode 프로젝트에 폴더 추가
4. Project Info에서 해당 언어 추가

### 언어 코드 참고

- `ja` - 일본어 (Japanese)
- `de` - 독일어 (German)
- `fr` - 프랑스어 (French)
- `pt-BR` - 포르투갈어 (Brazilian Portuguese)
- `ru` - 러시아어 (Russian)
- `ar` - 아랍어 (Arabic)

## 📝 번역 업데이트

새로운 문자열을 추가할 때:

1. 모든 `.lproj/Localizable.strings` 파일에 키 추가
2. `LocalizationKeys.swift`에 새 키 정의
3. Swift 코드에서 `L.` 접두사로 사용

## ⚠️ 주의사항

- **위젯 지원**: 위젯 파일도 업데이트 필요 시 같은 방식으로 진행
- **InfoPlist.strings**: 필요 시 앱 이름, 권한 메시지도 다국어화 가능
- **이미지/에셋**: 언어별 이미지가 필요하면 Asset Catalog에서 Localization 설정

## 🎯 완료 확인사항

- [ ] Xcode 프로젝트에 모든 `.lproj` 폴더 추가됨
- [ ] Project Info에 모든 언어 추가됨
- [ ] `LocalizationKeys.swift` 파일 추가됨
- [ ] 빌드 에러 없이 컴파일 성공
- [ ] 각 언어로 전환하여 정상 작동 확인
- [ ] 모든 화면에서 번역된 텍스트 표시 확인

## 🚀 다음 단계

1. Xcode에서 프로젝트 열기
2. 이 가이드대로 설정 진행
3. 빌드 및 테스트
4. 필요시 번역 수정 또는 추가

---

다국어 지원이 성공적으로 구현되었습니다! 🎉