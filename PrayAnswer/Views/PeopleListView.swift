import SwiftUI
import SwiftData

struct PeopleListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allPrayers: [Prayer]
    @State private var prayerViewModel: PrayerViewModel?
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var searchText = ""
    
    // "본인" 기도 (target이 비어있는 기도들)
    private var myselfPrayers: [Prayer] {
        allPrayers.filter { $0.target.isEmpty }
    }

    // 기도대상자별 기도 목록 (본인 제외)
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

    // "본인"을 포함한 전체 표시용 타겟 목록
    private var allDisplayTargets: [String] {
        var targets: [String] = []
        // "본인"이 있으면 맨 앞에 추가
        if !myselfPrayers.isEmpty {
            targets.append("")  // 빈 문자열은 "본인"을 의미
        }
        targets.append(contentsOf: sortedTargets)
        return targets
    }

    // 표시할 항목이 있는지 확인
    private var hasAnyPrayers: Bool {
        !myselfPrayers.isEmpty || !sortedTargets.isEmpty
    }
    
    // 검색 필터링된 기도대상자 목록
    private var filteredTargets: [String] {
        if searchText.isEmpty {
            return allDisplayTargets
        } else {
            return allDisplayTargets.filter { target in
                // "본인"(빈 문자열)도 검색 대상에 포함
                if target.isEmpty {
                    return L.Target.myself.localizedCaseInsensitiveContains(searchText)
                }
                return target.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    // 특정 타겟의 기도 목록 반환 (본인 포함)
    private func prayersForTarget(_ target: String) -> [Prayer] {
        if target.isEmpty {
            return myselfPrayers
        }
        return prayersByTarget[target] ?? []
    }
    
    var body: some View {
        NavigationView {
            Group {
                if !hasAnyPrayers {
                    EmptyPeopleStateView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        // 검색바를 List 내부로 이동
                        Section {
                            SearchBar(text: $searchText, placeholder: L.Placeholder.searchPeople)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(
                            top: DesignSystem.Spacing.sm,
                            leading: DesignSystem.Spacing.lg,
                            bottom: DesignSystem.Spacing.sm,
                            trailing: DesignSystem.Spacing.lg
                        ))

                        ForEach(filteredTargets, id: \.self) { target in
                            ZStack {
                                // 투명한 NavigationLink로 네비게이션 기능만 유지
                                // "본인"(빈 문자열)인 경우 특별 처리
                                if target.isEmpty {
                                    NavigationLink(destination: MyselfPrayerListView()) {
                                        EmptyView()
                                    }
                                    .opacity(0)
                                } else {
                                    NavigationLink(destination: PersonDetailView(target: target)) {
                                        EmptyView()
                                    }
                                    .opacity(0)
                                }

                                // 실제 보이는 UI
                                PersonRowView(
                                    target: target,
                                    prayers: prayersForTarget(target),
                                    isMyself: target.isEmpty
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
            .navigationTitle(L.Nav.peopleList)
            .navigationBarTitleDisplayMode(.large)
            .background(DesignSystem.Colors.background)
            .onAppear {
                if prayerViewModel == nil {
                    prayerViewModel = PrayerViewModel(modelContext: modelContext)
                }
            }
            .alert(L.Alert.error, isPresented: $showingErrorAlert) {
                Button(L.Button.confirm) { }
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
    let isMyself: Bool

    init(target: String, prayers: [Prayer], isMyself: Bool = false) {
        self.target = target
        self.prayers = prayers
        self.isMyself = isMyself
    }

    private var displayName: String {
        isMyself ? L.Target.myself : target
    }

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
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        if isMyself {
                            Image(systemName: "person.fill")
                                .font(.caption)
                                .foregroundColor(DesignSystem.Colors.primary)
                        }

                        Text(displayName)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(isMyself ? DesignSystem.Colors.primary : .primary)
                    }

                    if let latestDate = latestDate {
                        Text(L.Date.recentPrayerFormat(DateFormatter.compact.string(from: latestDate)))
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

                    Text(L.Counter.count)
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
                .fill(isMyself ? DesignSystem.Colors.primary.opacity(0.05) : DesignSystem.Colors.secondaryBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .stroke(isMyself ? DesignSystem.Colors.primary.opacity(0.2) : Color.clear, lineWidth: 1)
        )
    }
}

// MARK: - Myself Prayer List View

struct MyselfPrayerListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Prayer> { $0.target.isEmpty },
           sort: \Prayer.createdDate,
           order: .reverse) private var myselfPrayers: [Prayer]
    @State private var prayerViewModel: PrayerViewModel?

    var body: some View {
        Group {
            if myselfPrayers.isEmpty {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    Image(systemName: "person.fill.questionmark")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)

                    Text(L.Empty.storageTitle)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(myselfPrayers) { prayer in
                        ZStack {
                            NavigationLink(destination: PrayerDetailView(prayer: prayer)) {
                                EmptyView()
                            }
                            .opacity(0)

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
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle(L.Target.myself)
        .navigationBarTitleDisplayMode(.large)
        .background(DesignSystem.Colors.background)
        .onAppear {
            if prayerViewModel == nil {
                prayerViewModel = PrayerViewModel(modelContext: modelContext)
            }
        }
    }

    private func toggleFavorite(_ prayer: Prayer) {
        guard let viewModel = prayerViewModel else { return }
        try? viewModel.toggleFavorite(prayer)
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
                Text(L.Empty.peopleTitle)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text(L.Empty.peopleDescription)
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
