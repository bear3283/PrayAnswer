//
//  ScreenshotDataGenerator.swift
//  PrayAnswer
//
//  스크린샷 촬영용 더미 데이터 생성기 (DEBUG 전용)
//

import Foundation
import SwiftData

#if DEBUG
enum ScreenshotDataGenerator {

    // MARK: - Public

    static func generateSampleData(in modelContext: ModelContext) {
        clearAllData(in: modelContext)

        let collections = createCollections()
        for c in collections { modelContext.insert(c) }

        let prayers = createPrayers(collections: collections)
        for p in prayers { modelContext.insert(p) }

        let habits = createHabits()
        for h in habits { modelContext.insert(h) }

        try? modelContext.save()
        print("✅ 더미 데이터 생성 완료 — 기도 \(prayers.count)개 / 컬렉션 \(collections.count)개 / 습관 \(habits.count)개")
    }

    static func clearAllData(in modelContext: ModelContext) {
        try? modelContext.delete(model: PrayerHabitLog.self)
        try? modelContext.delete(model: PrayerHabit.self)
        try? modelContext.delete(model: Prayer.self)
        try? modelContext.delete(model: PrayerCollection.self)
        try? modelContext.save()
        print("🗑️ 기존 데이터 삭제 완료")
    }

    // MARK: - Collections

    private static func createCollections() -> [PrayerCollection] {
        // colorIndex: 0=파랑, 1=민트, 2=오렌지, 3=보라, 4=핑크
        [
            PrayerCollection(name: "가족", icon: "house.fill", colorIndex: 4, sortOrder: 0),
            PrayerCollection(name: "직장·학업", icon: "briefcase.fill", colorIndex: 1, sortOrder: 1),
            PrayerCollection(name: "교회", icon: "cross.fill", colorIndex: 3, sortOrder: 2),
        ]
    }

    // MARK: - Prayers

    private static func createPrayers(collections: [PrayerCollection]) -> [Prayer] {
        let family   = collections.first { $0.name == "가족" }
        let work     = collections.first { $0.name == "직장·학업" }
        let church   = collections.first { $0.name == "교회" }

        var list: [Prayer] = []

        // ── 기다리는 기도 ──────────────────────────────────────────
        list.append(make(
            target: "엄마", category: .health, storage: .wait, favorite: true,
            content: "사랑하는 엄마의 무릎 수술이 잘 되고 빠르게 회복되기를 간절히 기도합니다. 하나님, 엄마의 손을 잡아주세요.",
            daysFromNow: 3, notify: true, collection: family
        ))
        list.append(make(
            target: "아빠", category: .health, storage: .wait, favorite: false,
            content: "아버지의 건강 검진 결과가 좋게 나오길 기도합니다. 늘 가족을 위해 애쓰시는 아버지께 건강과 평안을 허락해주세요.",
            daysFromNow: 7, notify: true, collection: family
        ))
        list.append(make(
            target: "아들", category: .personal, storage: .wait, favorite: true,
            content: "사랑하는 아들이 올바른 길로 성장하길 기도합니다. 좋은 친구들을 만나고 건강하고 지혜로운 사람이 되게 해주세요.",
            daysFromNow: nil, notify: false, collection: family
        ))
        list.append(make(
            target: "남편", category: .work, storage: .wait, favorite: true,
            content: "남편의 새로운 사업이 잘 되길 기도합니다. 지혜와 분별력을 주시고 좋은 동역자들을 만나게 해주세요.",
            daysFromNow: 30, notify: true, collection: family
        ))
        list.append(make(
            target: "지현", category: .relationship, storage: .wait, favorite: true,
            content: "친구 지현이의 결혼 생활을 위해 기도합니다. 부부가 서로를 더 깊이 이해하고 사랑하며 어려운 시간을 함께 이겨낼 수 있는 힘을 주세요.",
            daysFromNow: nil, notify: false, collection: nil
        ))
        list.append(make(
            target: "", category: .work, storage: .wait, favorite: false,
            content: "이번 프로젝트가 성공적으로 마무리되길 기도합니다. 팀원들과 좋은 협력으로 최선의 결과를 낼 수 있도록 지혜를 주세요.",
            daysFromNow: 14, notify: true, collection: work
        ))
        list.append(make(
            target: "", category: .vision, storage: .wait, favorite: true,
            content: "하나님이 제게 주신 꿈을 이룰 수 있도록 인도해주세요. 두려움을 이기고 담대하게 나아갈 수 있는 믿음을 주시고 제 삶을 통해 주님의 영광이 드러나게 해주세요.",
            daysFromNow: 90, notify: true, collection: nil
        ))
        list.append(make(
            target: "", category: .other, storage: .wait, favorite: false,
            content: "우리 교회 청년부 사역이 부흥하고 많은 젊은이들이 하나님을 만나게 해주세요.",
            daysFromNow: nil, notify: false, collection: church
        ))
        list.append(make(
            target: "", category: .other, storage: .wait, favorite: false,
            content: "우리나라의 평화와 화합을 위해 기도합니다. 지도자들에게 지혜를 주시고 국민들이 서로 사랑하며 살아가게 해주세요.",
            daysFromNow: nil, notify: false, collection: nil
        ))

        // ── 응답받은 기도 ──────────────────────────────────────────
        list.append(make(
            target: "동생", category: .work, storage: .yes, favorite: true,
            content: "동생의 취업을 위해 기도했습니다. 하나님, 동생에게 맞는 좋은 직장을 허락해주셔서 감사합니다! 새로운 시작을 축복해주세요.",
            daysFromNow: -5, notify: false, collection: family
        ))
        list.append(make(
            target: "", category: .personal, storage: .yes, favorite: true,
            content: "자격증 시험 합격을 위해 기도했습니다. 열심히 준비한 만큼 좋은 결과를 주셔서 감사합니다. 이 능력으로 더 많은 사람들을 섬기겠습니다.",
            daysFromNow: -14, notify: false, collection: work
        ))
        list.append(make(
            target: "할머니", category: .health, storage: .yes, favorite: false,
            content: "할머니의 회복을 위해 기도했습니다. 수술이 잘 되고 빠르게 회복되셔서 정말 감사합니다. 앞으로도 건강하게 지켜주세요.",
            daysFromNow: nil, notify: false, collection: family
        ))
        list.append(make(
            target: "", category: .thanksgiving, storage: .yes, favorite: true,
            content: "올 한 해 동안 저와 가족을 지켜주신 하나님께 감사드립니다. 어려운 시간도 있었지만 모든 순간 함께해주셔서 감사합니다.",
            daysFromNow: nil, notify: false, collection: nil
        ))

        // ── 묵묵부답 기도 ──────────────────────────────────────────
        list.append(make(
            target: "삼촌", category: .health, storage: .no, favorite: false,
            content: "삼촌의 투병 생활을 위해 기도했습니다. 아직 응답이 없지만 하나님의 뜻을 신뢰합니다. 삼촌에게 평안을 주세요.",
            daysFromNow: nil, notify: false, collection: family
        ))
        list.append(make(
            target: "", category: .work, storage: .no, favorite: false,
            content: "원하던 회사에 입사하고 싶었지만 다른 길로 인도하셨습니다. 지금 돌아보니 더 좋은 곳에서 일하게 되어 감사합니다.",
            daysFromNow: nil, notify: false, collection: work
        ))

        adjustCreatedDates(list)
        return list
    }

