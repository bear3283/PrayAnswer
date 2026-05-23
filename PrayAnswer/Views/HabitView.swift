import SwiftUI
import SwiftData
import UserNotifications

// MARK: - 기도 습관 메인 뷰

struct HabitView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\PrayerHabit.sortOrder), SortDescriptor(\PrayerHabit.createdDate)]) private var habits: [PrayerHabit]
    // Bool == true 비교는 SwiftData Predicate에서 오동작할 수 있어 전체 fetch 후 메모리 필터링
    @Query(sort: \Prayer.createdDate, order: .reverse)
    private var allPrayers: [Prayer]

    @State private var showAddHabit = false
    @State private var editTarget: PrayerHabit?
    @State private var deleteTarget: PrayerHabit?
    @State private var showDeleteAlert = false
    @State private var reorderMode: EditMode = .inactive
    @State private var notificationAuthStatus: Bool = true

    private var todayHabits: [PrayerHabit] {
        habits.filter { $0.isActive && $0.isScheduledToday }
    }

    // notificationEnabled == true 인 모든 기도 (D-Day 여부 무관)
    private var activePrayerNotifications: [Prayer] {
        allPrayers.filter { $0.notificationEnabled }
    }

    private var hasContent: Bool {
        !habits.isEmpty || !activePrayerNotifications.isEmpty
    }

    var body: some View {
        NavigationView {
            Group {
                if hasContent {
                    habitListContent
                } else {
                    emptyStateView
                }
            }
            .background(DesignSystem.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .environment(\.editMode, $reorderMode)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !habits.isEmpty {
                        Button(reorderMode.isEditing ? L.Button.done : L.Button.edit) {
                            withAnimation { reorderMode = reorderMode.isEditing ? .inactive : .active }
                        }
                        .foregroundColor(DesignSystem.Colors.primary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddHabit = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.primary)
                    }
                }
            }
            .sheet(isPresented: $showAddHabit) {
                HabitFormView()
            }
            .sheet(item: $editTarget) { habit in
                HabitFormView(editTarget: habit)
            }
            .alert(L.Habit.deleteConfirm, isPresented: $showDeleteAlert) {
                Button(L.Button.delete, role: .destructive) {
                    if let target = deleteTarget { deleteHabit(target) }
                }
                Button(L.Button.cancel, role: .cancel) {}
            }
            .onAppear { checkNotificationPermission() }
        }
    }

    // MARK: - 빈 상태

    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Spacer()
            Image(systemName: "clock.badge.checkmark")
                .font(.system(size: 60))
                .foregroundColor(DesignSystem.Colors.primary.opacity(0.4))

            VStack(spacing: DesignSystem.Spacing.sm) {
                Text(L.Habit.emptyTitle)
                    .font(DesignSystem.Typography.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                Text(L.Habit.emptyDescription)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }

            Button {
                showAddHabit = true
            } label: {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "plus.circle.fill")
                    Text(L.Habit.newHabit)
                }
                .font(DesignSystem.Typography.callout)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, DesignSystem.Spacing.xl)
                .padding(.vertical, DesignSystem.Spacing.md)
                .background(DesignSystem.Colors.primary)
                .cornerRadius(DesignSystem.CornerRadius.large)
            }
            .buttonStyle(PlainButtonStyle())
            Spacer()
        }
        .padding(DesignSystem.Spacing.xl)
    }

    // MARK: - 습관 목록

    private var habitListContent: some View {
        List {
            if !todayHabits.isEmpty {
                Section {
                    ForEach(todayHabits) { habit in
                        TodayHabitCard(habit: habit) {
                            toggleCheckIn(habit)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: DesignSystem.Spacing.xl, bottom: 4, trailing: DesignSystem.Spacing.xl))
                    }
                } header: {
                    Text(L.Habit.todaySection)
                        .font(DesignSystem.Typography.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                        .textCase(nil)
                        .padding(.leading, -4)
                }
            }

            Section {
                ForEach(habits) { habit in
                    HabitRowCard(habit: habit)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if !reorderMode.isEditing { editTarget = habit }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                deleteTarget = habit
                                showDeleteAlert = true
                            } label: {
                                Label(L.Button.delete, systemImage: "trash")
                            }
                            .tint(.red)
                            Button {
                                editTarget = habit
                            } label: {
                                Label(L.Button.edit, systemImage: "pencil")
                            }
                            .tint(DesignSystem.Colors.primary)
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                toggleHabitActive(habit)
                            } label: {
                                Label(
                                    habit.isActive ? "비활성화" : "활성화",
                                    systemImage: habit.isActive ? "pause.circle" : "play.circle"
                                )
                            }
                            .tint(habit.isActive ? .gray : DesignSystem.Colors.answered)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: DesignSystem.Spacing.xl, bottom: 4, trailing: DesignSystem.Spacing.xl))
                }
                .onMove(perform: reorderHabits)
            } header: {
                Text(L.Habit.allHabits)
                    .font(DesignSystem.Typography.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                    .textCase(nil)
                    .padding(.leading, -4)
            }

            // 기도 응답 알림 섹션
            prayerNotificationsSection
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(DesignSystem.Colors.background)
    }

    @ViewBuilder
    private var prayerNotificationsSection: some View {
        Section {
            if !notificationAuthStatus {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "bell.slash.fill")
                        .foregroundColor(.orange)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("알림 권한이 꺼져 있습니다")
                            .font(DesignSystem.Typography.caption)
                            .fontWeight(.medium)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                        Text("설정 앱에서 알림을 허용해주세요")
                            .font(DesignSystem.Typography.caption2)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                    Spacer()
                    Button("설정 열기") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.primary)
                }
                .padding(DesignSystem.Spacing.md)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(DesignSystem.CornerRadius.medium)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 4, leading: DesignSystem.Spacing.xl, bottom: 4, trailing: DesignSystem.Spacing.xl))
            }

            if activePrayerNotifications.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "bell.slash")
                            .font(.title2)
                            .foregroundColor(DesignSystem.Colors.tertiaryText)
                        Text("알림이 설정된 기도제목이 없습니다")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.tertiaryText)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, DesignSystem.Spacing.lg)
                    Spacer()
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 4, leading: DesignSystem.Spacing.xl, bottom: 4, trailing: DesignSystem.Spacing.xl))
            } else {
                ForEach(activePrayerNotifications) { prayer in
                    PrayerNotificationRow(prayer: prayer)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                turnOffNotification(prayer)
                            } label: {
                                Label("알림 끄기", systemImage: "bell.slash")
                            }
                            .tint(.red)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: DesignSystem.Spacing.xl, bottom: 4, trailing: DesignSystem.Spacing.xl))
                }
            }
        } header: {
            HStack {
                Text("기도 응답 알림")
                    .font(DesignSystem.Typography.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                    .textCase(nil)
                    .padding(.leading, -4)
                Spacer()
                if !activePrayerNotifications.isEmpty {
                    Text("\(activePrayerNotifications.count)개")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
            }
        }
    }

    // MARK: - Actions

    private func toggleCheckIn(_ habit: PrayerHabit) {
        let today = Calendar.current.startOfDay(for: Date())

        if let existing = habit.log(for: today) {
            existing.isCompleted.toggle()
            existing.completedAt = existing.isCompleted ? Date() : nil
        } else {
            let log = PrayerHabitLog(date: today)
            log.isCompleted = true
            log.completedAt = Date()
            log.habit = habit
            if habit.logs == nil { habit.logs = [] }; habit.logs!.append(log)
            modelContext.insert(log)
        }

        try? modelContext.save()

        // 햅틱 피드백
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    private func reorderHabits(from source: IndexSet, to destination: Int) {
        var reordered = habits
        reordered.move(fromOffsets: source, toOffset: destination)
        for (index, habit) in reordered.enumerated() {
            habit.sortOrder = index
        }
        try? modelContext.save()
    }

    private func deleteHabit(_ habit: PrayerHabit) {
        NotificationManager.shared.cancelHabitNotifications(for: habit)
        modelContext.delete(habit)
        try? modelContext.save()
    }

    private func toggleHabitActive(_ habit: PrayerHabit) {
        habit.isActive.toggle()
        if habit.isActive {
            NotificationManager.shared.scheduleHabitNotifications(for: habit)
        } else {
            NotificationManager.shared.cancelHabitNotifications(for: habit)
        }
        try? modelContext.save()
    }

    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationAuthStatus = settings.authorizationStatus == .authorized ||
                                         settings.authorizationStatus == .provisional
            }
        }
    }

    private func turnOffNotification(_ prayer: Prayer) {
        prayer.notificationEnabled = false
        NotificationManager.shared.cancelAllNotifications(for: prayer)
        try? modelContext.save()
    }
}

