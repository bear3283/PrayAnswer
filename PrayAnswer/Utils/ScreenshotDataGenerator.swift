//
//  ScreenshotDataGenerator.swift
//  PrayAnswer
//
//  스크린샷 촬영용 더미 데이터 생성기
//  ⚠️ 앱 스토어 배포 전에 이 파일의 코드 호출을 제거하세요
//

import Foundation
import SwiftData

#if DEBUG
/// 스크린샷용 샘플 기도 데이터 생성기
enum ScreenshotDataGenerator {

    /// 스크린샷용 샘플 데이터 생성
    /// - Parameter modelContext: SwiftData ModelContext
    static func generateSampleData(in modelContext: ModelContext) {
        // 기존 데이터 삭제
        clearAllData(in: modelContext)

        // 샘플 기도 데이터 생성
        let prayers = createSamplePrayers()

        for prayer in prayers {
            modelContext.insert(prayer)
        }

        try? modelContext.save()
        print("✅ 스크린샷용 샘플 데이터 \(prayers.count)개 생성 완료")
    }

    /// 모든 기도 데이터 삭제
    static func clearAllData(in modelContext: ModelContext) {
        do {
            try modelContext.delete(model: Prayer.self)
            try modelContext.save()
            print("🗑️ 기존 데이터 삭제 완료")
        } catch {
            print("❌ 데이터 삭제 실패: \(error)")
        }
    }

    /// 샘플 기도 목록 생성
    private static func createSamplePrayers() -> [Prayer] {
        var prayers: [Prayer] = []

        // MARK: - 기다림 (Wait) 기도들

        // 1. 가족을 위한 기도 - D-Day 임박
        let prayer1 = Prayer(
            title: Prayer.generateTitle(from: "엄마", category: .health),
            content: "사랑하는 엄마의 건강을 위해 기도합니다. 무릎 수술이 잘 되고 빠르게 회복되어 다시 건강하게 걸을 수 있기를 간절히 기도합니다. 하나님, 엄마의 손을 잡아주세요.",
            category: .health,
            target: "엄마",
            storage: .wait,
            isFavorite: true,
            targetDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()),
            notificationEnabled: true
        )
        prayers.append(prayer1)

        // 2. 직장을 위한 기도
        let prayer2 = Prayer(
            title: Prayer.generateTitle(from: "", category: .work),
            content: "이번 프로젝트가 성공적으로 마무리되길 기도합니다. 팀원들과 좋은 협력으로 최선의 결과를 낼 수 있도록 지혜를 주세요. 어려운 상황에서도 평안함을 잃지 않게 해주세요.",
            category: .work,
            target: "",
            storage: .wait,
            isFavorite: false,
            targetDate: Calendar.current.date(byAdding: .day, value: 14, to: Date()),
            notificationEnabled: true
        )
        prayers.append(prayer2)

        // 3. 친구를 위한 기도
        let prayer3 = Prayer(
            title: Prayer.generateTitle(from: "지현", category: .relationship),
            content: "친구 지현이의 결혼 생활을 위해 기도합니다. 부부가 서로를 더 깊이 이해하고 사랑하며, 어려운 시간을 함께 이겨낼 수 있는 힘을 주세요.",
            category: .relationship,
            target: "지현",
            storage: .wait,
            isFavorite: true,
            targetDate: nil,
            notificationEnabled: false
        )
        prayers.append(prayer3)

        // 4. 비전을 위한 기도
        let prayer4 = Prayer(
            title: Prayer.generateTitle(from: "", category: .vision),
            content: "하나님이 제게 주신 꿈을 이룰 수 있도록 인도해주세요. 두려움을 이기고 담대하게 나아갈 수 있는 믿음을 주시고, 제 삶을 통해 주님의 영광이 드러나게 해주세요.",
            category: .vision,
            target: "",
            storage: .wait,
            isFavorite: true,
            targetDate: Calendar.current.date(byAdding: .month, value: 3, to: Date()),
            notificationEnabled: true
        )
        prayers.append(prayer4)

