import SwiftUI

/// 알림 세부설정 화면
struct NotificationSettingsView: View {
    @Binding var settings: NotificationSettings
    @Environment(\.presentationMode) var presentationMode

    @State private var showTimePicker = false
    @State private var showWeekdayPicker = false
    @State private var tempTime = Date()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    // 알림 활성화 토글
                    enableToggleSection

                    if settings.isEnabled {
                        // 알림 시간 설정
                        timeSettingsSection

                        // D-Day 알림 일정
                        reminderDaysSection

                        // 반복 설정
                        repeatSettingsSection

                        // 미리보기
                        previewSection
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
                .padding(.vertical, DesignSystem.Spacing.lg)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle(L.Notification.settings)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L.Button.cancel) {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L.Button.done) {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.primary)
                }
            }
        }
    }

    // MARK: - Enable Toggle Section

    private var enableToggleSection: some View {
        ModernCard {
            Toggle(isOn: $settings.isEnabled) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    Image(systemName: settings.isEnabled ? "bell.fill" : "bell.slash")
                        .font(.title2)
                        .foregroundColor(settings.isEnabled ? DesignSystem.Colors.primary : DesignSystem.Colors.secondaryText)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text(L.DDay.enableNotification)
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(DesignSystem.Colors.primaryText)

                        Text(settings.isEnabled ? L.Notification.preview : L.DDay.notificationDescription)
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                }
            }
            .tint(DesignSystem.Colors.primary)
            .padding(DesignSystem.Spacing.lg)
        }
        .animation(DesignSystem.Animation.standard, value: settings.isEnabled)
    }

    // MARK: - Time Settings Section

    private var timeSettingsSection: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                // 섹션 헤더
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(DesignSystem.Colors.primary)
                    Text(L.Notification.timeSettings)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                }

                // 시간 선택 버튼
                Button(action: {
                    tempTime = settings.notificationTime
                    showTimePicker = true
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                            Text(L.Notification.notificationTime)
                                .font(DesignSystem.Typography.callout)
                                .foregroundColor(DesignSystem.Colors.secondaryText)

                            Text(settings.timeDisplayText)
                                .font(DesignSystem.Typography.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(DesignSystem.Colors.primaryText)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.tertiaryText)
                    }
                    .padding(DesignSystem.Spacing.md)
                    .background(DesignSystem.Colors.secondaryBackground)
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(DesignSystem.Spacing.lg)
        }
        .sheet(isPresented: $showTimePicker) {
            TimePickerSheet(
                selectedTime: $tempTime,
                onSave: {
                    settings.notificationTime = tempTime
                }
            )
        }
    }

    // MARK: - Reminder Days Section

    private var reminderDaysSection: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                // 섹션 헤더
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundColor(DesignSystem.Colors.primary)
                    Text(L.Notification.scheduleSettings)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                }

                Text(L.Notification.reminderDays)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)

                // D-Day 알림 일정 선택
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: DesignSystem.Spacing.sm) {
                    ForEach(NotificationSettings.availableReminderDays, id: \.self) { day in
                        ReminderDayButton(
                            day: day,
                            isSelected: settings.isReminderDaySelected(day),
                            onTap: {
                                withAnimation(DesignSystem.Animation.quick) {
                                    settings.toggleReminderDay(day)
                                }
                            }
                        )
                    }
                }

                // 선택된 일정 표시
                if !settings.reminderDays.isEmpty {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(DesignSystem.Colors.answered)
                            .font(.caption)

                        Text(settings.reminderDaysDisplayText)
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                    .padding(.top, DesignSystem.Spacing.xs)
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }
    }

    // MARK: - Repeat Settings Section

    private var repeatSettingsSection: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                // 섹션 헤더
                HStack {
                    Image(systemName: "repeat")
                        .foregroundColor(DesignSystem.Colors.primary)
                    Text(L.Notification.repeatSettings)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                }

                // 반복 유형 선택
                VStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(NotificationRepeatType.allCases, id: \.self) { type in
                        RepeatTypeButton(
                            type: type,
                            isSelected: settings.repeatType == type,
                            onTap: {
                                withAnimation(DesignSystem.Animation.quick) {
                                    settings.repeatType = type
                                    if type == .weekdays {
                                        settings.customWeekdays = .weekdays
                                    } else if type == .daily {
                                        settings.customWeekdays = .everyday
                                    }
                                }
                            }
                        )
                    }
                }

                // 사용자 지정 요일 선택 (repeatType == .custom일 때)
                if settings.repeatType == .custom {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text(L.Notification.selectWeekdays)
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.secondaryText)

                        WeekdaySelector(selection: $settings.customWeekdays)
                    }
                    .padding(.top, DesignSystem.Spacing.sm)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }
        .animation(DesignSystem.Animation.standard, value: settings.repeatType)
    }

    // MARK: - Preview Section

    private var previewSection: some View {
        ModernCard(
            backgroundColor: DesignSystem.Colors.primary.opacity(0.05),
            shadowStyle: DesignSystem.Shadow.small
        ) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack {
                    Image(systemName: "eye")
                        .foregroundColor(DesignSystem.Colors.primary)
                    Text(L.Notification.preview)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                }

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    // 시간 미리보기
                    PreviewRow(
                        icon: "clock.fill",
                        title: L.Notification.notificationTime,
                        value: settings.timeDisplayText
                    )

                    // 일정 미리보기
                    PreviewRow(
                        icon: "calendar",
                        title: L.Notification.reminderDays,
                        value: settings.reminderDaysDisplayText
                    )

                    // 반복 미리보기
                    PreviewRow(
                        icon: "repeat",
                        title: L.Notification.repeatType,
                        value: settings.repeatDisplayText
                    )
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }
    }
}