// MARK: - 오늘 체크인 카드

struct TodayHabitCard: View {
    let habit: PrayerHabit
    let onCheckIn: () -> Void

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // 시간
            VStack(spacing: 2) {
                Text(habit.time, style: .time)
                    .font(DesignSystem.Typography.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                    .monospacedDigit()
            }
            .frame(width: 64)

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(habit.label.isEmpty ? L.Habit.navTitle : habit.label)
                    .font(DesignSystem.Typography.callout)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.primaryText)

                if habit.currentStreak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                        Text("\(habit.currentStreak)\(L.Habit.streakDays) \(L.Habit.streakLabel)")
                            .font(DesignSystem.Typography.caption2)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                }
            }

            Spacer()

            // 체크인 버튼
            Button(action: onCheckIn) {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                    if !habit.isCompletedToday {
                        Text(L.Habit.checkInButton)
                            .font(DesignSystem.Typography.caption)
                            .fontWeight(.semibold)
                    }
                }
                .foregroundColor(habit.isCompletedToday ? DesignSystem.Colors.answered : DesignSystem.Colors.primary)
                .padding(.horizontal, habit.isCompletedToday ? 0 : DesignSystem.Spacing.md)
                .padding(.vertical, habit.isCompletedToday ? 0 : DesignSystem.Spacing.sm)
                .background(
                    habit.isCompletedToday ? Color.clear : DesignSystem.Colors.primary.opacity(0.1)
                )
                .cornerRadius(DesignSystem.CornerRadius.medium)
            }
            .buttonStyle(PlainButtonStyle())
            .animation(DesignSystem.Animation.quick, value: habit.isCompletedToday)
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.cardBackground)
        .cornerRadius(DesignSystem.CornerRadius.large)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
}

