# PrayAnswer v1.7 Release Notes

## App Store 업데이트 노트

### 한국어
```
버전 1.7 - 복수 첨부 파일 지원

새로운 기능:
• 이미지 및 PDF 여러 개 첨부 가능 (기도당 최대 10개)
• 전체화면 미리보기 - 이미지 줌/팬, PDF 뷰어 지원
• 여러 이미지에서 한 번에 텍스트 추출 (배치 OCR)
• 첨부 파일 갤러리 UI 개선

버그 수정:
• 음성 녹음 중지 후 텍스트가 사라지는 문제 수정
• 기존 이미지 데이터 자동 마이그레이션

안정성 개선:
• 전반적인 성능 및 안정성 향상
```

### English
```
Version 1.7 - Multiple Attachments Support

New Features:
• Attach multiple images and PDF files (up to 10 per prayer)
• Full-screen preview - image zoom/pan, PDF viewer support
• Extract text from multiple images at once (batch OCR)
• Improved attachment gallery UI

Bug Fixes:
• Fixed issue where text disappeared after stopping voice recording
• Automatic migration of existing image data

Stability Improvements:
• Overall performance and stability enhancements
```

### Español
```
Versión 1.7 - Soporte para múltiples archivos adjuntos

Nuevas funciones:
• Adjuntar múltiples imágenes y archivos PDF (hasta 10 por oración)
• Vista previa a pantalla completa - zoom/pan de imágenes, visor de PDF
• Extraer texto de múltiples imágenes a la vez (OCR por lotes)
• Interfaz de galería de adjuntos mejorada

Correcciones:
• Solucionado el problema donde el texto desaparecía al detener la grabación de voz
• Migración automática de datos de imágenes existentes

Mejoras de estabilidad:
• Mejoras generales de rendimiento y estabilidad
```

---

## 프로모션 텍스트 (Promotional Text)

### 한국어
```
기도를 더 풍성하게 기록하세요. 이제 여러 이미지와 PDF를 첨부할 수 있습니다.
```

### English
```
Record your prayers more richly. Now you can attach multiple images and PDFs.
```

### Español
```
Registra tus oraciones más ricamente. Ahora puedes adjuntar múltiples imágenes y PDFs.
```

---

## 주요 변경 사항 체크리스트

### 데이터 안정성
- [x] 기존 단일 이미지 → Attachment 모델 자동 마이그레이션
- [x] 마이그레이션 1회성 실행 (UserDefaults 플래그)
- [x] 파일 복사 시 원본 유지 (안전한 마이그레이션)
- [x] SwiftData Cascade 삭제 규칙 적용

### 디버그 모드 해제
- [x] NotificationManager.swift print문 #if DEBUG 처리
- [x] Logger.swift 이미 #if DEBUG 처리됨
- [x] ScreenshotDataGenerator.swift 이미 #if DEBUG 처리됨

### 버전 정보
- 마케팅 버전: 1.6 → 1.7
- 빌드 번호: 2 → 1 (새 버전이므로 리셋)

### 테스트 필요 항목
- [ ] 신규 설치 후 기도 생성 및 첨부 파일 추가
- [ ] 기존 데이터 마이그레이션 정상 동작
- [ ] 이미지 전체화면 줌/팬 동작
- [ ] PDF 미리보기 동작
- [ ] 배치 OCR 텍스트 추출
- [ ] 음성 녹음 → 텍스트 사용 정상 동작
- [ ] 첨부 파일 삭제 정상 동작
- [ ] 기도 삭제 시 첨부 파일도 삭제
- [ ] iPad에서 UI 정상 표시
