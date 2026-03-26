import SwiftUI
import SwiftData
import StoreKit

struct AddPrayerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.requestReview) private var requestReview
    @Binding var selectedTab: Int

    // MARK: - 다인원 기도 초안 상태
    @State private var draftEntries: [PrayerDraftEntry] = [PrayerDraftEntry(target: "", colorIndex: 0)]
    @State private var activeEntryIndex: Int = 0

    @State private var showingAlert = false
    @State private var showingSuccessAlert = false
    @State private var alertMessage = ""
    @State private var prayerViewModel: PrayerViewModel?
    @FocusState private var isContentFieldFocused: Bool

    // Voice Recording
    @State private var showVoiceRecordingOverlay = false
    @State private var showVoicePermissionAlert = false
    private var speechManager: SpeechRecognitionManager

    // Attachments: active entry에서 직접 관리 (OCR 팝업용 임시 상태)
    @State private var showOCRResult = false
    @State private var extractedText = ""
    @State private var isExtractingText = false
    @State private var scrollOffset: CGFloat = 0
    @State private var scrollToTopTrigger: Bool = false

    // iPad: 외부에서 전달받은 녹음 텍스트 (사이드 패널에서)
    @Binding var externalRecordedText: String

    init(selectedTab: Binding<Int>, externalRecordedText: Binding<String>? = nil) {
        self._selectedTab = selectedTab
        self._externalRecordedText = externalRecordedText ?? .constant("")
        self.speechManager = SpeechRecognitionManager.shared
    }

    // 기존 기도대상자 목록
    private var existingTargets: [String] {
        prayerViewModel?.allTargets() ?? []
    }

    // MARK: - Active Entry 헬퍼

    /// 항상 유효한 범위 내의 안전한 인덱스
    private var safeIdx: Int {
        guard !draftEntries.isEmpty else { return 0 }
        return min(activeEntryIndex, draftEntries.count - 1)
    }

    private var activeEntry: PrayerDraftEntry {
        guard !draftEntries.isEmpty else { return PrayerDraftEntry() }
        return draftEntries[safeIdx]
    }

    private var isMultiEntryMode: Bool { draftEntries.count > 1 }

    private var saveableCount: Int { draftEntries.filter { $0.hasContent }.count }

    private var saveButtonTitle: String {
        saveableCount > 1 ? "\(saveableCount)명의 기도제목 저장" : L.Button.savePrayer
    }

    private var generatedTitle: String {
        Prayer.generateTitle(from: activeEntry.target, category: activeEntry.category)
    }

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                // iPad: NavigationView 없이 컨텐츠만
                iPadAddPrayerContent
            } else {
                // iPhone: 기존 NavigationView 구조
                iPhoneAddPrayerContent
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .widgetAddPrayerWithCategory)) { notification in
            if let catRaw = notification.userInfo?["category"] as? String,
               let requestedCategory = PrayerCategory(rawValue: catRaw) {
                guard !draftEntries.isEmpty else { return }
                draftEntries[safeIdx].category = requestedCategory
                scrollToTopTrigger.toggle()
            }
        }
    }

    // MARK: - iPad Content

    @ViewBuilder
    private var iPadAddPrayerContent: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                formContent
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.xl)
            .padding(.horizontal, DesignSystem.Spacing.xl)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(DesignSystem.Colors.background)
        .onChange(of: externalRecordedText) { oldValue, newValue in
            // 사이드 패널에서 녹음된 텍스트를 활성 entry의 content에 추가
            if !newValue.isEmpty {
                guard !draftEntries.isEmpty else { return }
                if draftEntries[safeIdx].content.isEmpty {
                    draftEntries[safeIdx].content = newValue
                } else {
                    draftEntries[safeIdx].content += "\n" + newValue
                }
                externalRecordedText = ""
            }
        }
        .onAppear {
            if prayerViewModel == nil {
                prayerViewModel = PrayerViewModel(modelContext: modelContext)
            }
            initializeDraftIfNeeded()
            PrayerLogger.shared.viewDidAppear("AddPrayerView")
            PrayerLogger.shared.logMemoryUsage()
        }
        .alert(L.Alert.notification, isPresented: $showingAlert) {
            Button(L.Button.confirm) { }
        } message: {
            Text(alertMessage)
        }
        .alert(L.Alert.saveComplete, isPresented: $showingSuccessAlert) {
            Button(L.Button.confirm) { }
        } message: {
            Text(L.Success.saveMessage)
        }
        .fullScreenCover(isPresented: $showVoiceRecordingOverlay) {
            VoiceRecordingOverlay(
                speechManager: speechManager,
                onUseText: { text in
                    guard !draftEntries.isEmpty else { return }
                    if draftEntries[safeIdx].content.isEmpty {
                        draftEntries[safeIdx].content = text
                    } else {
                        draftEntries[safeIdx].content += "\n" + text
                    }
                    showVoiceRecordingOverlay = false
                },
                onCancel: {
                    showVoiceRecordingOverlay = false
                }
            )
            .background(ClearBackgroundView())
        }
        .sheet(isPresented: $showVoicePermissionAlert) {
            VStack {
                Spacer()
                VoicePermissionAlert(
                    onOpenSettings: {
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsUrl)
                        }
                        showVoicePermissionAlert = false
                    },
                    onCancel: {
                        showVoicePermissionAlert = false
                    }
                )
                Spacer()
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showOCRResult) {
            OCRResultPreviewView(
                extractedText: $extractedText,
                onApply: { text in
                    applyExtractedText(text)
                    showOCRResult = false
                },
                onCancel: {
                    showOCRResult = false
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .overlay {
            if isExtractingText {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    VStack(spacing: DesignSystem.Spacing.md) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        Text(L.Image.extractingText)
                            .font(DesignSystem.Typography.callout)
                            .foregroundColor(.white)
                    }
                    .padding(DesignSystem.Spacing.xl)
                    .background(DesignSystem.Colors.primaryText.opacity(0.8))
                    .cornerRadius(DesignSystem.CornerRadius.large)
                }
            }
        }
    }

    // MARK: - iPhone Content

    @ViewBuilder
    private var iPhoneAddPrayerContent: some View {
        NavigationView {
            ZStack(alignment: .top) {
                // 메인 스크롤 컨텐츠
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: DesignSystem.Spacing.xl) {
                            // 헤더 공간 확보 + 스크롤 오프셋 감지
                            Color.clear.frame(height: 24)
                                .id("top")  // 스크롤 앵커
                                .overlay(alignment: .top) {
                                    ScrollOffsetDetector()
                                }

                            formContent
                                .padding(.bottom, DesignSystem.Spacing.xxxl)
                        }
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        scrollOffset = value
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onTapGesture {
                        isContentFieldFocused = false
                    }
                    .onChange(of: scrollToTopTrigger) { _, _ in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo("top", anchor: .top)
                        }
                    }
                }

                // 고정 헤더 오버레이 (iOS 전화 앱 스타일)
                VStack(spacing: 0) {
                    InlineHeader(title: L.Nav.newPrayer, showFadeGradient: true, fadeOpacity: min(1.0, max(0.0, -scrollOffset / 30.0)))
                    Spacer()
                }
                .allowsHitTesting(false)
            }
            .navigationBarHidden(true)
            .background(DesignSystem.Colors.background)
            .onAppear {
                if prayerViewModel == nil {
                    prayerViewModel = PrayerViewModel(modelContext: modelContext)
                }
                initializeDraftIfNeeded()
                PrayerLogger.shared.viewDidAppear("AddPrayerView")
                PrayerLogger.shared.logMemoryUsage()
            }
            .onDisappear {
                PrayerLogger.shared.viewDidAppear("AddPrayerView - onDisappear")
            }
            .onChange(of: selectedTab) { oldValue, newValue in
                // 기도추가 탭(1)이 선택되면 스크롤을 맨 위로 이동
                if newValue == 1 && oldValue != 1 {
                    scrollToTopTrigger.toggle()
                }
            }
            .alert(L.Alert.notification, isPresented: $showingAlert) {
                Button(L.Button.confirm) { }
            } message: {
                Text(alertMessage)
            }
            .alert(L.Alert.saveComplete, isPresented: $showingSuccessAlert) {
                Button(L.Button.confirm) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = 0
                    }
                }
            } message: {
                Text(L.Success.saveMessage)
            }
            .fullScreenCover(isPresented: $showVoiceRecordingOverlay) {
                VoiceRecordingOverlay(
                    speechManager: speechManager,
                    onUseText: { text in
                        guard !draftEntries.isEmpty else { return }
                        if draftEntries[safeIdx].content.isEmpty {
                            draftEntries[safeIdx].content = text
                        } else {
                            draftEntries[safeIdx].content += "\n" + text
                        }
                        showVoiceRecordingOverlay = false
                    },
                    onCancel: {
                        showVoiceRecordingOverlay = false
                    }
                )
                .background(ClearBackgroundView())
            }
            .sheet(isPresented: $showVoicePermissionAlert) {
                VStack {
                    Spacer()
                    VoicePermissionAlert(
                        onOpenSettings: {
                            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(settingsUrl)
                            }
                            showVoicePermissionAlert = false
                        },
                        onCancel: {
                            showVoicePermissionAlert = false
                        }
                    )
                    Spacer()
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showOCRResult) {
                OCRResultPreviewView(
                    extractedText: $extractedText,
                    onApply: { text in
                        applyExtractedText(text)
                        showOCRResult = false
                    },
                    onCancel: {
                        showOCRResult = false
                    }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            .overlay {
                if isExtractingText {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        VStack(spacing: DesignSystem.Spacing.md) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)
                            Text(L.Image.extractingText)
                                .font(DesignSystem.Typography.callout)
                                .foregroundColor(.white)
                        }
                        .padding(DesignSystem.Spacing.xl)
                        .background(DesignSystem.Colors.primaryText.opacity(0.8))
                        .cornerRadius(DesignSystem.CornerRadius.large)
                    }
                }
            }
        }
    }

    // MARK: - Form Content (Shared)

    @ViewBuilder
    private var formContent: some View {
        let accentColor = isMultiEntryMode ? activeEntry.color : DesignSystem.Colors.primary
        let idx = safeIdx

        VStack(spacing: DesignSystem.Spacing.lg) {
            // 기도대상자 선택 (다인원 지원)
            ModernCard {
                MultiTargetPicker(
                    entries: $draftEntries,
                    activeEntryIndex: $activeEntryIndex,
                    existingTargets: existingTargets
                )
                .padding(DesignSystem.Spacing.lg)
            }

            // 기도 내용 입력 (음성 녹음 버튼 포함 - iPhone만)
            ModernCard {
                VStack(spacing: DesignSystem.Spacing.md) {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        HStack {
                            Text(L.Label.prayerContent)
                                .font(DesignSystem.Typography.callout)
                                .foregroundColor(DesignSystem.Colors.primaryText)
                                .fontWeight(.medium)

                            Spacer()

                            if horizontalSizeClass == .regular {
                                HStack(spacing: DesignSystem.Spacing.xs) {
                                    Image(systemName: "arrow.left")
                                        .font(.caption2)
                                    Image(systemName: "mic.fill")
                                        .font(.caption)
                                }
                                .foregroundColor(DesignSystem.Colors.tertiaryText)
                            } else {
                                VoiceRecordingButton(isRecording: speechManager.isRecording) {
                                    startVoiceRecording()
                                }
                            }
                        }

                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $draftEntries[idx].content)
                                .font(DesignSystem.Typography.body)
                                .padding(DesignSystem.Spacing.md)
                                .scrollContentBackground(.hidden)
                                .background(DesignSystem.Colors.secondaryBackground)
                                .frame(height: 200)
                                .cornerRadius(DesignSystem.CornerRadius.medium)
                                .focused($isContentFieldFocused)
                                .overlay(
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                        .stroke(
                                            draftEntries[idx].content.isEmpty
                                                ? Color.clear
                                                : accentColor.opacity(0.7),
                                            lineWidth: 2
                                        )
                                )

                            if draftEntries[idx].content.isEmpty {
                                Text(L.Placeholder.content)
                                    .font(DesignSystem.Typography.body)
                                    .foregroundColor(DesignSystem.Colors.tertiaryText)
                                    .padding(.horizontal, DesignSystem.Spacing.md + 4)
                                    .padding(.vertical, DesignSystem.Spacing.md + 8)
                                    .allowsHitTesting(false)
                            }
                        }
                        .animation(DesignSystem.Animation.quick, value: draftEntries[idx].content.isEmpty)
                    }
                }
                .padding(DesignSystem.Spacing.lg)
            }
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                    .stroke(isMultiEntryMode ? accentColor.opacity(0.55) : Color.clear, lineWidth: 3)
            )

            // 첨부 파일 섹션
            AttachmentGallerySection(
                pendingAttachments: $draftEntries[idx].pendingAttachments,
                readOnly: false,
                maxAttachments: 10,
                onExtractText: { image in
                    extractTextFromImage(image)
                },
                onExtractAllText: {
                    extractTextFromAllImages()
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                    .stroke(isMultiEntryMode ? accentColor.opacity(0.55) : Color.clear, lineWidth: 3)
            )

            // 분류 섹션
            ModernCard {
                ModernCategoryPicker(
                    title: L.Label.category,
                    selection: $draftEntries[idx].category
                )
                .padding(DesignSystem.Spacing.lg)
            }
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                    .stroke(isMultiEntryMode ? accentColor.opacity(0.55) : Color.clear, lineWidth: 3)
            )

            // D-Day 섹션
            ModernCard {
                DDayFormSection(
                    targetDate: $draftEntries[idx].targetDate,
                    notificationEnabled: $draftEntries[idx].notificationEnabled,
                    notificationSettings: $draftEntries[idx].notificationSettings,
                    calendarEnabled: $draftEntries[idx].calendarEnabled
                )
                .padding(DesignSystem.Spacing.lg)
            }
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                    .stroke(isMultiEntryMode ? accentColor.opacity(0.55) : Color.clear, lineWidth: 3)
            )

            // 생성될 기도 제목 미리보기
            if !draftEntries[idx].content.isEmpty {
                ModernCard(
                    backgroundColor: accentColor.opacity(0.05),
                    cornerRadius: DesignSystem.CornerRadius.medium,
                    shadowStyle: DesignSystem.Shadow.small
                ) {
                    HStack(spacing: DesignSystem.Spacing.md) {
                        Image(systemName: "text.quote")
                            .font(.title3)
                            .foregroundColor(accentColor)

                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                            Text(L.Label.title)
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.secondaryText)

                            Text(generatedTitle)
                                .font(DesignSystem.Typography.callout)
                                .fontWeight(.medium)
                                .foregroundColor(DesignSystem.Colors.primaryText)
                        }

                        Spacer()
                    }
                    .padding(DesignSystem.Spacing.md)
                }
            }

            // 저장 안내
            ModernCard(
                backgroundColor: DesignSystem.Colors.wait.opacity(0.1),
                cornerRadius: DesignSystem.CornerRadius.medium,
                shadowStyle: DesignSystem.Shadow.small
            ) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    StatusIndicator(storage: .wait, size: .medium)

                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text(L.Info.saveNotice)
                            .font(DesignSystem.Typography.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.primaryText)

                        Text(L.Info.saveDescription)
                            .font(DesignSystem.Typography.caption2)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }

                    Spacer()
                }
                .padding(DesignSystem.Spacing.md)
            }

            // 저장 버튼
            ModernButton(
                title: saveButtonTitle,
                style: .primary,
                size: .large
            ) {
                savePrayers()
            }
            .disabled(saveableCount == 0)
            .opacity(saveableCount == 0 ? 0.6 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: saveableCount)
        }
        .padding(.horizontal, DesignSystem.Spacing.xl)
    }

    // MARK: - Voice Recording

    private func startVoiceRecording() {
        // 권한 확인
        if speechManager.checkPermissions() {
            // 권한이 있으면 바로 녹음 시작
            showVoiceRecordingOverlay = true
        } else {
            // 권한 요청
            speechManager.requestAllPermissions { granted in
                if granted {
                    showVoiceRecordingOverlay = true
                } else {
                    showVoicePermissionAlert = true
                }
            }
        }
    }

    // MARK: - 초기화

    private func initializeDraftIfNeeded() {
        guard draftEntries.isEmpty else { return }
        draftEntries = [PrayerDraftEntry(target: "", colorIndex: 0)]
        activeEntryIndex = 0
    }

    // MARK: - 저장

    private func savePrayers() {
        let entriesToSave = draftEntries.filter { $0.hasContent }

        guard !entriesToSave.isEmpty else {
            alertMessage = L.Validation.contentRequired
            showingAlert = true
            return
        }

        for entry in entriesToSave {
            if entry.content.count > 2000 {
                alertMessage = L.Error.contentTooLong
                showingAlert = true
                return
            }
        }

        do {
            let context = modelContext

            // 1단계: 모든 Prayer와 Attachment를 context에 insert (save 없음)
            var insertedPairs: [(Prayer, PrayerDraftEntry)] = []

            for entry in entriesToSave {
                let title = Prayer.generateTitle(from: entry.target, category: entry.category)
                let firstImageFileName = entry.pendingAttachments.first(where: { $0.type == .image })?.fileName

                var finalSettings = entry.notificationSettings
                finalSettings.isEnabled = entry.notificationEnabled

                let prayer = Prayer(
                    title: title,
                    content: entry.content.trimmingCharacters(in: .whitespacesAndNewlines),
                    category: entry.category,
                    target: entry.target.trimmingCharacters(in: .whitespacesAndNewlines),
                    targetDate: entry.targetDate,
                    notificationEnabled: entry.notificationEnabled,
                    notificationSettings: finalSettings,
                    imageFileName: firstImageFileName
                )
                modelContext.insert(prayer)

                for (index, pending) in entry.pendingAttachments.enumerated() {
                    let attachment = Attachment(
                        fileName: pending.fileName,
                        originalName: pending.originalName,
                        type: pending.type,
                        fileSize: pending.fileSize,
                        order: index
                    )
                    prayer.addAttachment(attachment)
                }

                insertedPairs.append((prayer, entry))
            }

            // 2단계: 모든 항목을 한 번에 저장
            try modelContext.save()

            // 3단계: 저장 완료 후 알림/캘린더/로그 처리
            for (prayer, entry) in insertedPairs {
                PrayerLogger.shared.prayerCreated(title: prayer.title)

                if entry.notificationEnabled {
                    if let date = entry.targetDate {
                        NotificationManager.shared.scheduleNotifications(for: prayer, targetDate: date)
                    } else {
                        NotificationManager.shared.scheduleRecurringNotifications(for: prayer, settings: prayer.notificationSettings)
                    }
                }

                if entry.calendarEnabled, let date = entry.targetDate {
                    #if DEBUG
                    print("📅 캘린더 이벤트 추가 시작: date=\(date)")
                    #endif
                    CalendarManager.shared.addDDayEvent(for: prayer, targetDate: date) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let eventId):
                                prayer.updateCalendarEventId(eventId)
                                try? context.save()
                                PrayerLogger.shared.userAction("캘린더 이벤트 추가 성공: \(eventId)")
                            case .failure(let error):
                                PrayerLogger.shared.dataOperationFailed("캘린더 이벤트 추가", error: error)
                            }
                        }
                    }
                }
            }

            PrayerLogger.shared.userAction("기도 저장 (\(insertedPairs.count)명)")
            updateWidgetData()
            resetForm()
            showingSuccessAlert = true

            if ReviewRequestManager.shared.recordPrayerCreated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    requestReview()
                    ReviewRequestManager.shared.didRequestReview()
                }
            }

        } catch {
            alertMessage = L.Error.saveFailed
            showingAlert = true
            PrayerLogger.shared.prayerOperationFailed("저장", error: error)
        }
    }

    private func resetForm() {
        draftEntries = [PrayerDraftEntry(target: "", colorIndex: 0)]
        activeEntryIndex = 0
        extractedText = ""

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isContentFieldFocused = true
        }
    }

    private func updateWidgetData() {
        // 위젯 데이터 업데이트를 위해 모든 즐겨찾기 기도 다시 로드
        guard let viewModel = prayerViewModel else { return }

        let allFavorites = viewModel.favoritePrayers()
        let favoritesByStorage = Dictionary(grouping: allFavorites) { $0.storage }

        // 위젯 데이터 매니저를 통해 데이터 공유
        WidgetDataManager.shared.shareFavoritePrayersByStorage(favoritesByStorage)
    }

    // MARK: - Image OCR

    private func extractTextFromImage(_ image: UIImage) {
        isExtractingText = true

        Task {
            do {
                let text = try await ImageTextRecognizer.shared.recognizeText(from: image)
                await MainActor.run {
                    extractedText = text
                    isExtractingText = false
                    showOCRResult = true
                }
            } catch {
                await MainActor.run {
                    isExtractingText = false
                    alertMessage = error.localizedDescription
                    showingAlert = true
                }
            }
        }
    }

    private func applyExtractedText(_ text: String) {
        guard !draftEntries.isEmpty else { return }
        let idx = safeIdx
        if draftEntries[idx].content.isEmpty {
            draftEntries[idx].content = text
        } else {
            draftEntries[idx].content += "\n\n" + text
        }
    }

    // MARK: - Batch OCR

    private func extractTextFromAllImages() {
        guard !draftEntries.isEmpty else { return }
        let images = draftEntries[safeIdx].pendingAttachments
            .filter { $0.type == .image }
            .compactMap { AttachmentStorageManager.shared.loadImage(fileName: $0.fileName) }

        guard !images.isEmpty else { return }

        isExtractingText = true

        Task {
            do {
                let text = try await ImageTextRecognizer.shared.recognizeText(from: images)
                await MainActor.run {
                    extractedText = text
                    isExtractingText = false
                    showOCRResult = true
                }
            } catch {
                await MainActor.run {
                    isExtractingText = false
                    alertMessage = error.localizedDescription
                    showingAlert = true
                }
            }
        }
    }
}
