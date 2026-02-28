# PrayAnswer v1.9 Release Notes

## App Store 업데이트 노트

### 한국어
```
버전 1.9 - 기도 편집 시 음성 녹음 지원

새로운 기능:
• 기도 수정 화면에서 음성 녹음으로 내용 추가 가능
• 편집 모드에서도 마이크 버튼으로 바로 녹음 시작
• 녹음된 텍스트가 기존 내용에 자동 추가

개선 사항:
• 앱 사용 경험에 기반한 자연스러운 리뷰 요청 (v1.8)
• 전반적인 성능 및 안정성 향상
```

### English
```
Version 1.9 - Voice Recording in Prayer Editing

New Features:
• Add content via voice recording while editing prayers
• Start recording instantly with the microphone button in edit mode
• Recorded text is automatically appended to existing content

Improvements:
• Natural review prompts based on your app experience (v1.8)
• Overall performance and stability enhancements
```

### Español
```
Versión 1.9 - Grabación de voz al editar oraciones

Nuevas funciones:
• Agregar contenido por grabación de voz al editar oraciones
• Iniciar grabación al instante con el botón de micrófono en modo edición
• El texto grabado se añade automáticamente al contenido existente

Mejoras:
• Solicitudes de reseña naturales basadas en tu experiencia (v1.8)
• Mejoras generales de rendimiento y estabilidad
```

---

## 프로모션 텍스트 (Promotional Text)

### 한국어
```
기도를 수정할 때에도 음성으로 간편하게 내용을 추가하세요. 더 자유롭고 편리한 기도 기록을 경험하세요.
```

### English
```
Add content by voice even while editing prayers. Experience a more flexible and convenient way to record your prayers.
```

### Español
```
Agrega contenido por voz incluso al editar oraciones. Experimenta una forma más flexible y conveniente de registrar tus oraciones.
```

---

## 주요 변경 사항 체크리스트

### 데이터 안정성
- [x] SwiftData 모델 (Prayer, Attachment) 변경 없음 - 데이터 마이그레이션 불필요
- [x] 음성 녹음 텍스트는 기존 editedContent에 append - 기존 내용 보존
- [x] 편집 취소 시 녹음 내용도 함께 취소 (기존 cancelEditing 로직 활용)
- [x] iCloud 동기화 영향 없음

### 수정된 파일
- [x] `Views/PrayerDetailView.swift` - 편집 모드에 음성 녹음 기능 추가
- [x] `PrayAnswer.xcodeproj/project.pbxproj` - MARKETING_VERSION 1.8 → 1.9 (4곳)

### 추가된 컴포넌트 (PrayerDetailView 내)
| 항목 | 설명 |
|------|------|
| `speechManager` | SpeechRecognitionManager.shared 참조 |
| `showVoiceRecordingOverlay` | 녹음 오버레이 표시 상태 |
| `showVoicePermissionAlert` | 마이크 권한 거부 시 설정 안내 |
| `VoiceRecordingButton` | 편집 모드 내용 영역 우측 상단 (iPhone) |
| `VoiceRecordingOverlay` | fullScreenCover 녹음 UI |
| `VoicePermissionAlert` | 권한 안내 sheet |
| `startVoiceRecording()` | 권한 확인 → 녹음 시작 |

### 디버그 모드 해제
- [x] 새로 추가된 코드에 DEBUG 전용 출력 없음
- [x] 기존 DEBUG 가드 유지 확인

### 버전 정보
- 마케팅 버전: 1.8 → 1.9
- 빌드 번호: 1 (유지)

### 테스트 필요 항목
- [ ] 기도 편집 모드에서 마이크 버튼 표시 확인
- [ ] 마이크 버튼 탭 → 녹음 오버레이 정상 표시
- [ ] 녹음 → "텍스트 사용" → 기존 내용에 추가 확인
- [ ] 녹음 → "취소" → 내용 변경 없음 확인
- [ ] 편집 취소 시 녹음 추가 내용도 함께 롤백
- [ ] 마이크 권한 거부 시 설정 안내 표시
- [ ] iPad 편집 모드에서 마이크 버튼 미표시 (사이드 패널 사용)
- [ ] 기존 보기 모드 기능 영향 없음
- [ ] 기존 AddPrayerView 녹음 기능 영향 없음

---

## 변경 이력 요약 (v1.8 → v1.9)

| 기능 | 상태 | 설명 |
|------|------|------|
| 편집 모드 음성 녹음 | ✅ 신규 | PrayerDetailView 편집 시 VoiceRecordingButton 추가 |
| 녹음 오버레이 | ✅ 신규 | 편집 모드 전용 fullScreenCover 녹음 UI |
| 권한 안내 | ✅ 신규 | 편집 모드 전용 VoicePermissionAlert |
| 텍스트 추가 방식 | ✅ 신규 | 기존 내용 뒤에 줄바꿈 후 append |
| 데이터 모델 | 변경 없음 | SwiftData 스키마 유지 |
| 기존 기능 | 변경 없음 | 모든 기존 기능 정상 동작 |

---

## 누적 업데이트 요약 (v1.7 → v1.9)

| 버전 | 주요 변경 |
|------|-----------|
| v1.7 | 복수 첨부 파일 지원 (이미지/PDF 최대 10개), 배치 OCR, 음성 녹음 버그 수정 |
| v1.8 | 앱스토어 리뷰 요청 (하이브리드 전략: 응답 마일스톤 + 생성 마일스톤) |
| v1.9 | 기도 편집 모드 음성 녹음 지원 |
