import AppIntents
import SwiftData
import Foundation

// MARK: - 기도제목 추가 Intent

/// Siri에서 "PrayAnswer에 기도제목 추가해줘" 로 호출
struct AddPrayerIntent: AppIntent {
    static var title: LocalizedStringResource = "기도제목 추가"
    static var description = IntentDescription("새 기도제목을 PrayAnswer에 추가합니다")

    @Parameter(title: "기도 내용")
    var content: String

    @Parameter(title: "기도 대상 (선택)")
    var target: String?

    static var parameterSummary: some ParameterSummary {
        Summary("'\(\.$content)' 기도제목 추가") {
            \.$target
        }
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let schema = Schema([
            Prayer.self,
            Attachment.self,
            PrayerCollection.self,
            PrayerHabit.self,
            PrayerHabitLog.self
        ])
        let container = try ModelContainer(for: schema)
        let context = ModelContext(container)

        let prayerTarget = target?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let title = Prayer.generateTitle(from: prayerTarget, category: .personal)

        let prayer = Prayer(
            title: title,
            content: content.trimmingCharacters(in: .whitespacesAndNewlines),
            category: .personal,
            target: prayerTarget
        )
        context.insert(prayer)
        try context.save()

        let confirmMsg = prayerTarget.isEmpty
            ? "'\(content)'이(가) 추가되었습니다."
            : "'\(prayerTarget)'을(를) 위한 기도가 추가되었습니다."

        return .result(dialog: IntentDialog(stringLiteral: confirmMsg))
    }
}

// MARK: - 기도 습관 체크인 Intent

/// Siri에서 "오늘 기도 완료" 로 호출
struct CheckInPrayerHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "기도 완료 체크"
    static var description = IntentDescription("오늘의 기도 습관을 완료로 표시합니다")

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let schema = Schema([
            Prayer.self,
            Attachment.self,
            PrayerCollection.self,
            PrayerHabit.self,
            PrayerHabitLog.self
        ])
        let container = try ModelContainer(for: schema)
        let context = ModelContext(container)

        let today = Calendar.current.startOfDay(for: Date())
        let todayWeekday = Calendar.current.component(.weekday, from: Date())

        let descriptor = FetchDescriptor<PrayerHabit>(
            predicate: #Predicate { $0.isActive }
        )
        let habits = try context.fetch(descriptor)

        var checkedIn = 0
        for habit in habits {
            guard habit.weekdays.selectedDays.contains(todayWeekday) else { continue }

            let alreadyLogged = habit.logs.contains {
                Calendar.current.startOfDay(for: $0.date) == today && $0.isCompleted
            }
            guard !alreadyLogged else { continue }

            let log = PrayerHabitLog(date: today)
            log.isCompleted = true
            log.completedAt = Date()
            log.habit = habit
            habit.logs.append(log)
            context.insert(log)
            checkedIn += 1
        }

        try context.save()

        let msg = checkedIn > 0
            ? "오늘의 기도 \(checkedIn)개를 완료했습니다. 🙏"
            : "오늘의 기도 습관이 이미 완료되었습니다."

        return .result(dialog: IntentDialog(stringLiteral: msg))
    }
}

// MARK: - App Shortcuts (Siri 자동 등록)

struct PrayAnswerShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddPrayerIntent(),
            phrases: [
                "\(.applicationName)에 기도제목 추가",
                "\(.applicationName)에 기도 추가해줘",
                "\(.applicationName) 기도제목 적어줘"
            ],
            shortTitle: "기도제목 추가",
            systemImageName: "hands.clap.fill"
        )
        AppShortcut(
            intent: CheckInPrayerHabitIntent(),
            phrases: [
                "\(.applicationName) 오늘 기도 완료",
                "\(.applicationName) 기도 체크",
                "\(.applicationName) 기도했어"
            ],
            shortTitle: "기도 완료",
            systemImageName: "checkmark.circle.fill"
        )
    }
}
