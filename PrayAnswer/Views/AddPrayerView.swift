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

    // 컬렉션 (모든 entry에 공통 적용)
    @Query(sort: \PrayerCollection.sortOrder) private var collections: [PrayerCollection]
    @State private var selectedCollection: PrayerCollection? = nil

    // 부가 속성 바: 펼쳐진 항목 (한 번에 하나만)
    @State private var openAttribute: PrayerAttribute? = nil
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var showingAlert = false
    @State private var showingSuccessAlert = false
    /// 완료 표시에 쓸 저장 개수 (폼을 비운 뒤에도 유지되어야 한다)
    @State private var savedCount = 0
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
        .onReceive(NotificationCenter.default.publisher(for: .sharedPrayerTextReceived)) { notification in
            guard let text = notification.userInfo?["text"] as? String, !text.isEmpty else { return }
            guard !draftEntries.isEmpty else { return }
            // 공유된 텍스트를 현재 활성 entry의 content에 설정
            if draftEntries[safeIdx].content.isEmpty {
                draftEntries[safeIdx].content = text
            } else {
                draftEntries[safeIdx].content += "\n\n" + text
            }
            scrollToTopTrigger.toggle()
            isContentFieldFocused = true
        }
    }

    // MARK: - iPad Content

    @ViewBuilder
    private var iPadAddPrayerContent: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    formContent
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.xl)
                .padding(.horizontal, DesignSystem.Spacing.xl)
                // 내용이 화면보다 짧으면 입력창이 남는 높이를 채운다
                .frame(minHeight: geometry.size.height, alignment: .top)
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
        .overlay {
            if showingSuccessAlert {
                CompletionOverlay.saved(count: savedCount) {
                    showingSuccessAlert = false
                }
            }
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

    // MARK: - iPhone Content

    @ViewBuilder
    private var iPhoneAddPrayerContent: some View {
        NavigationView {
            ZStack(alignment: .top) {
                // 메인 스크롤 컨텐츠
                GeometryReader { geometry in
                    ScrollViewReader { scrollProxy in
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
                            // 내용이 화면보다 짧으면 입력창이 남는 높이를 채운다
                            .frame(minHeight: geometry.size.height, alignment: .top)
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
                                scrollProxy.scrollTo("top", anchor: .top)
                            }
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
            .overlay {
                if showingSuccessAlert {
                    CompletionOverlay.saved(count: savedCount) {
                        showingSuccessAlert = false
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedTab = 2
                        }
                    }
                }
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

        // 안전한 Binding<PrayerDraftEntry>: idx가 stale해도 크래시 없이 기본값 반환
        // (SwiftUI reconciliation 중 자식 뷰 binding getter가 resetForm() 이후에도 호출될 수 있음)
        let safeEntry = Binding<PrayerDraftEntry>(
            get: { idx < draftEntries.count ? draftEntries[idx] : PrayerDraftEntry() },
            set: { if idx < draftEntries.count { draftEntries[idx] = $0 } }
        )

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
                                .font(DesignSystem.Typography.title3)
                                .foregroundColor(DesignSystem.Colors.primaryText)

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
                            TextEditor(text: safeEntry.content)
                                .font(DesignSystem.Typography.body)
                                .padding(DesignSystem.Spacing.md)
                                .scrollContentBackground(.hidden)
                                .background(DesignSystem.Colors.secondaryBackground)
                                // 화면에 남는 공간을 입력창이 흡수한다 (저장 버튼은 항상 맨 아래)
                                .frame(minHeight: 200, maxHeight: .infinity)
                                .cornerRadius(DesignSystem.CornerRadius.medium)
                                .focused($isContentFieldFocused)
                                .overlay(
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                        .stroke(Color.clear, lineWidth: 0)
                                )
                                .onChange(of: safeEntry.wrappedValue.content) { oldValue, newValue in
                                    continueNumbering(from: oldValue, to: newValue)
                                }

                            if safeEntry.wrappedValue.content.isEmpty {
                                Text(L.Placeholder.content)
                                    .font(DesignSystem.Typography.body)
                                    .foregroundColor(DesignSystem.Colors.tertiaryText)
                                    .padding(.horizontal, DesignSystem.Spacing.md + 4)
                                    .padding(.vertical, DesignSystem.Spacing.md + 8)
                                    .allowsHitTesting(false)
                            }
                        }
                        .animation(DesignSystem.Animation.quick, value: safeEntry.wrappedValue.content.isEmpty)

                        // 줄바꿈 번호 매기기 (한 사람의 기도제목을 여러 개 입력할 때)
                        if safeEntry.wrappedValue.hasContent {
                            lineNumberingRow(accentColor: accentColor)
                        }
                    }
                }
                .padding(DesignSystem.Spacing.lg)
            }
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                    .stroke(isMultiEntryMode ? accentColor.opacity(0.55) : Color.clear, lineWidth: 3)
            )

            // 부가 속성 바 — 누른 항목만 아래로 펼쳐진다
            attributeBar(entry: safeEntry)

            if let open = openAttribute {
                attributePanel(open, entry: safeEntry, accentColor: accentColor)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity
                    ))
            }

            // 무엇이 어디에 저장되는지 (카드 없이 두 줄)
            saveSummary

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

    // MARK: - Save Summary

    /// 저장 가능한 초안이 딱 하나일 때 그 초안의 자동 생성 제목.
    /// 여러 명을 한꺼번에 쓰는 중이면 제목이 여러 개라 보여주지 않는다 (버튼이 인원수를 말한다).
    private var singleSaveableTitle: String? {
        let saveable = draftEntries.filter { $0.hasContent }
        guard saveable.count == 1, let entry = saveable.first else { return nil }
        return Prayer.generateTitle(from: entry.target, category: entry.category)
    }

    @ViewBuilder
    private var saveSummary: some View {
        if saveableCount > 0 {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                if let title = singleSaveableTitle {
                    Text(title)
                        .font(DesignSystem.Typography.caption)
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                        .lineLimit(1)
                }

                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 10))
                        .foregroundColor(PrayerStorage.wait.color)

                    Text(L.Info.saveDescription)
                        .font(DesignSystem.Typography.caption2)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DesignSystem.Spacing.xs)
            .accessibilityElement(children: .combine)
        }
    }

    // MARK: - Attribute Bar

    /// 컬렉션이 하나도 없으면 컬렉션 칩은 숨긴다
    private var visibleAttributes: [PrayerAttribute] {
        PrayerAttribute.allCases.filter { $0 != .collection || !collections.isEmpty }
    }

    private func toggle(_ attribute: PrayerAttribute) {
        isContentFieldFocused = false
        withAnimation(reduceMotion ? nil : DesignSystem.Animation.standard) {
            openAttribute = (openAttribute == attribute) ? nil : attribute
        }
    }

    @ViewBuilder
    private func attributeBar(entry: Binding<PrayerDraftEntry>) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(visibleAttributes) { attribute in
                    chip(for: attribute, entry: entry.wrappedValue)
                }
            }
            .padding(.horizontal, 2)   // 열린 칩 테두리가 잘리지 않도록
            .padding(.vertical, 2)
        }
    }

    @ViewBuilder
    private func chip(for attribute: PrayerAttribute, entry: PrayerDraftEntry) -> some View {
        switch attribute {
        case .attachment:
            let count = entry.pendingAttachments.count
            AttributeChip(
                icon: "paperclip",
                name: L.Attachment.sectionTitle,
                label: count > 0 ? L.AttributeBar.attachmentCount(count) : L.Attachment.sectionTitle,
                tint: DesignSystem.Colors.primary,
                isSet: count > 0,
                isOpen: openAttribute == .attachment
            ) { toggle(.attachment) }

        case .category:
            // 카테고리는 언제나 값이 있으므로 늘 제 색을 입는다
            AttributeChip(
                icon: "tag.fill",
                name: L.Label.category,
                label: entry.category.displayName,
                tint: entry.category.color,
                isSet: true,
                isOpen: openAttribute == .category
            ) { toggle(.category) }

        case .dDay:
            AttributeChip(
                icon: entry.notificationEnabled ? "calendar.badge.clock" : "calendar",
                name: L.DDay.title,
                label: entry.targetDate.map { DraftDDay.label(for: $0) } ?? L.DDay.title,
                tint: entry.targetDate.map { DraftDDay.tint(for: $0) } ?? DesignSystem.Colors.primary,
                isSet: entry.targetDate != nil,
                isOpen: openAttribute == .dDay
            ) { toggle(.dDay) }

        case .collection:
            AttributeChip(
                icon: selectedCollection?.icon ?? "folder",
                name: L.Collection.navTitle,
                label: selectedCollection?.name ?? L.Collection.navTitle,
                tint: selectedCollection?.color ?? DesignSystem.Colors.primary,
                isSet: selectedCollection != nil,
                isOpen: openAttribute == .collection
            ) { toggle(.collection) }
        }
    }

    /// 패널 테두리 색 — 다인원 모드에서는 "지금 누구의 칸인지"가 더 중요해 사람 색을 쓴다
    private func panelTint(for attribute: PrayerAttribute, entry: PrayerDraftEntry) -> Color {
        switch attribute {
        case .attachment: return DesignSystem.Colors.primary
        case .category:   return entry.category.color
        case .dDay:       return entry.targetDate.map { DraftDDay.tint(for: $0) } ?? DesignSystem.Colors.primary
        case .collection: return selectedCollection?.color ?? DesignSystem.Colors.primary
        }
    }

    @ViewBuilder
    private func attributePanel(_ attribute: PrayerAttribute, entry: Binding<PrayerDraftEntry>, accentColor: Color) -> some View {
        AttributePanel(
            tint: isMultiEntryMode ? accentColor : panelTint(for: attribute, entry: entry.wrappedValue),
            borderWidth: isMultiEntryMode ? 3 : 1.5
        ) {
            switch attribute {
            case .attachment:
                AttachmentGallerySection(
                    pendingAttachments: entry.pendingAttachments,
                    readOnly: false,
                    maxAttachments: 10,
                    onExtractText: { image in
                        extractTextFromImage(image)
                    },
                    onExtractAllText: {
                        extractTextFromAllImages()
                    },
                    embedded: true
                )

            case .category:
                ModernCategoryPicker(title: "", selection: entry.category)

            case .dDay:
                DDayFormSection(
                    targetDate: entry.targetDate,
                    notificationEnabled: entry.notificationEnabled,
                    notificationSettings: entry.notificationSettings,
                    calendarEnabled: entry.calendarEnabled,
                    showsTitle: false
                )

            case .collection:
                collectionPanel
            }
        }
    }

    // MARK: - Collection Panel

    @ViewBuilder
    private var collectionPanel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                collectionPill(
                    name: L.Collection.none,
                    icon: "tray",
                    tint: DesignSystem.Colors.secondaryText,
                    isSelected: selectedCollection == nil
                ) {
                    selectedCollection = nil
                }

                ForEach(collections) { collection in
                    collectionPill(
                        name: collection.name,
                        icon: collection.icon,
                        tint: collection.color,
                        isSelected: selectedCollection?.persistentModelID == collection.persistentModelID
                    ) {
                        selectedCollection = collection
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func collectionPill(name: String, icon: String, tint: Color, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(reduceMotion ? nil : DesignSystem.Animation.quick) {
                action()
            }
        } label: {
            HStack(spacing: DesignSystem.Spacing.xs + 2) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                Text(name)
                    .font(DesignSystem.Typography.caption)
                    .lineLimit(1)
            }
            .foregroundColor(isSelected ? .white : tint)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm + 1)
            .background(Capsule().fill(isSelected ? tint : tint.opacity(0.12)))
            .contentShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    // MARK: - Line Numbering

    /// 현재 활성 entry의 번호 상태
    private var activeNumberingState: PrayerNumberingState {
        activeEntry.content.numberingState
    }

    /// 줄바꿈 기준으로 나눈 기도제목 개수
    private var activeItemCount: Int {
        activeEntry.content.prayerLineItems.count
    }

    /// 버튼은 "지금 누르면 무슨 일이 일어나는지"를 말한다
    private var numberingButtonLabel: (icon: String, text: String) {
        switch activeNumberingState {
        case .none:       return ("list.number", L.Numbering.apply)
        case .ordered:    return ("list.bullet", L.Numbering.remove)
        case .disordered: return ("arrow.triangle.2.circlepath", L.Numbering.renumber)
        }
    }

    private var numberingHint: String {
        switch activeNumberingState {
        case .none:       return L.Numbering.hint
        case .ordered:    return L.Numbering.countHint(activeItemCount)
        case .disordered: return L.Numbering.disorderedHint
        }
    }

    @ViewBuilder
    private func lineNumberingRow(accentColor: Color) -> some View {
        let label = numberingButtonLabel

        HStack(spacing: DesignSystem.Spacing.sm) {
            Button {
                toggleLineNumbering()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: label.icon)
                        .font(.system(size: 12, weight: .semibold))
                    Text(label.text)
                        .font(DesignSystem.Typography.caption)
                        .fontWeight(.medium)
                        .lineLimit(1)
                }
                .foregroundColor(accentColor)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .background(Capsule().fill(accentColor.opacity(0.12)))
            }
            .buttonStyle(PlainButtonStyle())

            Text(numberingHint)
                .font(DesignSystem.Typography.caption2)
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .lineLimit(2)

            Spacer(minLength: 0)
        }
        .animation(DesignSystem.Animation.quick, value: activeNumberingState)
    }

    /// 번호가 매겨진 상태에서 맨 끝에 줄바꿈을 하면 다음 번호를 자동으로 이어 붙인다.
    /// 중간 줄을 편집하거나 번호가 없는 글에는 개입하지 않는다.
    private func continueNumbering(from oldValue: String, to newValue: String) {
        guard newValue.count == oldValue.count + 1,
              newValue.hasSuffix("\n"),
              String(newValue.dropLast()) == oldValue,
              oldValue.isSequentiallyNumbered,
              !draftEntries.isEmpty else { return }

        let idx = safeIdx
        guard idx < draftEntries.count else { return }

        let next = (oldValue.lastLineNumber ?? oldValue.prayerLineItems.count) + 1
        draftEntries[idx].content = newValue + "\(next). "
    }

    /// 번호 매기기 ⇄ 번호 해제 토글.
    /// 이미 번호가 있지만 순서가 어긋난 경우(줄 추가·삭제 후)에는 다시 번호를 매긴다.
    private func toggleLineNumbering() {
        guard !draftEntries.isEmpty else { return }
        let idx = safeIdx
        let current = draftEntries[idx].content

        draftEntries[idx].content = current.isSequentiallyNumbered
            ? current.numberingRemoved
            : current.numberedByLines
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
                prayer.collection = selectedCollection
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
            // 폼을 비우기 전에 개수를 기억해둔다 (완료 표시에 쓴다)
            savedCount = insertedPairs.count
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
        selectedCollection = nil
        extractedText = ""
        openAttribute = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isContentFieldFocused = true
        }
    }

    private func updateWidgetData() {
        guard let viewModel = prayerViewModel else { return }

        // fetch 직후 즉시 값 타입 변환 (Prayer @Model 참조를 외부로 전달 금지)
        let allFavorites = viewModel.favoritePrayers()
        var dataByStorage: [PrayerStorage: [PrayerWidgetData]] = [:]
        for prayer in allFavorites {
            let storage = prayer.storage
            dataByStorage[storage, default: []].append(prayer.toWidgetData())
        }
        WidgetDataManager.shared.shareFavoritePrayersByStorage(dataByStorage)
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
