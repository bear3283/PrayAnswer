import WidgetKit
import SwiftUI

// MARK: - Entry & Provider

struct AddPrayerEntry: TimelineEntry {
    let date: Date
}

struct AddPrayerProvider: TimelineProvider {
    func placeholder(in context: Context) -> AddPrayerEntry { AddPrayerEntry(date: Date()) }
    func getSnapshot(in context: Context, completion: @escaping (AddPrayerEntry) -> Void) {
        completion(AddPrayerEntry(date: Date()))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<AddPrayerEntry>) -> Void) {
        completion(Timeline(entries: [AddPrayerEntry(date: Date())], policy: .never))
    }
}

// MARK: - Design Tokens (Gemini 스타일)

private extension Color {
    /// 위젯 전체 배경 - 거의 검정에 가까운 다크 그레이
    static let widgetBackground = Color(red: 0.13, green: 0.13, blue: 0.14)
    /// 일반 원형 버튼 배경
    static let circleNormal = Color(white: 0.21)
    /// 메인 원형 버튼 배경 (좌상단)
    static let circleMain = Color(white: 0.26)
    /// 메인 원형 테두리
    static let circleBorder = Color(white: 0.38)
}

// MARK: - Gemini Style Circle Button

private struct GeminiIconCircle: View {
    let icon: String
    let isMain: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(isMain ? Color.circleMain : Color.circleNormal)
                .overlay {
                    if isMain {
                        Circle().strokeBorder(Color.circleBorder, lineWidth: 0.6)
                    }
                }

            Image(systemName: icon)
                .font(.system(size: isMain ? 28 : 22, weight: isMain ? .semibold : .medium))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Small Widget (2×2 Gemini 스타일)
// 소형 위젯: 4개의 동일한 원형 아이콘 버튼 → 전체 탭 시 기도 추가 화면으로 이동

struct SmallAddPrayerWidgetView: View {
    private let spacing: CGFloat = 9
    private let padding: CGFloat = 11

    var body: some View {
        VStack(spacing: spacing) {
            HStack(spacing: spacing) {
                // 좌상단: 앱 메인 아이콘 (Gemini처럼 강조)
                GeminiIconCircle(icon: "hands.clap.fill", isMain: true)
                // 우상단: 기도 추가
                GeminiIconCircle(icon: "square.and.pencil", isMain: false)
            }
            .frame(maxHeight: .infinity)

            HStack(spacing: spacing) {
                // 좌하단: 개인 기도
                GeminiIconCircle(icon: "person.fill", isMain: false)
                // 우하단: 가족 기도
                GeminiIconCircle(icon: "house.fill", isMain: false)
            }
            .frame(maxHeight: .infinity)
        }
        .padding(padding)
        .containerBackground(for: .widget) {
            Color.widgetBackground
        }
        .widgetURL(URL(string: "prayanswer://add")!)
    }
}

// MARK: - Medium Widget (4×2 Gemini 스타일)
// 중형 위젯: 왼쪽 큰 메인 원 + 오른쪽 2×2 카테고리 그리드

private struct MediumCategoryCircle: View {
    let icon: String
    let category: String

    var body: some View {
        Link(destination: URL(string: "prayanswer://add?category=\(category)")!) {
            GeminiIconCircle(icon: icon, isMain: false)
        }
    }
}

struct MediumAddPrayerWidgetView: View {
    private let spacing: CGFloat = 9
    private let padding: CGFloat = 11

    var body: some View {
        HStack(spacing: spacing) {
            // 왼쪽: 큰 메인 원 (앱 아이콘)
            Link(destination: URL(string: "prayanswer://add")!) {
                GeminiIconCircle(icon: "hands.clap.fill", isMain: true)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // 오른쪽: 2×2 카테고리 그리드
            VStack(spacing: spacing) {
                HStack(spacing: spacing) {
                    MediumCategoryCircle(icon: "person.fill", category: "personal")
                    MediumCategoryCircle(icon: "house.fill", category: "family")
                }
                .frame(maxHeight: .infinity)

                HStack(spacing: spacing) {
                    MediumCategoryCircle(icon: "heart.fill", category: "health")
                    MediumCategoryCircle(icon: "briefcase.fill", category: "work")
                }
                .frame(maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(padding)
        .containerBackground(for: .widget) {
            Color.widgetBackground
        }
    }
}

// MARK: - Widget Entry View

struct AddPrayerWidgetEntryView: View {
    var entry: AddPrayerEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallAddPrayerWidgetView()
        case .systemMedium:
            MediumAddPrayerWidgetView()
        default:
            SmallAddPrayerWidgetView()
        }
    }
}

// MARK: - Widget Configuration

struct AddPrayerWidget: Widget {
    let kind: String = "AddPrayerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AddPrayerProvider()) { entry in
            AddPrayerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("기도 추가")
        .description("홈 화면에서 바로 새 기도를 추가하세요.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
