import SwiftUI
import SwiftData

struct PersonDetailView: View {
    let target: String
    @Environment(\.modelContext) private var modelContext
    @Query private var allPrayers: [Prayer]
    @State private var selectedStorage: PrayerStorage = .wait
    @State private var prayerViewModel: PrayerViewModel?
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    // 해당 대상자의 기도 목록
    private var targetPrayers: [Prayer] {
        allPrayers.filter { $0.target == target }
            .sorted { $0.createdDate > $1.createdDate }
    }
    
    // 선택된 보관소별 기도 목록
    private var filteredPrayers: [Prayer] {
        targetPrayers.filter { $0.storage == selectedStorage }
    }
    
    // 보관소별 기도 개수
    private var storageCounts: [PrayerStorage: Int] {
        Dictionary(grouping: targetPrayers) { $0.storage }
            .mapValues { $0.count }
    }
    
    var body: some View {
        VStack() {
            // 헤더 정보
            PersonHeaderView(
                target: target,
                totalCount: targetPrayers.count,
                storageCounts: storageCounts
            )
            .padding(.horizontal, 10)
            
            // 보관소 선택
            ModernStorageSelector(
                selectedStorage: $selectedStorage,
                allPrayers: targetPrayers
            )
            
            // 기도 목록
            List {
                if filteredPrayers.isEmpty {
                    EmptyPersonStateView(target: target, storage: selectedStorage)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                } else {
                    ForEach(filteredPrayers) { prayer in
                        ZStack {
                            // 투명한 NavigationLink로 네비게이션 기능만 유지
                            NavigationLink(destination: PrayerDetailView(prayer: prayer)) {
                                EmptyView()
                            }
                            .opacity(0)
                            
                            // 실제 보이는 UI
                            ModernPrayerRow(prayer: prayer) {
                                toggleFavorite(prayer)
                            }
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(
                            top: DesignSystem.Spacing.sm,
                            leading: DesignSystem.Spacing.md,
                            bottom: DesignSystem.Spacing.sm,
                            trailing: DesignSystem.Spacing.md
                        ))
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let prayer = filteredPrayers[index]
                            deletePrayer(prayer)
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden)
            
            Spacer()
        }
        .background(DesignSystem.Colors.background)
        .onAppear {
            if prayerViewModel == nil {
                prayerViewModel = PrayerViewModel(modelContext: modelContext)
            }
        }
        .alert("오류", isPresented: $showingErrorAlert) {
            Button("확인") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func deletePrayer(_ prayer: Prayer) {
        guard let viewModel = prayerViewModel else {
            showError("삭제 중 오류가 발생했습니다.")
            return
        }
        
        do {
            try viewModel.deletePrayer(prayer)
            PrayerLogger.shared.userAction("\(target)의 기도 삭제")
        } catch {
            showError("기도를 삭제하는 중 오류가 발생했습니다.")
            PrayerLogger.shared.prayerOperationFailed("삭제", error: error)
        }
    }
    
    private func toggleFavorite(_ prayer: Prayer) {
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

// MARK: - Person Header View

struct PersonHeaderView: View {
    let target: String
    let totalCount: Int
    let storageCounts: [PrayerStorage: Int]
    
    private var waitCount: Int { storageCounts[.wait] ?? 0 }
    private var yesCount: Int { storageCounts[.yes] ?? 0 }
    private var noCount: Int { storageCounts[.no] ?? 0 }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // 대상자 이름과 총 기도 개수
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(target)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // 기도 상태별 개수
                HStack(spacing: DesignSystem.Spacing.xl) {
                    // Wait
                    VStack(spacing: 4) {
                        Text("\(waitCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        
                        Text("대기")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Yes
                    VStack(spacing: 4) {
                        Text("\(yesCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("응답")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // No
                    VStack(spacing: 4) {
                        Text("\(noCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        
                        Text("미응답")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // 총 기도 개수 (큰 원형 배지)
                ZStack {
                    Circle()
                        .fill(DesignSystem.Colors.primary.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    HStack(spacing: 2) {
                        Text("\(totalCount)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.Colors.primary)
                        
                        Text("개")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                .fill(DesignSystem.Colors.secondaryBackground)
        )
        .padding(.horizontal, 4)
        .padding(.top, DesignSystem.Spacing.md)
    }
}

// MARK: - Empty Person State View

struct EmptyPersonStateView: View {
    let target: String
    let storage: PrayerStorage
    
    private var storageDisplayName: String {
        switch storage {
        case .wait: return "대기"
        case .yes: return "응답"
        case .no: return "미응답"
        }
    }
    
    var body: some View {
        HStack{
            Spacer()
            VStack(spacing: DesignSystem.Spacing.lg) {
                Image(systemName: "heart.slash")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)
                
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Text("\(target)의 \(storageDisplayName) 기도가 없습니다")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("다른 보관소를 선택해보세요")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(DesignSystem.Spacing.xl)
            Spacer()
        }
    }
}

#Preview {
    NavigationView {
        PersonDetailView(target: "김철수")
    }
}