        // 5. 아버지를 위한 기도
        let prayer5 = Prayer(
            title: Prayer.generateTitle(from: "아빠", category: .health),
            content: "아버지의 건강 검진 결과가 좋게 나오길 기도합니다. 늘 가족을 위해 애쓰시는 아버지께 건강과 평안을 허락해주세요.",
            category: .health,
            target: "아빠",
            storage: .wait,
            isFavorite: false,
            targetDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()),
            notificationEnabled: true
        )
        prayers.append(prayer5)

        // 6. 교회를 위한 기도
        let prayer6 = Prayer(
            title: Prayer.generateTitle(from: "", category: .other),
            content: "우리 교회가 지역사회에 빛과 소금이 되길 기도합니다. 청년부 사역이 부흥하고, 많은 젊은이들이 하나님을 만나게 해주세요.",
            category: .other,
            target: "",
            storage: .wait,
            isFavorite: false,
            targetDate: nil,
            notificationEnabled: false
        )
        prayers.append(prayer6)

        // MARK: - 응답 (Yes) 기도들

        // 7. 응답받은 취업 기도
        let prayer7 = Prayer(
            title: Prayer.generateTitle(from: "동생", category: .work),
            content: "동생의 취업을 위해 기도했습니다. 하나님, 동생에게 맞는 좋은 직장을 허락해주셔서 감사합니다! 새로운 시작을 축복해주세요.",
            category: .work,
            target: "동생",
            storage: .yes,
            isFavorite: true,
            targetDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()),
            notificationEnabled: false
        )
        prayers.append(prayer7)

        // 8. 응답받은 시험 기도
        let prayer8 = Prayer(
            title: Prayer.generateTitle(from: "", category: .personal),
            content: "자격증 시험 합격을 위해 기도했습니다. 열심히 준비한 만큼 좋은 결과를 주셔서 감사합니다. 이 능력으로 더 많은 사람들을 섬기겠습니다.",
            category: .personal,
            target: "",
            storage: .yes,
            isFavorite: true,
            targetDate: Calendar.current.date(byAdding: .day, value: -14, to: Date()),
            notificationEnabled: false
        )
        prayers.append(prayer8)

        // 9. 응답받은 건강 기도
        let prayer9 = Prayer(
            title: Prayer.generateTitle(from: "할머니", category: .health),
            content: "할머니의 회복을 위해 기도했습니다. 수술이 잘 되고 빠르게 회복되셔서 정말 감사합니다. 앞으로도 건강하게 지켜주세요.",
            category: .health,
            target: "할머니",
            storage: .yes,
            isFavorite: false,
            targetDate: nil,
            notificationEnabled: false
        )
        prayers.append(prayer9)

        // 10. 응답받은 감사 기도
        let prayer10 = Prayer(
            title: Prayer.generateTitle(from: "", category: .thanksgiving),
            content: "올 한 해 동안 저와 가족을 지켜주신 하나님께 감사드립니다. 어려운 시간도 있었지만, 모든 순간 함께해주셔서 감사합니다.",
            category: .thanksgiving,
            target: "",
            storage: .yes,
            isFavorite: true,
            targetDate: nil,
            notificationEnabled: false
        )
        prayers.append(prayer10)

        // MARK: - 묵묵부답 (No) 기도들

        // 11. 아직 응답 없는 기도
        let prayer11 = Prayer(
            title: Prayer.generateTitle(from: "삼촌", category: .health),
            content: "삼촌의 투병 생활을 위해 기도했습니다. 아직 응답이 없지만, 하나님의 뜻을 신뢰합니다. 삼촌에게 평안을 주세요.",
            category: .health,
            target: "삼촌",
            storage: .no,
            isFavorite: false,
            targetDate: nil,
            notificationEnabled: false
        )
        prayers.append(prayer11)

        // 12. 다른 방식의 응답
        let prayer12 = Prayer(
            title: Prayer.generateTitle(from: "", category: .work),
            content: "원하던 회사에 입사하고 싶었지만, 다른 길로 인도하셨습니다. 지금 돌아보니 더 좋은 곳에서 일하게 되어 감사합니다.",
            category: .work,
            target: "",
            storage: .no,
            isFavorite: false,
            targetDate: nil,
            notificationEnabled: false
        )
        prayers.append(prayer12)

        // MARK: - 추가 기도들 (다양성을 위해)

        // 13. 자녀를 위한 기도
        let prayer13 = Prayer(
            title: Prayer.generateTitle(from: "아들", category: .personal),
            content: "사랑하는 아들이 올바른 길로 성장하길 기도합니다. 좋은 친구들을 만나고, 건강하고 지혜로운 사람이 되게 해주세요.",
            category: .personal,
            target: "아들",
            storage: .wait,
            isFavorite: true,
            targetDate: nil,
            notificationEnabled: false
        )
        prayers.append(prayer13)

        // 14. 배우자를 위한 기도
        let prayer14 = Prayer(
            title: Prayer.generateTitle(from: "남편", category: .work),
            content: "남편의 새로운 사업이 잘 되길 기도합니다. 지혜와 분별력을 주시고, 좋은 동역자들을 만나게 해주세요.",
            category: .work,
            target: "남편",
            storage: .wait,
            isFavorite: true,
            targetDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()),
            notificationEnabled: true
        )
        prayers.append(prayer14)

        // 15. 나라를 위한 기도
        let prayer15 = Prayer(
            title: Prayer.generateTitle(from: "", category: .other),
            content: "우리나라의 평화와 화합을 위해 기도합니다. 지도자들에게 지혜를 주시고, 국민들이 서로 사랑하며 살아가게 해주세요.",
            category: .other,
            target: "",
            storage: .wait,
            isFavorite: false,
            targetDate: nil,
            notificationEnabled: false
        )
        prayers.append(prayer15)

        // 날짜 조정 (createdDate를 다양하게)
        adjustCreatedDates(prayers)

        return prayers
    }

    /// 생성 날짜를 6개월에 걸쳐 분산 (통계 차트용)
    private static func adjustCreatedDates(_ prayers: [Prayer]) {
        let calendar = Calendar.current
        // 6개월치 고르게 분산: 월별 2-3개씩
        let daysAgo = [-168, -150, -130, -112, -95, -80, -65, -50, -38, -25, -14, -7, -4, -2, 0]

        for (index, prayer) in prayers.enumerated() {
            let offset = index < daysAgo.count ? daysAgo[index] : -(index * 5)
            if let newDate = calendar.date(byAdding: .day, value: offset, to: Date()) {
                prayer.createdDate = newDate
            }
        }
    }
}
#endif
