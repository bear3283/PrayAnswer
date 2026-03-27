import SwiftUI
import SwiftData

// MARK: - 기도 습관 메인 뷰

struct HabitView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PrayerHabit.createdDate) private var habits: [PrayerHabit]

    @State private var showAddHabit = false
    @State private var editTarget: PrayerHabit?
    @State private var deleteTarget: PrayerHabit?
    @State private var showDeleteAlert = false

    private var todayHabits: [PrayerHabit] {
        habits.filter { $0.isActive && $0.isScheduledToday }
    }

    var body: some View {
        NavigationView {
            Group {
                if habits.isEmpty {
                    emptyStateView
                } else {
                    habitListContent
                }
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle(L.Habit.navTitle)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
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
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                // 오늘의 기도 시간 섹션
                if !todayHabits.isEmpty {
                    todaySection
                }

                // 전체 습관 섹션
                allHabitsSection
            }
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .padding(.vertical, DesignSystem.Spacing.lg)
        }
    }

    // MARK: - 오늘 섹션

    private var todaySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text(L.Habit.todaySection)
                .font(DesignSystem.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.primaryText)

            VStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(todayHabits) { habit in
                    TodayHabitCard(habit: habit) {
                        toggleCheckIn(habit)
                    }
                }
            }
        }
    }

    // MARK: - 전체 습관 섹션

    private var allHabitsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text(L.Habit.allHabits)
                .font(DesignSystem.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.primaryText)

            VStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(habits) { habit in
                    HabitRowCard(habit: habit)
                        .contextMenu {
                            Button {
                                editTarget = habit
                            } label: {
                                Label(L.Button.edit, systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                deleteTarget = habit
                                showDeleteAlert = true
                            } label: {
                                Label(L.Button.delete, systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                deleteTarget = habit
                                showDeleteAlert = true
                            } label: {
                                Label(L.Button.delete, systemImage: "trash")
                            }
                            Button {
                                editTarget = habit
                            } label: {
                                Label(L.Button.edit, systemImage: "pencil")
                            }
                            .tint(DesignSystem.Colors.primary)
                        }
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
            habit.logs.append(log)
            modelContext.insert(log)
        }

        try? modelContext.save()

        // 햅틱 피드백
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    private func deleteHabit(_ habit: PrayerHabit) {
        NotificationManager.shared.cancelHabitNotifications(for: habit)
        modelContext.delete(habit)
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
