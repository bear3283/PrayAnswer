import SwiftUI
import SwiftData

struct PeopleListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allPrayers: [Prayer]
    @State private var prayerViewModel: PrayerViewModel?
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var searchText = ""
    
    // 기도대상자별 기도 목록
    private var prayersByTarget: [String: [Prayer]] {
        allPrayers.byTarget
    }
    
    // 기도대상자 목록 (최근 기도 날짜 순으로 정렬)
    private var sortedTargets: [String] {
        let targetsWithLatestDates = prayersByTarget.map { (target, prayers) in
            let latestDate = prayers.max { $0.createdDate < $1.createdDate }?.createdDate ?? Date.distantPast
            return (target: target, latestDate: latestDate)
        }
        
        return targetsWithLatestDates
            .sorted { $0.latestDate > $1.latestDate }
            .map { $0.target }
    }
    
    // 검색 필터링된 기도대상자 목록
    private var filteredTargets: [String] {
        if searchText.isEmpty {
            return sortedTargets
        } else {
            return sortedTargets.filter { target in
                target.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if sortedTargets.isEmpty {
                    EmptyPeopleStateView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // 검색바
                    SearchBar(text: $searchText, placeholder: "기도대상자 검색")
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        .padding(.vertical, DesignSystem.Spacing.sm)
                    
                    List {
                        ForEach(filteredTargets, id: \.self) { target in
                            ZStack {
                                // 투명한 NavigationLink로 네비게이션 기능만 유지
                                NavigationLink(destination: PersonDetailView(target: target)) {
                                    EmptyView()
                                }
                                .opacity(0)
                                
                                // 실제 보이는 UI
                                PersonRowView(
                                    target: target,
                                    prayers: prayersByTarget[target] ?? []
                                )
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
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("기도대상자")
            .navigationBarTitleDisplayMode(.large)
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
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showingErrorAlert = true
    }
}

// MARK: - Person Row View

struct PersonRowView: View {
    let target: String
    let prayers: [Prayer]
    
    private var totalCount: Int {
        prayers.count
    }
    
    private var waitCount: Int {
        prayers.filter { $0.storage == .wait }.count
    }
    
    private var yesCount: Int {
        prayers.filter { $0.storage == .yes }.count
    }
    
    private var noCount: Int {
        prayers.filter { $0.storage == .no }.count
    }
    
    private var latestDate: Date? {
        prayers.max { $0.createdDate < $1.createdDate }?.createdDate
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            // 대상자 이름과 총 기도 개수
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(target)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    if let latestDate = latestDate {
                        Text("최근 기도: \(DateFormatter.compact.string(from: latestDate))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // 총 기도 개수
                HStack() {
                    Text("\(totalCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.primary)
                    
                    Text("개")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // 기도 상태별 개수
            HStack(spacing: DesignSystem.Spacing.md) {
                // Wait
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 8, height: 8)
                    
                    Text("\(waitCount)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                
                // Yes
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    
                    Text("\(yesCount)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                
                // No
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                    
                    Text("\(noCount)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(DesignSystem.Colors.secondaryBackground)
        )
    }
}

// MARK: - Empty State View

struct EmptyPeopleStateView: View {
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("기도대상자가 없습니다")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("기도를 추가할 때 기도대상자를 입력하면\n여기서 확인할 수 있습니다")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(DesignSystem.Spacing.xl)
    }
}

#Preview {
    PeopleListView()
}

// MARK: - Search Bar Component

struct SearchBar: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.system(size: 16, weight: .medium))
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.primaryText)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.secondaryBackground)
        .cornerRadius(DesignSystem.CornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .stroke(
                    text.isEmpty ? Color.clear : DesignSystem.Colors.primary.opacity(0.3),
                    lineWidth: 1
                )
        )
        .animation(DesignSystem.Animation.quick, value: text.isEmpty)
    }
}
