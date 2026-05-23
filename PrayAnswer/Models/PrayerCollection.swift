import Foundation
import SwiftUI
import SwiftData

// MARK: - 기도 컬렉션 (폴더) 모델

/// 기도제목을 묶어 관리하는 폴더/컬렉션 모델.
/// 하나의 Prayer는 최대 하나의 PrayerCollection에만 속할 수 있다.
@Model
final class PrayerCollection {
    var name: String = ""
    var icon: String = "folder.fill"
    var colorIndex: Int = 0
    var createdDate: Date = Date()
    var sortOrder: Int = 0

    @Relationship(deleteRule: .nullify, inverse: \Prayer.collection)
    var prayers: [Prayer]?

    init(name: String, icon: String = "folder.fill", colorIndex: Int = 0, sortOrder: Int = 0) {
        self.name = name
        self.icon = icon
        self.colorIndex = colorIndex
        self.createdDate = Date()
        self.sortOrder = sortOrder
    }

    // MARK: - 색상 & 아이콘 팔레트

    static let colorPalette: [Color] = [
        Color(red: 0.33, green: 0.59, blue: 0.99),  // 파랑
        Color(red: 0.18, green: 0.76, blue: 0.62),  // 민트
        Color(red: 0.96, green: 0.54, blue: 0.22),  // 오렌지
        Color(red: 0.62, green: 0.41, blue: 0.88),  // 보라
        Color(red: 0.94, green: 0.33, blue: 0.52),  // 핑크
        Color(red: 0.86, green: 0.66, blue: 0.13),  // 앰버
        Color(red: 0.22, green: 0.56, blue: 0.90),  // 하늘
        Color(red: 0.44, green: 0.74, blue: 0.23),  // 초록
    ]

    static let iconOptions: [String] = [
        "folder.fill",
        "heart.fill",
        "star.fill",
        "bookmark.fill",
        "house.fill",
        "person.2.fill",
        "globe",
        "cross.fill",
        "hands.clap.fill",
        "book.fill",
        "moon.fill",
        "sun.max.fill",
        "leaf.fill",
        "flame.fill",
    ]

    var color: Color {
        Self.colorPalette[colorIndex % Self.colorPalette.count]
    }

    var prayerCount: Int { (prayers ?? []).count }
}