// MARK: - 습관 행 카드 (전체 목록)

struct HabitRowCard: View {
    let habit: PrayerHabit

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // 아이콘
            ZStack {
                Circle()
                    .fill(DesignSystem.Colors.primary.opacity(habit.isActive ? 0.15 : 0.07))
                    .frame(width: 44, height: 44)
                Image(systemName: "clock.fill")
                    .font(.system(size: 18))
                    .foregroundColor(habit.isActive ? DesignSystem.Colors.primary : DesignSystem.Colors.tertiaryText)
            }

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(habit.label.isEmpty ? L.Habit.navTitle : habit.label)
                    .font(DesignSystem.Typography.callout)
                    .fontWeight(.medium)
                    .foregroundColor(habit.isActive ? DesignSystem.Colors.primaryText : DesignSystem.Colors.tertiaryText)

                HStack(spacing: DesignSystem.Spacing.sm) {
                    Text(habit.time, style: .time)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .monospacedDigit()

                    Text("·")
                        .foregroundColor(DesignSystem.Colors.tertiaryText)

                    Text(habit.weekdays.displayText)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .lineLimit(1)
                }
            }

            Spacer()

            // 통계
            VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xs) {
                if habit.currentStreak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill").font(.caption2).foregroundColor(.orange)
                        Text("\(habit.currentStreak)").font(DesignSystem.Typography.caption).fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                    }
                }
                Text("\(L.Habit.totalCount) \(habit.totalCompletedCount)")
                    .font(DesignSystem.Typography.caption2)
                    .foregroundColor(DesignSystem.Colors.tertiaryText)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.cardBackground)
        .cornerRadius(DesignSystem.CornerRadius.large)
        .opacity(habit.isActive ? 1.0 : 0.6)
    }
}

// MARK: - 기도 응답 알림 행

struct PrayerNotificationRow: View {
    let prayer: Prayer

