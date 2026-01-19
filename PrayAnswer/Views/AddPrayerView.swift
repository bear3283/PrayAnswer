import SwiftUI
import SwiftData

struct AddPrayerView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedTab: Int
    @State private var title = ""
    @State private var content = ""
    @State private var category: PrayerCategory = .personal
    @State private var target = ""
    @State private var targetDate: Date? = nil
    @State private var notificationEnabled: Bool = false
    @State private var showingAlert = false
    @State private var showingSuccessAlert = false
    @State private var alertMessage = ""
    @State private var prayerViewModel: PrayerViewModel?
    @FocusState private var isTitleFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    
                    // 폼 섹션들
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        // 기본 입력 필드들
                        ModernCard {
                            VStack(spacing: DesignSystem.Spacing.md) {
                                ModernTextField(
                                    title: L.Label.title,
                                    text: $title,
                                    placeholder: L.Placeholder.title,
                                    focusedField: $isTitleFieldFocused
                                )

                                ModernTextEditor(
                                    title: L.Label.prayerContent,
                                    text: $content,
                                    placeholder: L.Placeholder.content
                                )
                            }
                            .padding(DesignSystem.Spacing.lg)
                        }

                        // 분류 섹션
                        ModernFormSection(title: L.Label.classification) {
                            VStack(spacing: DesignSystem.Spacing.md) {
                                ModernCategoryPicker(
                                    title: L.Label.category,
                                    selection: $category
                                )

                                ModernTextField(
                                    title: L.Label.prayerTarget,
                                    text: $target,
                                    placeholder: L.Placeholder.target
                                )
                            }
                        }

                        // D-Day 섹션
                        ModernCard {
                            DDayFormSection(
                                targetDate: $targetDate,
                                notificationEnabled: $notificationEnabled
                            )
                            .padding(DesignSystem.Spacing.lg)
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
                        .disabled(title.isEmpty || content.isEmpty)
                        .opacity(title.isEmpty || content.isEmpty ? 0.6 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: title.isEmpty || content.isEmpty)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    .padding(.top, DesignSystem.Spacing.lg)
                    .padding(.bottom, DesignSystem.Spacing.xxxl)
                }
            }
            .navigationTitle(L.Nav.newPrayer)
            .navigationBarTitleDisplayMode(.large)
            .background(DesignSystem.Colors.background)
            .onAppear {
                if prayerViewModel == nil {
                    prayerViewModel = PrayerViewModel(modelContext: modelContext)
                }
                // 화면이 나타날 때 기도제목 필드에 자동으로 포커스
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    isTitleFieldFocused = true
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
        }
    }
    
    private func savePrayer() {
        // 입력 검증
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = L.Error.emptyFields
            showingAlert = true
            return
        }

        // 길이 검증
        if title.count > 100 {
            alertMessage = L.Error.titleTooLong
            showingAlert = true
            return
        }

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
            // 기도 저장
            let prayer = try viewModel.addPrayer(
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                content: content.trimmingCharacters(in: .whitespacesAndNewlines),
                category: category,
                target: target.trimmingCharacters(in: .whitespacesAndNewlines),
                targetDate: targetDate,
                notificationEnabled: notificationEnabled
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
        title = ""
        content = ""
        category = .personal
        target = ""
        targetDate = nil
        notificationEnabled = false

        // 폼 초기화 후 기도제목 필드에 다시 포커스
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isTitleFieldFocused = true
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
} 
