import SwiftUI
import SwiftData

struct PrayerDetailView: View {
    let prayer: Prayer
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var isEditing = false
    @State private var editedContent = ""
    @State private var editedCategory: PrayerCategory = .personal
    @State private var editedTarget = ""
    @State private var editedTargetDate: Date? = nil
    @State private var editedNotificationEnabled: Bool = false
    @State private var editedNotificationSettings: NotificationSettings = NotificationSettings()
    @State private var editedCalendarEventId: String? = nil
    @State private var showingStoragePicker = false
    @State private var showingDeleteAlert = false
    @State private var prayerViewModel: PrayerViewModel?
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var showingCalendarPermissionAlert = false
    @State private var showingCalendarSuccessAlert = false
    @State private var calendarAlertMessage = ""
    @State private var isCalendarLoading = false

    // 기존 기도대상자 목록
    private var existingTargets: [String] {
        prayerViewModel?.allTargets() ?? []
    }

    // 편집 시 자동 생성될 제목
    private var editedGeneratedTitle: String {
        Prayer.generateTitle(from: editedTarget, category: editedCategory)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    if isEditing {
                        // 편집 모드 UI
                        editingView
                    } else {
                        // 보기 모드 UI
                        viewingView
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
                .padding(.bottom, DesignSystem.Spacing.xxxl)
                .adaptiveFrame(sizeClass: horizontalSizeClass, maxWidth: DesignSystem.AdaptiveLayout.maxDetailWidth)
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(isEditing ? L.Nav.prayerEdit : L.Nav.prayerDetail)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isEditing)
        .background(DesignSystem.Colors.background)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isEditing {
                    Button(L.Button.done) {
                        saveChanges()
                    }
                    .disabled(editedContent.isEmpty)
                    .foregroundColor(DesignSystem.Colors.primary)
                    .fontWeight(.semibold)
                } else {
                    FavoriteButton(isFavorite: prayer.isFavorite) {
                        toggleFavorite()
                    }
                }
            }

