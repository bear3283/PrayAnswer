import SwiftUI
import SwiftData

struct AddPrayerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Binding var selectedTab: Int
    @State private var content = ""
    @State private var category: PrayerCategory = .personal
    @State private var target = ""
    @State private var targetDate: Date? = nil
    @State private var notificationEnabled: Bool = false
    @State private var notificationSettings: NotificationSettings = NotificationSettings()
    @State private var showingAlert = false
    @State private var showingSuccessAlert = false
    @State private var alertMessage = ""
    @State private var prayerViewModel: PrayerViewModel?
    @FocusState private var isContentFieldFocused: Bool

    // Voice Recording
    @State private var showVoiceRecordingOverlay = false
    @State private var showVoicePermissionAlert = false
    private var speechManager: SpeechRecognitionManager

    // Image Attachment
    @State private var selectedImage: UIImage?
    @State private var imageFileName: String?
    @State private var showOCRResult = false
    @State private var extractedText = ""
    @State private var isExtractingText = false

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
            // 사이드 패널에서 녹음된 텍스트를 content에 추가
            if !newValue.isEmpty {
                if content.isEmpty {
                    content = newValue
                } else {
                    content += "\n" + newValue
                }
                // 텍스트 사용 후 초기화
                externalRecordedText = ""
            }
        }
        .onAppear {
            if prayerViewModel == nil {
                prayerViewModel = PrayerViewModel(modelContext: modelContext)
            }
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
                    if content.isEmpty {
                        content = text
                    } else {
                        content += "\n" + text
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
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        // 헤더 공간 확보 (기도대상자 탭과 동일한 높이)
                        Color.clear.frame(height: 24)

                        formContent
                            .padding(.bottom, DesignSystem.Spacing.xxxl)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .onTapGesture {
                    isContentFieldFocused = false
                }

                // 고정 헤더 오버레이 (iOS 전화 앱 스타일)
                VStack(spacing: 0) {
                    InlineHeader(title: L.Nav.newPrayer, showFadeGradient: true)
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
                PrayerLogger.shared.viewDidAppear("AddPrayerView")
                PrayerLogger.shared.logMemoryUsage()
            }
            .onDisappear {
                PrayerLogger.shared.viewDidAppear("AddPrayerView - onDisappear")
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
                        if content.isEmpty {
                            content = text
                        } else {
                            content += "\n" + text
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
        VStack(spacing: DesignSystem.Spacing.lg) {
            // 기도대상자 선택
            ModernCard {
                TargetPicker(
                    selectedTarget: $target,
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

                            // iPad에서는 사이드 패널에서 녹음하므로 안내 표시
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
                            TextEditor(text: $content)
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
                                            content.isEmpty ? Color.clear : DesignSystem.Colors.primary.opacity(0.3),
                                            lineWidth: 1
                                        )
                                )

                            if content.isEmpty {
                                Text(L.Placeholder.content)
                                    .font(DesignSystem.Typography.body)
                                    .foregroundColor(DesignSystem.Colors.tertiaryText)
                                    .padding(.horizontal, DesignSystem.Spacing.md + 4)
                                    .padding(.vertical, DesignSystem.Spacing.md + 8)
                                    .allowsHitTesting(false)
                            }
                        }
                        .animation(DesignSystem.Animation.quick, value: content.isEmpty)
                    }
                }
                .padding(DesignSystem.Spacing.lg)
            }

            // 이미지 첨부 섹션
            ImageAttachmentSection(
                selectedImage: $selectedImage,
                imageFileName: $imageFileName,
                onExtractText: { image in
                    extractTextFromImage(image)
                }
            )

            // 분류 섹션
            ModernFormSection(title: L.Label.classification) {
                VStack(spacing: DesignSystem.Spacing.md) {
                    ModernCategoryPicker(
                        title: L.Label.category,
                        selection: $category
                    )
                }
            }

            // D-Day 섹션
            ModernCard {
                DDayFormSection(
                    targetDate: $targetDate,
                    notificationEnabled: $notificationEnabled,
                    notificationSettings: $notificationSettings
                )
                .padding(DesignSystem.Spacing.lg)
            }

            // 생성될 기도 제목 미리보기
            if !content.isEmpty {
                ModernCard(
                    backgroundColor: DesignSystem.Colors.primary.opacity(0.05),
                    cornerRadius: DesignSystem.CornerRadius.medium,
                    shadowStyle: DesignSystem.Shadow.small
                ) {
                    HStack(spacing: DesignSystem.Spacing.md) {
                        Image(systemName: "text.quote")
                            .font(.title3)
                            .foregroundColor(DesignSystem.Colors.primary)

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
                title: L.Button.savePrayer,
                style: .primary,
                size: .large
            ) {
                savePrayer()
            }
            .disabled(content.isEmpty)
            .opacity(content.isEmpty ? 0.6 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: content.isEmpty)
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

    // 자동 생성된 제목
    private var generatedTitle: String {
        Prayer.generateTitle(from: target, category: category)
    }

    private func savePrayer() {
        // 입력 검증
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = L.Validation.contentRequired
            showingAlert = true
            return
        }

        // 길이 검증
        if content.count > 2000 {
            alertMessage = L.Error.contentTooLong
            showingAlert = true
            return
        }

        // PrayerViewModel을 사용하여 기도 저장
        guard let viewModel = prayerViewModel else {
            alertMessage = L.Error.generic
            showingAlert = true
            return
        }

        do {
            // 알림 설정 동기화
            var finalSettings = notificationSettings
            finalSettings.isEnabled = notificationEnabled

            // 기도 저장 (제목은 자동 생성)
            let prayer = try viewModel.addPrayer(
                title: generatedTitle,
                content: content.trimmingCharacters(in: .whitespacesAndNewlines),
                category: category,
                target: target.trimmingCharacters(in: .whitespacesAndNewlines),
                targetDate: targetDate,
                notificationEnabled: notificationEnabled,
                notificationSettings: finalSettings,
                imageFileName: imageFileName
            )

            // D-Day 알림 스케줄링
            if notificationEnabled, let date = targetDate {
                NotificationManager.shared.scheduleNotifications(for: prayer, targetDate: date)
            }

            PrayerLogger.shared.userAction("기도 저장")

            // 위젯 데이터 업데이트
            updateWidgetData()

            // 폼 초기화
            resetForm()

            // 성공 메시지 표시
            showingSuccessAlert = true

        } catch {
            alertMessage = L.Error.saveFailed
            showingAlert = true
            PrayerLogger.shared.prayerOperationFailed("저장", error: error)
        }
    }

    private func resetForm() {
        content = ""
        category = .personal
        target = ""
        targetDate = nil
        notificationEnabled = false
        notificationSettings = NotificationSettings()

        // 이미지 관련 상태 초기화 (파일은 이미 저장되었으므로 삭제하지 않음)
        selectedImage = nil
        imageFileName = nil
        extractedText = ""

        // 폼 초기화 후 내용 필드에 다시 포커스
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
        if content.isEmpty {
            content = text
        } else {
            content += "\n\n" + text
        }
    }
}
