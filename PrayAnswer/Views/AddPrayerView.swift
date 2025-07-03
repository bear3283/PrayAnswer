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
                                    placeholder: "기도 제목을 입력하세요"
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
            .alert("입력 확인", isPresented: $showingAlert) {
                Button("확인") { }
            } message: {
                Text("제목과 내용을 모두 입력해주세요.")
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
        guard !title.isEmpty && !content.isEmpty else {
            showingAlert = true
            return
        }
        
        // SwiftData ModelContext를 직접 사용하여 저장
        let newPrayer = Prayer(title: title, content: content, category: category, target: target)
        modelContext.insert(newPrayer)
        
        do {
            try modelContext.save()
            PrayerLogger.shared.prayerCreated(title: title)
            PrayerLogger.shared.userAction("기도 저장")
            
            // 폼 초기화
            title = ""
            content = ""
            category = .personal
            target = ""
            
            // 성공 메시지 표시 후 기도 목록으로 이동
            showingSuccessAlert = true
            
            // 1초 후 기도 목록 탭으로 자동 이동
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(DesignSystem.Animation.standard) {
                    selectedTab = 0
                }
            }
        } catch {
            PrayerLogger.shared.prayerOperationFailed("저장", error: error)
            showingAlert = true
        }
    }
} 
