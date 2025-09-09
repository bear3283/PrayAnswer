import SwiftUI
import SwiftData

struct AddPrayerView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedTab: Int
    @State private var title = ""
    @State private var content = ""
    @State private var category: PrayerCategory = .personal
    @State private var target = ""
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
                                    title: "제목",
                                    text: $title,
                                    placeholder: "기도 제목을 입력하세요",
                                    focusedField: $isTitleFieldFocused
                                )
                                
                                ModernTextEditor(
                                    title: "기도 내용",
                                    text: $content,
                                    placeholder: "마음을 담아 기도 내용을 작성하세요"
                                )
                            }
                            .padding(DesignSystem.Spacing.lg)
                        }
                        
                        // 분류 섹션
                        ModernFormSection(title: "분류") {
                            VStack(spacing: DesignSystem.Spacing.md) {
                                ModernCategoryPicker(
                                    title: "카테고리",
                                    selection: $category
                                )
                                
                                ModernTextField(
                                    title: "기도 대상자",
                                    text: $target,
                                    placeholder: "기도 대상자 (선택사항)"
                                )
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
                                    Text("저장 안내")
                                        .font(DesignSystem.Typography.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(DesignSystem.Colors.primaryText)
                                    
                                    Text("기도는 '대기중' 보관소에 저장됩니다")
                                        .font(DesignSystem.Typography.caption2)
                                        .foregroundColor(DesignSystem.Colors.secondaryText)
                                }
                                
                                Spacer()
                            }
                            .padding(DesignSystem.Spacing.md)
                        }
                        
                        // 저장 버튼
                        ModernButton(
                            title: "기도 저장하기",
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
            .navigationTitle("새로운 기도")
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
            .alert("알림", isPresented: $showingAlert) {
                Button("확인") { }
            } message: {
                Text(alertMessage)
            }
            .alert("저장 완료", isPresented: $showingSuccessAlert) {
                Button("확인") { 
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = 0
                    }
                }
            } message: {
                Text("기도가 성공적으로 저장되었습니다.\n기도 목록으로 이동합니다.")
            }
        }
    }
    
    private func savePrayer() {
        // 입력 검증
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = "제목과 내용을 모두 입력해주세요."
            showingAlert = true
            return
        }
        
        // 길이 검증
        if title.count > 100 {
            alertMessage = "제목은 100자를 초과할 수 없습니다."
            showingAlert = true
            return
        }
        
        if content.count > 2000 {
            alertMessage = "기도 내용은 2000자를 초과할 수 없습니다."
            showingAlert = true
            return
        }
        
        // PrayerViewModel을 사용하여 기도 저장
        guard let viewModel = prayerViewModel else {
            alertMessage = "저장 중 오류가 발생했습니다. 다시 시도해주세요."
            showingAlert = true
            return
        }
        
        do {
            // 기도 저장
            try viewModel.addPrayer(
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                content: content.trimmingCharacters(in: .whitespacesAndNewlines),
                category: category,
                target: target.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            
            PrayerLogger.shared.userAction("기도 저장")
            
            // 위젯 데이터 업데이트
            updateWidgetData()
            
            // 폼 초기화
            resetForm()
            
            // 성공 메시지 표시
            showingSuccessAlert = true
            
        } catch {
            alertMessage = "기도를 저장하는 중 오류가 발생했습니다.\n다시 시도해주세요."
            showingAlert = true
            PrayerLogger.shared.prayerOperationFailed("저장", error: error)
        }
    }
    
    private func resetForm() {
        title = ""
        content = ""
        category = .personal
        target = ""
        
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