            if isEditing {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L.Button.cancel) {
                        cancelEditing()
                    }
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                }
            }
        }
        .onAppear {
            if prayerViewModel == nil {
                prayerViewModel = PrayerViewModel(modelContext: modelContext)
            }
        }
        .sheet(isPresented: $showingStoragePicker) {
            ModernStoragePickerView(
                currentStorage: prayer.storage,
                onStorageSelected: { newStorage in
                    movePrayerToStorage(newStorage)
                    showingStoragePicker = false
                }
            )
        }
        .alert(L.Alert.deletePrayer, isPresented: $showingDeleteAlert) {
            Button(L.Button.delete, role: .destructive) {
                deletePrayer()
            }
            Button(L.Button.cancel, role: .cancel) { }
        } message: {
            Text(L.Confirm.deletePrayer)
        }
        .alert(L.Alert.error, isPresented: $showingErrorAlert) {
            Button(L.Button.confirm) { }
        } message: {
            Text(errorMessage)
        }
        .alert(L.Calendar.permissionRequired, isPresented: $showingCalendarPermissionAlert) {
            Button(L.Calendar.openSettings) {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button(L.Button.cancel, role: .cancel) { }
        } message: {
            Text(L.Calendar.permissionMessage)
        }
        .alert(L.Alert.notification, isPresented: $showingCalendarSuccessAlert) {
            Button(L.Button.confirm) { }
        } message: {
            Text(calendarAlertMessage)
        }
    }

    // MARK: - Viewing Mode View

    @ViewBuilder
    private var viewingView: some View {
        // 제목과 카테고리 섹션
        ModernCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            Text(L.Label.title)
                                .font(DesignSystem.Typography.callout)
                                .foregroundColor(DesignSystem.Colors.primaryText)
                                .fontWeight(.medium)

                            Text(prayer.title)
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(DesignSystem.Colors.primaryText)
                                .padding(DesignSystem.Spacing.md)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(minHeight: 48)
                                .background(DesignSystem.Colors.secondaryBackground)
                                .cornerRadius(DesignSystem.CornerRadius.medium)
                        }

                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            Text(L.Label.category)
                                .font(DesignSystem.Typography.callout)
                                .foregroundColor(DesignSystem.Colors.primaryText)
                                .fontWeight(.medium)

                            CategoryTag(category: prayer.category, size: .medium)
                                .padding(.top, DesignSystem.Spacing.sm)
                        }
                    }
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }

        // 내용 섹션
        ModernCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text(L.Label.prayerContent)
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                        .fontWeight(.medium)

                    ScrollView {
                        Text(prayer.content)
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                            .lineSpacing(4)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .padding(DesignSystem.Spacing.md)
                    }
                    .frame(height: 200)
                    .background(DesignSystem.Colors.secondaryBackground)
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }

        // 기도 대상자 섹션
        if !prayer.target.isEmpty {
            ModernCard {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text(L.Label.prayerTarget)
                            .font(DesignSystem.Typography.callout)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                            .fontWeight(.medium)

                        HStack(spacing: DesignSystem.Spacing.md) {
                            Image(systemName: "person.fill")
                                .font(.title3)
                                .foregroundColor(DesignSystem.Colors.secondary)

                            Text(prayer.target)
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(DesignSystem.Colors.primaryText)
                                .padding(DesignSystem.Spacing.md)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(minHeight: 48)
                                .background(DesignSystem.Colors.secondaryBackground)
                                .cornerRadius(DesignSystem.CornerRadius.medium)
                        }
                    }
                }
                .padding(DesignSystem.Spacing.lg)
            }
        }

        // D-Day 섹션 (보기 모드)
        if prayer.hasTargetDate {
            ModernCard {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text(L.DDay.title)
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                        .fontWeight(.medium)

                    HStack(spacing: DesignSystem.Spacing.md) {
                        // D-Day 배지
                        DDayBadge(prayer: prayer, size: .large)

                        Spacer()

                        // 목표 날짜
                        if let targetDate = prayer.targetDate {
                            VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xs) {
                                Text(L.DDay.targetDate)
                                    .font(DesignSystem.Typography.caption2)
                                    .foregroundColor(DesignSystem.Colors.tertiaryText)

                                Text(DateFormatter.compact.string(from: targetDate))
                                    .font(DesignSystem.Typography.callout)
                                    .fontWeight(.medium)
                                    .foregroundColor(DesignSystem.Colors.primaryText)
                            }
                        }
                    }
                    .padding(DesignSystem.Spacing.md)
                    .background(DesignSystem.Colors.secondaryBackground)
                    .cornerRadius(DesignSystem.CornerRadius.medium)

                    // 알림 상태
                    if prayer.notificationEnabled {
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            Image(systemName: "bell.fill")
                                .font(.caption)
                                .foregroundColor(DesignSystem.Colors.primary)

                            Text(L.DDay.notificationDescription)
                                .font(DesignSystem.Typography.caption2)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                        }
                        .padding(.horizontal, DesignSystem.Spacing.sm)
                    }

                    // 캘린더 추가/삭제 버튼
                    calendarActionButton
                }
                .padding(DesignSystem.Spacing.lg)
            }
        }

        // 기도 정보 카드
        ModernPrayerInfoCard(prayer: prayer)

        // 액션 버튼들
        VStack(spacing: DesignSystem.Spacing.md) {
            ModernButton(
                title: L.Button.moveStorage,
                style: .primary,
                size: .large
            ) {
                showingStoragePicker = true
            }

            HStack(spacing: DesignSystem.Spacing.md) {
                ModernButton(
                    title: L.Button.edit,
                    style: .secondary,
                    size: .medium
                ) {
                    startEditing()
                }

                ModernButton(
                    title: L.Button.delete,
                    style: .destructive,
                    size: .medium
                ) {
                    showingDeleteAlert = true
                }
            }
        }
    }

    // MARK: - Editing Mode View

    @ViewBuilder
    private var editingView: some View {
        // 기도대상자 선택
        ModernCard {
            TargetPicker(
                selectedTarget: $editedTarget,
                existingTargets: existingTargets
            )
            .padding(DesignSystem.Spacing.lg)
        }

        // 내용 편집
        ModernCard {
            VStack(spacing: DesignSystem.Spacing.md) {
                ModernTextEditor(
                    title: L.Label.prayerContent,
                    text: $editedContent,
                    placeholder: L.Placeholder.content
                )
            }
            .padding(DesignSystem.Spacing.lg)
        }

        // 카테고리 선택
        ModernFormSection(title: L.Label.classification) {
            VStack(spacing: DesignSystem.Spacing.md) {
                ModernCategoryPicker(
                    title: L.Label.category,
                    selection: $editedCategory
                )
            }
        }

        // D-Day 섹션 (편집 모드)
        ModernCard {
            DDayFormSection(
                targetDate: $editedTargetDate,
                notificationEnabled: $editedNotificationEnabled,
                notificationSettings: $editedNotificationSettings,
                calendarEventId: $editedCalendarEventId,
                prayer: prayer
            )
            .padding(DesignSystem.Spacing.lg)
        }

        // 생성될 제목 미리보기
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

                    Text(editedGeneratedTitle)
                        .font(DesignSystem.Typography.callout)
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                }

                Spacer()
            }
            .padding(DesignSystem.Spacing.md)
        }
    }

    private func startEditing() {
        editedContent = prayer.content
        editedCategory = prayer.category
        editedTarget = prayer.target
        editedTargetDate = prayer.targetDate
        editedNotificationEnabled = prayer.notificationEnabled
        editedNotificationSettings = prayer.notificationSettings
        editedCalendarEventId = prayer.calendarEventId
        withAnimation(.easeInOut(duration: 0.3)) {
            isEditing = true
        }
    }

    private func cancelEditing() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isEditing = false
        }
        editedContent = ""
        editedCategory = .personal
        editedTarget = ""
        editedTargetDate = nil
        editedNotificationEnabled = false
        editedNotificationSettings = NotificationSettings()
        editedCalendarEventId = nil
    }

    private func saveChanges() {
        guard let viewModel = prayerViewModel else {
            showError(L.Error.updateFailed)
            return
        }

        // 입력 검증
        guard !editedContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showError(L.Validation.contentRequired)
            return
        }

        // 길이 검증
        if editedContent.count > 2000 {
            showError(L.Error.contentTooLong)
            return
        }

        do {
            // 알림 설정 동기화
            var finalSettings = editedNotificationSettings
            finalSettings.isEnabled = editedNotificationEnabled

            // 제목을 자동 생성하여 업데이트
            try viewModel.updatePrayer(
                prayer,
                title: editedGeneratedTitle,
                content: editedContent.trimmingCharacters(in: .whitespacesAndNewlines),
                category: editedCategory,
                target: editedTarget.trimmingCharacters(in: .whitespacesAndNewlines),
                targetDate: editedTargetDate,
                notificationEnabled: editedNotificationEnabled,
                notificationSettings: finalSettings
            )

            // 캘린더 이벤트 ID 업데이트
            if prayer.calendarEventId != editedCalendarEventId {
                prayer.updateCalendarEventId(editedCalendarEventId)
            }

            PrayerLogger.shared.userAction("기도 수정")
            withAnimation(DesignSystem.Animation.standard) {
                isEditing = false
            }
        } catch {
            showError(L.Error.updatePrayerFailed)
            PrayerLogger.shared.prayerOperationFailed("수정", error: error)
        }
    }

    private func deletePrayer() {
        guard let viewModel = prayerViewModel else {
            showError(L.Error.deleteFailed)
            return
        }

        // 캘린더 이벤트도 함께 삭제
        if let eventId = prayer.calendarEventId {
            CalendarManager.shared.removeEvent(withIdentifier: eventId) { _ in
                // 캘린더 이벤트 삭제 결과와 관계없이 기도 삭제 진행
            }
        }

        do {
            try viewModel.deletePrayer(prayer)
            PrayerLogger.shared.userAction("기도 삭제")
            presentationMode.wrappedValue.dismiss()
        } catch {
            showError(L.Error.deletePrayerFailed)
            PrayerLogger.shared.prayerOperationFailed("삭제", error: error)
        }
    }

    private func movePrayerToStorage(_ newStorage: PrayerStorage) {
        guard let viewModel = prayerViewModel else {
            showError(L.Error.moveFailed)
            return
        }

        do {
            try viewModel.movePrayer(prayer, to: newStorage)
            PrayerLogger.shared.userAction("기도 보관소 이동")
        } catch {
            showError(L.Error.movePrayerFailed)
            PrayerLogger.shared.prayerOperationFailed("이동", error: error)
        }
    }

    private func toggleFavorite() {
        guard let viewModel = prayerViewModel else {
            showError(L.Error.favoriteFailed)
            return
        }

        do {
            try viewModel.toggleFavorite(prayer)
        } catch {
            showError(L.Error.favoriteToggleFailed)
            PrayerLogger.shared.prayerOperationFailed("즐겨찾기 토글", error: error)
        }
    }

    private func showError(_ message: String) {
        errorMessage = message
        showingErrorAlert = true
    }

    // MARK: - Calendar Integration (View Mode)

    @ViewBuilder
    private var calendarActionButton: some View {
        if let targetDate = prayer.targetDate {
            Button(action: {
                handleCalendarAction(targetDate: targetDate)
            }) {
                HStack {
                    if isCalendarLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: prayer.isAddedToCalendar ? "calendar.badge.checkmark" : "calendar.badge.plus")
                            .font(.title3)
                            .foregroundColor(prayer.isAddedToCalendar ? DesignSystem.Colors.answered : DesignSystem.Colors.primary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(prayer.isAddedToCalendar ? L.Calendar.addedToCalendar : L.Calendar.addToCalendar)
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.primaryText)

                        if prayer.isAddedToCalendar {
                            Text(L.Calendar.removeFromCalendar)
                                .font(DesignSystem.Typography.caption2)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.tertiaryText)
                }
                .padding(DesignSystem.Spacing.md)
                .background(prayer.isAddedToCalendar ? DesignSystem.Colors.answered.opacity(0.1) : DesignSystem.Colors.secondaryBackground)
                .cornerRadius(DesignSystem.CornerRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                        .stroke(prayer.isAddedToCalendar ? DesignSystem.Colors.answered.opacity(0.3) : Color.clear, lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isCalendarLoading)
        }
    }

    private func handleCalendarAction(targetDate: Date) {
        if prayer.isAddedToCalendar, let eventId = prayer.calendarEventId {
            // 캘린더에서 삭제
            isCalendarLoading = true
            CalendarManager.shared.removeEvent(withIdentifier: eventId) { result in
                isCalendarLoading = false
                switch result {
                case .success:
                    prayer.updateCalendarEventId(nil)
                    try? modelContext.save()
                    calendarAlertMessage = L.Calendar.removeSuccess
                    showingCalendarSuccessAlert = true
                case .failure(let error):
                    calendarAlertMessage = error.localizedDescription ?? L.Calendar.removeFailed
                    showingCalendarSuccessAlert = true
                }
            }
        } else {
            // 캘린더에 추가
            if !CalendarManager.shared.hasCalendarAccess {
                CalendarManager.shared.requestAccess { granted, _ in
                    if granted {
                        addToCalendar(targetDate: targetDate)
                    } else {
                        showingCalendarPermissionAlert = true
                    }
                }
            } else {
                addToCalendar(targetDate: targetDate)
            }
        }
    }

    private func addToCalendar(targetDate: Date) {
        isCalendarLoading = true
        CalendarManager.shared.addDDayEvent(for: prayer, targetDate: targetDate, addReminder: prayer.notificationEnabled) { result in
            isCalendarLoading = false
            switch result {
            case .success(let eventId):
                prayer.updateCalendarEventId(eventId)
                try? modelContext.save()
                calendarAlertMessage = L.Calendar.addSuccess
                showingCalendarSuccessAlert = true
            case .failure(let error):
                if case .permissionDenied = error {
                    showingCalendarPermissionAlert = true
                } else {
                    calendarAlertMessage = error.localizedDescription ?? L.Calendar.addFailed
                    showingCalendarSuccessAlert = true
                }
            }
        }
    }
}
