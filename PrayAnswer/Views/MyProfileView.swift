import SwiftUI
import SwiftData

/// 나의 페이지 — 이름 설정 + 나의 기도제목 관리
struct MyProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var myProfile = MyProfile.shared

    @Query(filter: #Predicate<Prayer> { $0.isMyRequest == true },
           sort: \Prayer.createdDate, order: .reverse)
    private var myRequestPrayers: [Prayer]

    @Query(filter: #Predicate<Prayer> { $0.target == "" && $0.isMyRequest == false },
           sort: \Prayer.createdDate, order: .reverse)
    private var myselfPrayers: [Prayer]

    @State private var isEditingName = false
    @State private var draftName = ""
    @State private var showAddPrayer = false
    @State private var showDeleteAlert = false
    @State private var prayerToDelete: Prayer?
    @State private var prayerViewModel: PrayerViewModel?

    var body: some View {
        List {
            // 프로필 헤더
            Section {
                HStack(spacing: DesignSystem.Spacing.md) {
                    ZStack {
                        Circle()
                            .fill(DesignSystem.Colors.primary.opacity(0.15))
                            .frame(width: 56, height: 56)
                        Image(systemName: "person.fill")
                            .font(.system(size: 26))
                            .foregroundColor(DesignSystem.Colors.primary)
                    }

                    if isEditingName {
                        TextField("이름을 입력하세요", text: $draftName)
                            .font(DesignSystem.Typography.title3)
                            .submitLabel(.done)
                            .onSubmit { saveName() }
                        Button("완료") { saveName() }
                            .foregroundColor(DesignSystem.Colors.primary)
                            .fontWeight(.semibold)
                    } else {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(myProfile.name.isEmpty ? "이름을 설정해주세요" : myProfile.name)
                                .font(DesignSystem.Typography.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(myProfile.name.isEmpty
                                                 ? DesignSystem.Colors.tertiaryText
                                                 : DesignSystem.Colors.primaryText)
                            Text("나의 기도제목 \(myRequestPrayers.count)개")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                        }
                        Spacer()
                        Button {
                            draftName = myProfile.name
                            isEditingName = true
                        } label: {
                            Image(systemName: "pencil")
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                        }
                    }
                }
                .padding(.vertical, DesignSystem.Spacing.sm)
            }

            // 나의 기도제목 목록
            Section {
                ForEach(myRequestPrayers) { prayer in
                    HStack(spacing: DesignSystem.Spacing.md) {
                        Image(systemName: "hands.clap.fill")
                            .foregroundColor(prayer.category.color)
                            .frame(width: 20)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(prayer.title)
                                .font(DesignSystem.Typography.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(DesignSystem.Colors.primaryText)
                            if !prayer.content.isEmpty {
                                Text(prayer.content)
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(DesignSystem.Colors.secondaryText)
                                    .lineLimit(2)
                            }
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            prayerToDelete = prayer
                            showDeleteAlert = true
                        } label: {
                            Label("삭제", systemImage: "trash")
                        }
                    }
                }

                Button {
                    showAddPrayer = true
                } label: {
                    Label("기도제목 추가", systemImage: "plus.circle.fill")
                        .foregroundColor(DesignSystem.Colors.primary)
                        .font(DesignSystem.Typography.body)
                }
            } header: {
                Text("나의 기도제목")
            } footer: {
                Text("다른 사람이 나를 위해 기도해줄 내용을 적어두세요.")
                    .font(DesignSystem.Typography.caption2)
            }

            // 내가 드리는 기도 목록 (기존 "본인" 기도)
            if !myselfPrayers.isEmpty {
                Section {
                    ForEach(myselfPrayers) { prayer in
                        NavigationLink(destination: PrayerDetailView(prayer: prayer)) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(prayer.title)
                                    .font(DesignSystem.Typography.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(DesignSystem.Colors.primaryText)
                                if !prayer.content.isEmpty {
                                    Text(prayer.content)
                                        .font(DesignSystem.Typography.caption)
                                        .foregroundColor(DesignSystem.Colors.secondaryText)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                } header: {
                    Text("내가 드리는 기도")
                } footer: {
                    Text("대상자 없이 작성한 기도제목입니다.")
                        .font(DesignSystem.Typography.caption2)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if prayerViewModel == nil {
                prayerViewModel = PrayerViewModel(modelContext: modelContext)
            }
        }
        .sheet(isPresented: $showAddPrayer) {
            AddMyPrayerSheet()
        }
        .alert("기도제목 삭제", isPresented: $showDeleteAlert) {
            Button("삭제", role: .destructive) {
                if let prayer = prayerToDelete {
                    modelContext.delete(prayer)
                    try? modelContext.save()
                }
                prayerToDelete = nil
            }
            Button("취소", role: .cancel) { prayerToDelete = nil }
        } message: {
            Text("이 기도제목을 삭제하시겠습니까?")
        }
    }

    private func saveName() {
        myProfile.name = draftName.trimmingCharacters(in: .whitespaces)
        isEditingName = false
    }
}

// MARK: - 나의 기도제목 빠른 추가 시트

private struct AddMyPrayerSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var content = ""
    @State private var category: PrayerCategory = .personal

    var body: some View {
        NavigationStack {
            Form {
                Section("기도 제목") {
                    TextField("제목을 입력하세요", text: $title)
                }
                Section("내용 (선택)") {
                    TextField("기도 내용을 입력하세요", text: $content, axis: .vertical)
                        .lineLimit(3...6)
                }
                Section("카테고리") {
                    Picker("카테고리", selection: $category) {
                        ForEach(PrayerCategory.allCases, id: \.self) { cat in
                            Text(cat.displayName).tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle("나의 기도제목 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") { dismiss() }
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("추가") { save() }
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.primary)
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let prayer = Prayer(
            title: title.trimmingCharacters(in: .whitespaces),
            content: content.trimmingCharacters(in: .whitespaces),
            category: category,
            target: "",
            storage: .wait
        )
        prayer.isMyRequest = true
        modelContext.insert(prayer)
        try? modelContext.save()
        dismiss()
    }
}