// MARK: - Supporting Views

/// D-Day 알림 일정 버튼
struct ReminderDayButton: View {
    let day: Int
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(day == 0 ? "D-Day" : "D-\(day)")
                .font(DesignSystem.Typography.caption)
                .fontWeight(isSelected ? .bold : .medium)
                .foregroundColor(isSelected ? .white : DesignSystem.Colors.primaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(
                    isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.secondaryBackground
                )
                .cornerRadius(DesignSystem.CornerRadius.small)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                        .stroke(
                            isSelected ? DesignSystem.Colors.primary : Color.clear,
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// 반복 유형 버튼
struct RepeatTypeButton: View {
    let type: NotificationRepeatType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(type.displayName)
                        .font(DesignSystem.Typography.callout)
                        .fontWeight(isSelected ? .semibold : .regular)
                        .foregroundColor(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.primaryText)

                    Text(type.description)
                        .font(DesignSystem.Typography.caption2)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(DesignSystem.Colors.primary)
                }
            }
            .padding(DesignSystem.Spacing.md)
            .background(
                isSelected ? DesignSystem.Colors.primary.opacity(0.1) : DesignSystem.Colors.secondaryBackground
            )
            .cornerRadius(DesignSystem.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .stroke(
                        isSelected ? DesignSystem.Colors.primary.opacity(0.3) : Color.clear,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// 요일 선택기
struct WeekdaySelector: View {
    @Binding var selection: WeekdaySelection

    private let weekdays: [(keyPath: WritableKeyPath<WeekdaySelection, Bool>, name: String, shortName: String)] = [
        (\.sunday, L.Weekday.sunday, L.Weekday.sundayShort),
        (\.monday, L.Weekday.monday, L.Weekday.mondayShort),
        (\.tuesday, L.Weekday.tuesday, L.Weekday.tuesdayShort),
        (\.wednesday, L.Weekday.wednesday, L.Weekday.wednesdayShort),
        (\.thursday, L.Weekday.thursday, L.Weekday.thursdayShort),
        (\.friday, L.Weekday.friday, L.Weekday.fridayShort),
        (\.saturday, L.Weekday.saturday, L.Weekday.saturdayShort)
    ]

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(0..<7, id: \.self) { index in
                let weekday = weekdays[index]
                WeekdayButton(
                    name: weekday.shortName,
                    isSelected: selection[keyPath: weekday.keyPath],
                    onTap: {
                        selection[keyPath: weekday.keyPath].toggle()
                    }
                )
            }
        }
    }
}

/// 요일 버튼
struct WeekdayButton: View {
    let name: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(name)
                .font(DesignSystem.Typography.caption2)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? .white : DesignSystem.Colors.primaryText)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.secondaryBackground)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// 미리보기 행
struct PreviewRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(DesignSystem.Colors.primary)
                .frame(width: 16)

            Text(title)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.secondaryText)

            Spacer()

            Text(value)
                .font(DesignSystem.Typography.caption)
                .fontWeight(.medium)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .lineLimit(1)
        }
        .padding(.vertical, DesignSystem.Spacing.xs)
    }
}

/// 시간 선택 시트
struct TimePickerSheet: View {
    @Binding var selectedTime: Date
    let onSave: () -> Void
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                // 헤더
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 50))
                        .foregroundColor(DesignSystem.Colors.primary)

                    Text(L.Notification.selectTime)
                        .font(DesignSystem.Typography.title2)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                }
                .padding(.top, DesignSystem.Spacing.xl)

                // 시간 피커
                DatePicker(
                    "",
                    selection: $selectedTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()

                Spacer()
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle(L.Notification.notificationTime)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L.Button.cancel) {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L.Button.done) {
                        onSave()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.primary)
                }
            }
        }
    }
}
