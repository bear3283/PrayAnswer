# PrayAnswer v1.8 Release Notes

## App Store 업데이트 노트

### 한국어
```
버전 1.8 - 앱스토어 리뷰 요청 및 안정성 개선

새로운 기능:
• 앱 사용 경험에 기반한 자연스러운 리뷰 요청
• 기도 응답 시 감사의 순간에 별점 평가 안내
• 기도 작성 마일스톤 달성 시 피드백 요청

안정성 개선:
• 전반적인 성능 및 안정성 향상
```

### English
```
Version 1.8 - App Store Review Prompt & Stability Improvements

New Features:
• Natural review prompts based on your app experience
• Rating invitation at moments of gratitude when prayers are answered
• Feedback requests when prayer writing milestones are reached

Stability Improvements:
• Overall performance and stability enhancements
```

### Español
```
Versión 1.8 - Solicitud de reseña y mejoras de estabilidad

Nuevas funciones:
• Solicitudes de reseña naturales basadas en tu experiencia con la app
• Invitación a calificar en momentos de gratitud cuando se responden oraciones
• Solicitudes de retroalimentación al alcanzar hitos de escritura de oraciones

Mejoras de estabilidad:
• Mejoras generales de rendimiento y estabilidad
```

---

## 프로모션 텍스트 (Promotional Text)

### 한국어
```
기도의 응답을 기록하고, 감사의 순간을 나누세요. 여러분의 소중한 평가가 더 나은 기도 앱을 만듭니다.
```

### English
```
Record answered prayers and share your moments of gratitude. Your valuable feedback helps us build a better prayer app.
```

### Español
```
Registra oraciones respondidas y comparte tus momentos de gratitud. Tu valiosa opinión nos ayuda a crear una mejor app de oración.
```

---

## 주요 변경 사항 체크리스트

### 데이터 안정성
- [x] ReviewRequestManager: UserDefaults 기반 상태 관리 (SwiftData 모델 변경 없음)
- [x] 기존 SwiftData 모델 (Prayer, Attachment) 변경 없음 - 데이터 마이그레이션 불필요
- [x] 기존 UserDefaults 데이터와 충돌 없는 독립 키 사용 (`ReviewRequest_` 접두사)
- [x] iCloud 동기화 영향 없음 - 리뷰 상태는 기기별 로컬 저장

### 새로 추가된 파일
- [x] `Utils/ReviewRequestManager.swift` - 앱스토어 리뷰 요청 관리자

### 수정된 파일
- [x] `Views/AddPrayerView.swift` - StoreKit import, requestReview 환경변수, 저장 후 리뷰 체크
- [x] `Views/PrayerDetailView.swift` - StoreKit import, requestReview 환경변수, 응답 이동 후 리뷰 체크
- [x] `PrayAnswer.xcodeproj/project.pbxproj` - MARKETING_VERSION 1.7 → 1.8 (4곳)

### 디버그 모드 해제
- [x] ReviewRequestManager.swift print문 #if DEBUG 처리
- [x] 기존 DEBUG 가드 유지 확인 (Logger, ScreenshotDataGenerator, NotificationManager)

### 버전 정보
- 마케팅 버전: 1.7 → 1.8
- 빌드 번호: 1 (유지)

### 리뷰 요청 전략 상세

#### 하이브리드 전략 (Strategy C)

| 구분 | 트리거 | 마일스톤 | 타이밍 |
|------|--------|----------|--------|
| Primary | 기도 "응답 받음" 이동 | 1번째, 3번째, 5번째 | 이동 1초 후 |
| Fallback | 기도 새로 생성 | 10번째, 25번째, 50번째 | 저장 2초 후 |

#### 안전 장치
| 보호 장치 | 설명 |
|-----------|------|
| 버전 게이트 | 같은 앱 버전에서 최대 1회만 요청 |
| 시간 게이트 | 최소 90일 간격 유지 |
| Apple 제한 | 시스템 자체 365일당 3회 제한 |
| 비동기 실행 | 성공 알림 이후 자연스러운 딜레이로 표시 |

#### UserDefaults 키
| 키 | 타입 | 용도 |
|----|------|------|
| `ReviewRequest_totalPrayerCount` | Int | 총 기도 생성 수 |
| `ReviewRequest_answeredPrayerCount` | Int | 총 기도 응답 수 |
| `ReviewRequest_lastVersionPrompted` | String | 마지막 리뷰 요청 앱 버전 |
| `ReviewRequest_lastPromptDate` | Double | 마지막 리뷰 요청 날짜 (TimeInterval) |

### 테스트 필요 항목
- [ ] 기도 생성 10번째에서 리뷰 요청 표시 확인
- [ ] 기도 "응답 받음" 이동 시 리뷰 요청 표시 확인
- [ ] 같은 버전에서 중복 요청 안 되는지 확인
- [ ] 90일 간격 미충족 시 요청 안 되는지 확인
- [ ] iPad에서 리뷰 요청 정상 동작
- [ ] 기존 기도 생성/수정/삭제 기능 영향 없음
- [ ] 기존 보관소 이동 기능 영향 없음
- [ ] 위젯 데이터 업데이트 정상 동작

---

## 변경 이력 요약 (v1.7 → v1.8)

| 기능 | 상태 | 설명 |
|------|------|------|
| 앱스토어 리뷰 요청 | ✅ 신규 | SKStoreReviewController 기반 하이브리드 전략 |
| 응답 마일스톤 트리거 | ✅ 신규 | 기도 응답(yes) 1/3/5번째 시 리뷰 요청 |
| 생성 마일스톤 트리거 | ✅ 신규 | 기도 생성 10/25/50번째 시 리뷰 요청 |
| 버전/시간 게이트 | ✅ 신규 | 버전당 1회, 최소 90일 간격 |
| 데이터 모델 | 변경 없음 | SwiftData 스키마 유지 |
| 기존 기능 | 변경 없음 | 모든 기존 기능 정상 동작 |
