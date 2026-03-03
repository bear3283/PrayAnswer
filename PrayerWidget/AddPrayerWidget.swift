import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Entry & Provider

struct AddPrayerEntry: TimelineEntry {
    let date: Date
    let mainAction: QuickActionAppEnum
}

struct AddPrayerProvider: AppIntentTimelineProvider {
    typealias Entry = AddPrayerEntry
    typealias Intent = AddPrayerWidgetIntent

    func placeholder(in context: Context) -> AddPrayerEntry {
        AddPrayerEntry(date: Date(), mainAction: .addPrayer)
    }

    func snapshot(for configuration: AddPrayerWidgetIntent, in context: Context) async -> AddPrayerEntry {
        AddPrayerEntry(date: Date(), mainAction: configuration.mainAction)
    }

    func timeline(for configuration: AddPrayerWidgetIntent, in context: Context) async -> Timeline<AddPrayerEntry> {
        let entry = AddPrayerEntry(date: Date(), mainAction: configuration.mainAction)
        return Timeline(entries: [entry], policy: .never)
    }
}

// MARK: - Design Tokens (Gemini 스타일)

private extension Color {
    static let widgetBackground = Color(red: 0.13, green: 0.13, blue: 0.14)
    static let circleNormal = Color(white: 0.21)
    static let circleMain = Color(white: 0.26)
    static let circleBorder = Color(white: 0.38)
}

// MARK: - Gemini Style Circle

private struct GeminiCircle: View {
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
                .font(.system(size: isMain ? 26 : 20, weight: isMain ? .semibold : .medium))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Small Widget (2×2 Gemini — 메인 버튼 설정 가능)
// 소형: widgetURL 하나로 전체 탭 처리, 메인 액션으로 이동
struct SmallAddPrayerWidgetView: View {
    let mainAction: QuickActionAppEnum
    private let spacing: CGFloat = 8
    private let padding: CGFloat = 10

    // 메인 액션 외 3개의 빠른 액션 (고정)
    private let quickActions: [(icon: String, action: QuickActionAppEnum)] = [
        ("person.fill", .waitStorage),
        ("heart.fill", .favorites),
        ("chart.bar.xaxis", .statistics)
    ]

    var body: some View {
        VStack(spacing: spacing) {
            HStack(spacing: spacing) {
                // 좌상단: 설정된 메인 액션 (강조)
                GeminiCircle(icon: mainAction.icon, isMain: true)
                // 우상단: Wait 보관소
                GeminiCircle(icon: quickActions[0].icon, isMain: false)
            }
            .frame(maxHeight: .infinity)

            HStack(spacing: spacing) {
                // 좌하단: 즐겨찾기
                GeminiCircle(icon: quickActions[1].icon, isMain: false)
                // 우하단: 통계
                GeminiCircle(icon: quickActions[2].icon, isMain: false)
            }
            .frame(maxHeight: .infinity)
        }
        .padding(padding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) { Color.widgetBackground }
        .widgetURL(URL(string: mainAction.urlString)!)
    }
}

// MARK: - Medium Widget (메인 큰 원 + 2×3 그리드)
// 중형: 왼쪽 메인 Link + 오른쪽 3×2 빠른 액션 Link 그리드

private struct MediumQuickCircle: View {
    let icon: String
    let urlString: String

    var body: some View {
        Link(destination: URL(string: urlString)!) {
            GeminiCircle(icon: icon, isMain: false)
        }
    }
}

struct MediumAddPrayerWidgetView: View {
    let mainAction: QuickActionAppEnum
    private let spacing: CGFloat = 8
    private let padding: CGFloat = 10

    // 메인 외 6개 빠른 액션
    private let rightActions: [(icon: String, url: String)] = [
        ("person.fill", "prayanswer://add?category=personal"),
        ("house.fill", "prayanswer://add?category=family"),
        ("heart.fill", "prayanswer://add?category=health"),
        ("briefcase.fill", "prayanswer://add?category=work"),
        ("clock.fill", "prayanswer://storage?type=wait"),
        ("chart.bar.xaxis", "prayanswer://stats")
    ]

    var body: some View {
        HStack(spacing: spacing) {
            // 왼쪽: 메인 액션 (설정 가능)
            Link(destination: URL(string: mainAction.urlString)!) {
                GeminiCircle(icon: mainAction.icon, isMain: true)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // 오른쪽: 3×2 그리드
            VStack(spacing: spacing) {
                HStack(spacing: spacing) {
                    MediumQuickCircle(icon: rightActions[0].icon, urlString: rightActions[0].url)
                    MediumQuickCircle(icon: rightActions[1].icon, urlString: rightActions[1].url)
                    MediumQuickCircle(icon: rightActions[2].icon, urlString: rightActions[2].url)
                }
                .frame(maxHeight: .infinity)

                HStack(spacing: spacing) {
                    MediumQuickCircle(icon: rightActions[3].icon, urlString: rightActions[3].url)
                    MediumQuickCircle(icon: rightActions[4].icon, urlString: rightActions[4].url)
                    MediumQuickCircle(icon: rightActions[5].icon, urlString: rightActions[5].url)
                }
                .frame(maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(padding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) { Color.widgetBackground }
    }
}

// MARK: - Widget Entry View

struct AddPrayerWidgetEntryView: View {
    var entry: AddPrayerEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallAddPrayerWidgetView(mainAction: entry.mainAction)
        case .systemMedium:
            MediumAddPrayerWidgetView(mainAction: entry.mainAction)
        default:
            SmallAddPrayerWidgetView(mainAction: entry.mainAction)
        }
    }
}

// MARK: - Widget Configuration

struct AddPrayerWidget: Widget {
    let kind: String = "AddPrayerWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: AddPrayerWidgetIntent.self, provider: AddPrayerProvider()) { entry in
            AddPrayerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("기도 추가")
        .description("홈 화면에서 바로 새 기도를 추가하거나 원하는 화면으로 이동하세요.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
