# PrayAnswer v1.10 앱스토어 릴리즈 노트

## 버전 정보
- **마케팅 버전**: 1.10
- **빌드 번호**: 1
- **최소 iOS**: 기존 설정 유지

---

## 앱스토어 업데이트 노트 (한국어)

### 새로운 기능
**📊 기도 통계**
- 전체 기도 수, 응답률, 즐겨찾기 수를 한눈에 확인
- 보관소별 분포 도넛 차트
- 최근 6개월 월별 기도 추이 바 차트
- 카테고리별 분포 차트
- 기도 대상자 TOP 5 랭킹

**🔧 위젯 개선**
- 기도 추가 위젯: 메인 버튼 동작을 직접 설정 가능 (기도추가/보관소/즐겨찾기/통계)
- 기도 보관소 위젯: 즐겨찾기 전체 보기 옵션 추가
- 위젯 레이아웃 개선으로 더 많은 정보 표시
- 위젯 탭 시 해당 화면으로 바로 이동

---

## 앱스토어 업데이트 노트 (영어)

### What's New
**📊 Prayer Statistics**
- View total prayers, answer rate, and favorites at a glance
- Storage distribution donut chart
- Monthly prayer activity bar chart (last 6 months)
- Category distribution chart
- Top 5 prayer targets ranking

**🔧 Widget Improvements**
- Add Prayer widget: Customize main button action (add prayer / storage / favorites / statistics)
- Prayer Storage widget: New "All Favorites" option across all storages
- Improved widget layout for more information display
- Tap widget to navigate directly to the relevant screen

---

## 제출 체크리스트

### Xcode
- [ ] Archive 빌드 (Product → Archive)
- [ ] Validate App
- [ ] Distribute App → App Store Connect

### App Store Connect
- [ ] 업데이트 노트 입력 (한국어/영어)
- [ ] 스크린샷 업데이트 (통계 화면 추가)
- [ ] 위젯 스크린샷 업데이트 (새 위젯 UI)
- [ ] 심사 제출

### 스크린샷 필요 항목
1. 통계 화면 (iPhone + iPad)
2. 기도 추가 위젯 Small (새 UI)
3. 기도 추가 위젯 Medium (새 3×2 그리드)
4. 보관소 위젯 (즐겨찾기 전체 옵션)

---

## 주요 변경 사항 요약 (내부용)

| 파일 | 변경 내용 |
|------|-----------|
| `StatisticsView.swift` | 신규 - Swift Charts 통계 화면 |
| `ContentView.swift` | 탭 4번 추가, URL 스킴 확장 |
| `LocalizationKeys.swift` | L.Stats.* 로컬라이제이션 추가 |
| `AddPrayerWidget.swift` | AppIntentConfiguration 전환, 메인 버튼 설정 |
| `AppIntent.swift` | QuickActionAppEnum, AddPrayerWidgetIntent 추가 |
| `PrayerConfigurableWidget.swift` | favorites 옵션 추가 |
| `SharedWidgetViews.swift` | Spacer 버그 수정, 즐겨찾기 위젯 추가 |
| `WidgetDataManager.swift` | loadAllFavorites() 추가 |
