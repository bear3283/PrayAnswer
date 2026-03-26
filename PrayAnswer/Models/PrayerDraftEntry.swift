import SwiftUI

// MARK: - 다인원 기도 초안 모델

/// 여러 명의 기도 내용을 동시에 작성할 때 사용하는 초안(draft) 모델.
/// AddPrayerView에서만 사용되며, 저장 시 각각 별개의 Prayer 레코드로 변환된다.
struct PrayerDraftEntry: Identifiable {
    let id: UUID
    var target: String              // "" = 나(myself)
    var content: String
    var category: PrayerCategory
    var targetDate: Date?
    var notificationEnabled: Bool
    var notificationSettings: NotificationSettings
    var calendarEnabled: Bool
    var pendingAttachments: [PendingAttachment]

    /// 색상 팔레트 인덱스 (0 = 나/파란색, 1~6 = 추가 인원 색상)
    let colorIndex: Int

    init(target: String = "", colorIndex: Int = 0) {
        self.id = UUID()
        self.target = target
        self.content = ""
        self.category = .personal
        self.targetDate = nil
        self.notificationEnabled = false
        self.notificationSettings = NotificationSettings()
        self.calendarEnabled = false
        self.pendingAttachments = []
        self.colorIndex = colorIndex
    }

    /// 기도 내용이 있어 저장 가능한 상태인지
    var hasContent: Bool {
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// 칩에 표시할 이름 (빈 문자열이면 "나")
    var displayName: String {
        target.isEmpty ? L.Target.myself : target
    }

    // MARK: - 색상 시스템

    /// 다인원 입력 시 각 사람에게 순서대로 할당되는 색상 팔레트
    static let palette: [Color] = [
        DesignSystem.Colors.primary,                        // 0: 나 (앱 기본 파란색)
        Color(red: 0.18, green: 0.76, blue: 0.62),         // 1: 민트
        Color(red: 0.96, green: 0.54, blue: 0.22),         // 2: 오렌지
        Color(red: 0.62, green: 0.41, blue: 0.88),         // 3: 보라
        Color(red: 0.94, green: 0.33, blue: 0.52),         // 4: 핑크
        Color(red: 0.86, green: 0.66, blue: 0.13),         // 5: 앰버
        Color(red: 0.22, green: 0.56, blue: 0.90),         // 6: 하늘
    ]

    var color: Color {
        Self.palette[colorIndex % Self.palette.count]
    }
}
