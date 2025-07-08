import SwiftUI
import SwiftData

struct PrayerDetailView: View {
    let prayer: Prayer
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isEditing = false
    @State private var editedTitle = ""
    @State private var editedContent = ""
    @State private var editedCategory: PrayerCategory = .personal
    @State private var editedTarget = ""
    @State private var showingStoragePicker = false
    @State private var showingDeleteAlert = false
    @State private var prayerViewModel: PrayerViewModel?
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // 제목과 카테고리 섹션
                    ModernCard {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            if isEditing {
                                ModernTextField(
                                    title: "제목",
                                    text: $editedTitle,
                                    placeholder: "제목을 입력하세요"
                                )
                                
                                ModernCategoryPicker(
                                    title: "카테고리",
                                    selection: $editedCategory
                                )
                            } else {
                                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                                    HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                                            Text("제목")
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
                                            Text("카테고리")
                                                .font(DesignSystem.Typography.callout)
                                                .foregroundColor(DesignSystem.Colors.primaryText)
                                                .fontWeight(.medium)
                                            
                                            CategoryTag(category: prayer.category, size: .medium)
                                                .padding(.top, DesignSystem.Spacing.sm)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(DesignSystem.Spacing.lg)
                    }
                    
                    // 내용 섹션
                    ModernCard {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            if isEditing {
                                ModernTextEditor(
                                    title: "기도 내용",
                                    text: $editedContent,
                                    placeholder: "기도 내용을 작성하세요"
                                )
                            } else {
                                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                                    Text("기도 내용")
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
                        }
                        .padding(DesignSystem.Spacing.lg)
                    }
                    
                    // 기도 대상자 섹션
                    if !prayer.target.isEmpty || isEditing {
                        ModernCard {
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                                if isEditing {
                                    ModernTextField(
                                        title: "기도 대상자",
                                        text: $editedTarget,
                                        placeholder: "기도 대상자 (선택사항)"
                                    )
                                } else {
                                    if !prayer.target.isEmpty {
                                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                                            Text("기도 대상자")
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
                                }
                            }
                            .padding(DesignSystem.Spacing.lg)
                        }
                    }
                    
                    // 기도 정보 카드
                    if !isEditing {
                        ModernPrayerInfoCard(prayer: prayer)
                    }
                    
                    // 액션 버튼들
                    if !isEditing {
                        VStack(spacing: DesignSystem.Spacing.md) {
                            ModernButton(
                                title: "보관소 이동",
                                style: .primary,
                                size: .large
                            ) {
                                showingStoragePicker = true
                            }
                            
                            HStack(spacing: DesignSystem.Spacing.md) {
                                ModernButton(
                                    title: "편집",
                                    style: .secondary,
                                    size: .medium
                                ) {
                                    startEditing()
                                }
                                
                                ModernButton(
                                    title: "삭제",
                                    style: .destructive,
                                    size: .medium
                                ) {
                                    showingDeleteAlert = true
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
                .padding(.bottom, DesignSystem.Spacing.xxxl)
            }
        }
        .navigationTitle(isEditing ? "기도 편집" : "기도 상세")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isEditing)
        .background(DesignSystem.Colors.background)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isEditing {
                    Button("완료") {
                        saveChanges()
                    }
                    .disabled(editedTitle.isEmpty || editedContent.isEmpty)
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
                    Button("취소") {
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
        .alert("기도 삭제", isPresented: $showingDeleteAlert) {
            Button("삭제", role: .destructive) {
                deletePrayer()
            }
            Button("취소", role: .cancel) { }
        } message: {
            Text("이 기도를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.")
        }
        .alert("오류", isPresented: $showingErrorAlert) {
            Button("확인") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func startEditing() {
        editedTitle = prayer.title
        editedContent = prayer.content
        editedCategory = prayer.category
        editedTarget = prayer.target
        withAnimation(.easeInOut(duration: 0.3)) {
            isEditing = true
        }
    }
    
    private func cancelEditing() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isEditing = false
        }
        editedTitle = ""
        editedContent = ""
        editedCategory = .personal
        editedTarget = ""
    }
    
    private func saveChanges() {
        guard let viewModel = prayerViewModel else {
            showError("수정 중 오류가 발생했습니다.")
            return
        }
        
        // 입력 검증
        guard !editedTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !editedContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showError("제목과 내용을 모두 입력해주세요.")
            return
        }
        
        // 길이 검증
        if editedTitle.count > 100 {
            showError("제목은 100자를 초과할 수 없습니다.")
            return
        }
        
        if editedContent.count > 2000 {
            showError("기도 내용은 2000자를 초과할 수 없습니다.")
            return
        }
        
        do {
            try viewModel.updatePrayer(
                prayer,
                title: editedTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                content: editedContent.trimmingCharacters(in: .whitespacesAndNewlines),
                category: editedCategory,
                target: editedTarget.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            
            PrayerLogger.shared.userAction("기도 수정")
            withAnimation(DesignSystem.Animation.standard) {
                isEditing = false
            }
        } catch {
            showError("기도를 수정하는 중 오류가 발생했습니다.")
            PrayerLogger.shared.prayerOperationFailed("수정", error: error)
        }
    }
    
    private func deletePrayer() {
        guard let viewModel = prayerViewModel else {
            showError("삭제 중 오류가 발생했습니다.")
            return
        }
        
        do {
            try viewModel.deletePrayer(prayer)
            PrayerLogger.shared.userAction("기도 삭제")
            presentationMode.wrappedValue.dismiss()
        } catch {
            showError("기도를 삭제하는 중 오류가 발생했습니다.")
            PrayerLogger.shared.prayerOperationFailed("삭제", error: error)
        }
    }
    
    private func movePrayerToStorage(_ newStorage: PrayerStorage) {
        guard let viewModel = prayerViewModel else {
            showError("보관소 이동 중 오류가 발생했습니다.")
            return
        }
        
        do {
            try viewModel.movePrayer(prayer, to: newStorage)
            PrayerLogger.shared.userAction("기도 보관소 이동")
        } catch {
            showError("기도를 이동하는 중 오류가 발생했습니다.")
            PrayerLogger.shared.prayerOperationFailed("이동", error: error)
        }
    }
    
    private func toggleFavorite() {
        guard let viewModel = prayerViewModel else {
            showError("즐겨찾기 변경 중 오류가 발생했습니다.")
            return
        }
        
        do {
            try viewModel.toggleFavorite(prayer)
        } catch {
            showError("즐겨찾기를 변경하는 중 오류가 발생했습니다.")
            PrayerLogger.shared.prayerOperationFailed("즐겨찾기 토글", error: error)
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showingErrorAlert = true
    }
} 