    private static func make(
        target: String,
        category: PrayerCategory,
        storage: PrayerStorage,
        favorite: Bool,
        content: String,
        daysFromNow: Int?,
        notify: Bool,
        collection: PrayerCollection?
    ) -> Prayer {
        let targetDate = daysFromNow.flatMap { Calendar.current.date(byAdding: .day, value: $0, to: Date()) }
        let prayer = Prayer(
            title: Prayer.generateTitle(from: target, category: category),
            content: content,
            category: category,
            target: target,
            storage: storage,
            isFavorite: favorite,
            targetDate: targetDate,
            notificationEnabled: notify
        )
        prayer.collection = collection
        return prayer
    }

    private static func adjustCreatedDates(_ prayers: [Prayer]) {
        let offsets = [-168, -150, -130, -112, -95, -80, -65, -50, -38, -25, -14, -10, -7, -4, -2, -1, 0]
        for (i, prayer) in prayers.enumerated() {
            let offset = i < offsets.count ? offsets[i] : -(i * 4)
            if let d = Calendar.current.date(byAdding: .day, value: offset, to: Date()) {
                prayer.createdDate = d
            }
        }
    }

    // MARK: - Habits

    private static func createHabits() -> [PrayerHabit] {
        let calendar = Calendar.current
        let today = Date()

        func time(hour: Int, minute: Int) -> Date {
            calendar.date(bySettingHour: hour, minute: minute, second: 0, of: today) ?? today
        }

        let morning = PrayerHabit(label: "아침 기도", time: time(hour: 7, minute: 0), weekdays: .everyday, notificationEnabled: true)
        let evening = PrayerHabit(label: "저녁 기도", time: time(hour: 21, minute: 30), weekdays: .weekdays, notificationEnabled: true)
        var sundayOnly = WeekdaySelection()
        sundayOnly.sunday = true
        let weekly  = PrayerHabit(label: "주일 기도", time: time(hour: 10, minute: 0), weekdays: sundayOnly, notificationEnabled: false)

        // 최근 7일 체크인 로그 (아침 기도)
        for offset in 0..<7 {
            if let logDate = calendar.date(byAdding: .day, value: -offset, to: today) {
                let log = PrayerHabitLog(date: logDate)
                log.isCompleted = (offset != 2) // 2일 전만 미완료
                log.habit = morning
                morning.logs = (morning.logs ?? []) + [log]
            }
        }

        return [morning, evening, weekly]
    }
}
#endif
