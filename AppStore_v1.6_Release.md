# PrayAnswer v1.6 App Store 배포 자료

## 버전 정보
- **버전**: 1.6
- **빌드**: 1
- **최소 iOS**: 26.0 (Apple Intelligence 필수)

---

## 🎯 프로모션 텍스트 (Promotional Text)

### 한국어 (170자)
```
기도를 기록하고, 응답을 경험하세요. 이미지 첨부, OCR 텍스트 추출, D-Day 캘린더 연동으로 더욱 풍성한 기도 생활을 시작하세요. iPad에서도 완벽하게 지원됩니다.
```

### English (170 chars)
```
Record your prayers and experience answers. Start a richer prayer life with image attachments, OCR text extraction, and D-Day calendar integration. Perfect for iPad.
```

### Español (170 chars)
```
Registra tus oraciones y experimenta respuestas. Comienza una vida de oración más rica con imágenes, extracción de texto OCR e integración de calendario D-Day.
```

---

## 📝 업데이트 노트 (What's New)

### 한국어
```
v1.6 업데이트

✨ Apple Intelligence 통합
• AI가 음성 녹음을 자동으로 기도문 형식으로 정리
• Apple Intelligence 설정 안내 가이드 제공
• iOS 26 이상 필수

🖼️ 이미지 첨부 기능
• 기도에 이미지를 첨부할 수 있습니다
• OCR로 이미지에서 텍스트를 추출하세요

📅 캘린더 연동 개선
• D-Day를 캘린더에 추가하는 토글 버튼
• D-7, D-3, D-1 자동 알림 설정

📱 iPad 최적화
• 3단 레이아웃으로 넓은 화면 활용
• iPad와 iPhone 간 데이터 동기화

🎨 UI/UX 개선
• iOS 전화 앱 스타일 헤더 적용
• 스크롤 시 부드러운 페이드 효과
• 전체적인 안정성 향상
```

### English
```
v1.6 Update

✨ Apple Intelligence Integration
• AI automatically organizes voice recordings into prayer format
• Apple Intelligence setup guide included
• Requires iOS 26 or later

🖼️ Image Attachments
• Attach images to your prayers
• Extract text from images with OCR

📅 Calendar Integration
• Toggle button to add D-Day to calendar
• Automatic reminders at D-7, D-3, D-1

📱 iPad Optimization
• 3-column layout for larger screens
• Data sync between iPad and iPhone

🎨 UI/UX Improvements
• iOS Phone app style header
• Smooth fade effects while scrolling
• Overall stability improvements
```

### Español
```
v1.6 Actualización

✨ Integración de Apple Intelligence
• La IA organiza automáticamente las grabaciones de voz en formato de oración
• Guía de configuración de Apple Intelligence incluida
• Requiere iOS 26 o posterior

🖼️ Archivos adjuntos de imagen
• Adjunta imágenes a tus oraciones
• Extrae texto de imágenes con OCR

📅 Integración de calendario
• Botón para añadir D-Day al calendario
• Recordatorios automáticos en D-7, D-3, D-1

📱 Optimización para iPad
• Diseño de 3 columnas para pantallas grandes
• Sincronización de datos entre iPad y iPhone

🎨 Mejoras de UI/UX
• Encabezado estilo app Teléfono de iOS
• Efectos de desvanecimiento suaves
• Mejoras generales de estabilidad
```

---

## 🔒 데이터 안정성 (Data Stability)

### SwiftData 모델 구조
```
Prayer (기도)
├── title: String
├── content: String
├── category: PrayerCategory
├── target: String (기도대상자)
├── storage: PrayerStorage (wait/yes/no)
├── createdDate: Date
├── modifiedDate: Date?
├── targetDate: Date? (D-Day)
├── notificationEnabled: Bool
├── calendarEventId: String?
├── imageFileName: String? (레거시 호환)
└── attachments: [Attachment] (cascade delete)

Attachment (첨부파일)
├── fileName: String (UUID 기반)
├── originalName: String
├── type: AttachmentType (image/pdf)
├── fileSize: Int64
├── order: Int
├── ocrText: String?
└── prayer: Prayer? (inverse relationship)
```