    private var dDayText: String {
        guard let target = prayer.targetDate else { return "" }
        let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: target)).day ?? 0
        if days == 0 { return "D-Day" }
        if days > 0 { return "D-\(days)" }
        return "D+\(-days)"
    }

    private var dDayColor: Color {
        guard let target = prayer.targetDate else { return DesignSystem.Colors.secondaryText }
        let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: target)).day ?? 0
        if days <= 0 { return .red }
        if days <= 3 { return .orange }
        return DesignSystem.Colors.primary
    }

    private var notificationTimeText: String {
        let s = prayer.notificationSettings
        let h = s.notificationHour
        let m = s.notificationMinute
        let period = h < 12 ? "오전" : "오후"
        let displayH = h == 0 ? 12 : (h > 12 ? h - 12 : h)
        return "\(period) \(displayH):\(String(format: "%02d", m))"
    }

    private var repeatText: String {
        prayer.notificationSettings.repeatType.displayName
    }

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // 아이콘 (D-Day 여부에 따라 색상 구분)
            ZStack {
                Circle()
                    .fill((prayer.targetDate != nil ? DesignSystem.Colors.primary : Color.orange).opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: prayer.targetDate != nil ? "bell.fill" : "bell.badge.fill")
                    .font(.system(size: 18))
                    .foregroundColor(prayer.targetDate != nil ? DesignSystem.Colors.primary : .orange)
            }

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                // 기도 대상자 + 제목
                HStack(spacing: 4) {
                    if !prayer.target.isEmpty {
                        Text(prayer.target)
                            .font(DesignSystem.Typography.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.primary)
                    }
                    Text(prayer.title.isEmpty ? prayer.content : prayer.title)
                        .font(DesignSystem.Typography.callout)
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                        .lineLimit(1)
                }

                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "bell")
                        .font(.caption2)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                    Text(notificationTimeText)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                    if prayer.notificationSettings.repeatType != .none {
                        Text("·")
                            .foregroundColor(DesignSystem.Colors.tertiaryText)
                        Text(repeatText)
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                }
            }

            Spacer()

            // D-Day 배지 (targetDate 있을 때만)
            if !dDayText.isEmpty {
                Text(dDayText)
                    .font(DesignSystem.Typography.caption)
                    .fontWeight(.bold)
                    .foregroundColor(dDayColor)
                    .padding(.horizontal, DesignSystem.Spacing.sm)
                    .padding(.vertical, 4)
                    .background(dDayColor.opacity(0.12))
                    .cornerRadius(DesignSystem.CornerRadius.small)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.cardBackground)
        .cornerRadius(DesignSystem.CornerRadius.large)
    }
}

// MARK: - 습관 생성/편집 폼

struct HabitFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var editTarget: PrayerHabit?

    @State private var label: String = ""
    @State private var time: Date = {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }()
    @State private var weekdays: WeekdaySelection = .everyday
    @State private var notificationEnabled: Bool = true

    private var isEditing: Bool { editTarget != nil }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    labelSection
                    timeSection
                    daysSection
                    notificationSection
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
                .padding(.vertical, DesignSystem.Spacing.lg)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle(isEditing ? L.Habit.editHabit : L.Habit.newHabit)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L.Button.cancel) { dismiss() }
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L.Button.save) { save() }
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.primary)
                }
            }
        }
        .onAppear { loadEditTarget() }
    }

    // MARK: - 섹션들

    private var labelSection: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("이름")
                    .font(DesignSystem.Typography.callout)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.primaryText)

                TextField(L.Habit.labelPlaceholder, text: $label)
                    .font(DesignSystem.Typography.body)
                    .padding(DesignSystem.Spacing.md)
                    .background(DesignSystem.Colors.secondaryBackground)
                    .cornerRadius(DesignSystem.CornerRadius.medium)
            }
            .padding(DesignSystem.Spacing.lg)
        }
    }

    private var timeSection: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(DesignSystem.Colors.primary)
                    Text(L.Habit.timeSectionTitle)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                }

                DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
            }
            .padding(DesignSystem.Spacing.lg)
        }
    }

    private var daysSection: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(DesignSystem.Colors.primary)
                    Text(L.Habit.daysSectionTitle)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                }

                WeekdaySelector(selection: $weekdays)

                // 미리보기
                if !weekdays.selectedDays.isEmpty {
                    Text(weekdays.displayText)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .padding(.top, DesignSystem.Spacing.xs)
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }
    }

    private var notificationSection: some View {
        ModernCard {
            Toggle(isOn: $notificationEnabled) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "bell.fill")
                        .foregroundColor(DesignSystem.Colors.primary)
                    Text(L.Habit.notificationLabel)
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                }
            }
            .tint(DesignSystem.Colors.primary)
            .padding(DesignSystem.Spacing.lg)
        }
    }

    // MARK: - Actions

    private func loadEditTarget() {
        guard let target = editTarget else { return }
        label = target.label
        time = target.time
        weekdays = target.weekdays
        notificationEnabled = target.notificationEnabled
    }

    private func save() {
        if let target = editTarget {
            target.label = label
            target.time = time
            target.weekdays = weekdays
            target.notificationEnabled = notificationEnabled
            NotificationManager.shared.scheduleHabitNotifications(for: target)
        } else {
            let habit = PrayerHabit(
                label: label,
                time: time,
                weekdays: weekdays,
                notificationEnabled: notificationEnabled
            )
            modelContext.insert(habit)
            try? modelContext.save()
            NotificationManager.shared.scheduleHabitNotifications(for: habit)
        }

        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    HabitView()
        .modelContainer(for: [PrayerHabit.self, PrayerHabitLog.self], inMemory: true)
}
