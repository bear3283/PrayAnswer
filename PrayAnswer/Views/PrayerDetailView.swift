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
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    private var compactDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy.MM.dd HH:mm"
        return formatter
    }
    
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
                    EmptyView()
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
        prayer.updateContent(title: editedTitle, content: editedContent, category: editedCategory, target: editedTarget)
        
        do {
            try modelContext.save()
            PrayerLogger.shared.prayerUpdated(title: prayer.title)
            PrayerLogger.shared.userAction("기도 수정")
            withAnimation(DesignSystem.Animation.standard) {
                isEditing = false
            }
        } catch {
            PrayerLogger.shared.prayerOperationFailed("수정", error: error)
        }
    }
    
    private func deletePrayer() {
        modelContext.delete(prayer)
        
        do {
            try modelContext.save()
            PrayerLogger.shared.prayerDeleted(title: prayer.title)
            PrayerLogger.shared.userAction("기도 삭제")
            presentationMode.wrappedValue.dismiss()
        } catch {
            PrayerLogger.shared.prayerOperationFailed("삭제", error: error)
        }
    }
    
    private func movePrayerToStorage(_ newStorage: PrayerStorage) {
        prayer.moveToStorage(newStorage)
        
        do {
            try modelContext.save()
            PrayerLogger.shared.prayerMoved(title: prayer.title, to: newStorage)
            PrayerLogger.shared.userAction("기도 보관소 이동")
        } catch {
            PrayerLogger.shared.prayerOperationFailed("이동", error: error)
        }
    }
} 