### 데이터 보호 메커니즘
1. **Cascade Delete**: 기도 삭제 시 첨부파일 자동 삭제
2. **마이그레이션 관리**: `AttachmentMigrationManager`로 레거시 데이터 자동 변환
3. **UserDefaults 플래그**: 1회성 마이그레이션 보장
4. **파일 시스템 분리**: `Documents/PrayerAttachments/` 디렉토리에 안전하게 저장

### iCloud 동기화
- SwiftData + CloudKit 자동 동기화
- iPhone ↔ iPad 간 실시간 데이터 연동
- 첨부 파일은 로컬 저장 (기기별)

---

## ✅ 배포 전 체크리스트

### 코드 검증
- [x] 버전 번호 1.6으로 업데이트
- [x] DEBUG 코드 제거 확인 (ScreenshotDataGenerator는 #if DEBUG로 보호됨)
- [x] 컴파일러 경고 없음
- [x] 빌드 성공

### 기능 테스트
- [ ] 새 기도 추가 및 저장
- [ ] 이미지 첨부 및 OCR
- [ ] D-Day 설정 및 캘린더 연동
- [ ] 알림 설정 및 수신
- [ ] iPad 3-column 레이아웃
- [ ] iPhone ↔ iPad 데이터 동기화

### App Store 준비
- [ ] 스크린샷 (iPhone 6.7", 6.5", 5.5" / iPad 12.9", 11")
- [ ] 프로모션 텍스트 업로드
- [ ] 업데이트 노트 입력
- [ ] 앱 설명 검토

---

## 📊 변경 이력 요약 (v1.5 → v1.6)

| 기능 | 상태 | 설명 |
|------|------|------|
| Apple Intelligence | ✅ 신규 | AI 기도문 정리 기능 (iOS 26 필수) |
| AI 설정 안내 | ✅ 신규 | Apple Intelligence 활성화 가이드 |
| 이미지 첨부 | ✅ 신규 | 기도에 이미지 첨부 가능 |
| OCR 텍스트 추출 | ✅ 신규 | Vision 프레임워크 활용 |
| iPad UI | ✅ 신규 | NavigationSplitView 3-column |
| 캘린더 토글 | ✅ 개선 | 자동 추가 → 사용자 선택 |
| 헤더 UI | ✅ 개선 | iOS 전화 앱 스타일 |
| 스크롤 페이드 | ✅ 개선 | 부드러운 전환 효과 |
| 데이터 안정성 | ✅ 개선 | 마이그레이션 로직 강화 |

---

## 🤖 Apple Intelligence 설정 안내

앱 내에서 AI 기능 사용 시 Apple Intelligence가 비활성화되어 있으면 **설정 안내 뷰**가 표시됩니다.

### 설정 단계
1. **설정 앱 열기** - iPhone의 설정 앱을 엽니다
2. **Apple Intelligence 찾기** - 설정 > Apple Intelligence 및 Siri로 이동
3. **Apple Intelligence 켜기** - 토글을 켜고 약관에 동의
4. **다운로드 대기** - AI 모델 다운로드 완료 대기 (Wi-Fi + 충전 권장)

### 지원 언어
- 한국어
- 영어

### 관련 파일
- `AppleIntelligenceSetupGuideView.swift` - 설정 안내 UI
- `AISummarizationManager.swift` - AI 기능 관리자

---

## 🚀 배포 명령어

```bash
# Archive 생성
xcodebuild -scheme PrayAnswer -configuration Release archive -archivePath ./build/PrayAnswer.xcarchive

# App Store 업로드 (Xcode Organizer 사용 권장)
```
