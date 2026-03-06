import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Entry & Provider

struct AddPrayerEntry: TimelineEntry {
    let date: Date
    let prayers: [PrayerWidgetData]
    let selectedStorage: PrayerStorageAppEnum
}

struct AddPrayerProvider: AppIntentTimelineProvider {
    typealias Entry = AddPrayerEntry
    typealias Intent = AddPrayerWidgetIntent

    func placeholder(in context: Context) -> AddPrayerEntry {
        AddPrayerEntry(date: Date(), prayers: [], selectedStorage: .wait)
    }

    func snapshot(for configuration: AddPrayerWidgetIntent, in context: Context) async -> AddPrayerEntry {
        AddPrayerEntry(date: Date(), prayers: [], selectedStorage: configuration.storage)
    }

    func timeline(for configuration: AddPrayerWidgetIntent, in context: Context) async -> Timeline<AddPrayerEntry> {
        let prayers: [PrayerWidgetData]
        if configuration.storage.isFavorites {
            prayers = WidgetDataManager.shared.loadAllFavorites()
        } else {
            prayers = WidgetDataManager.shared.loadFavoritePrayersForStorage(configuration.storage.toPrayerStorage)
        }
        let entry = AddPrayerEntry(date: Date(), prayers: prayers, selectedStorage: configuration.storage)
        return Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
    }
}

// MARK: - Design Tokens (Gemini 스타일)

private extension Color {
    static let widgetBackground = Color(red: 0.13, green: 0.13, blue: 0.14)
    static let circleNormal = Color(white: 0.21)
}

// MARK: - 공통: 노드 원형 (Small & Medium 공유)

private struct NodeCircle: View {
    let icon: String

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.circleNormal)
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Small Widget (4개 고정 노드, 최대 크기)
// Small은 단일 widgetURL → 기도추가로 이동

struct SmallAddPrayerWidgetView: View {
    private let padding: CGFloat = 4
    private let spacing: CGFloat = 4

    var body: some View {
        VStack(spacing: spacing) {
            HStack(spacing: spacing) {
                NodeCircle(icon: "hands.clap.fill")
                NodeCircle(icon: "chart.bar.xaxis")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            HStack(spacing: spacing) {
                NodeCircle(icon: "person.2.fill")
                NodeCircle(icon: "list.bullet")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(padding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) { Color.widgetBackground }
        .widgetURL(URL(string: "prayanswer://add")!)
    }
}

// MARK: - Medium Widget (좌: 2×2 노드 / 우: 보관소 기도 목록 넓게)

struct MediumAddPrayerWidgetView: View {
    let prayers: [PrayerWidgetData]
    let selectedStorage: PrayerStorageAppEnum

    // Small과 동일한 간격
    private let nodeSpacing: CGFloat = 4
    private let outerPadding: CGFloat = 4
    private let dividerSpacing: CGFloat = 8

    // 노드 영역 너비: Small 위젯 크기(~155pt)와 맞춤
    private let nodeAreaWidth: CGFloat = 140

    private var nodeItems: [(icon: String, url: String)] {
        [
            ("hands.clap.fill", "prayanswer://add"),
            ("chart.bar.xaxis", "prayanswer://stats"),
            ("person.2.fill",   "prayanswer://people"),
            ("list.bullet",     selectedStorage.deepLinkURL.absoluteString)
        ]
    }

    var body: some View {
        HStack(spacing: dividerSpacing) {
            // 좌: 2×2 노드 (Small과 동일한 크기/간격)
            VStack(spacing: nodeSpacing) {
                HStack(spacing: nodeSpacing) {
                    nodeLink(nodeItems[0])
                    nodeLink(nodeItems[1])
                }
                .frame(maxHeight: .infinity)
                HStack(spacing: nodeSpacing) {
                    nodeLink(nodeItems[2])
                    nodeLink(nodeItems[3])
                }
                .frame(maxHeight: .infinity)
            }
            .frame(width: nodeAreaWidth)
            .frame(maxHeight: .infinity)

            // 구분선
            Rectangle()
                .fill(Color(white: 0.30))
                .frame(width: 0.5)

            // 우: 보관소 기도 목록 (넓게)
            prayerListSection
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .padding(outerPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) { Color.widgetBackground }
    }

    private func nodeLink(_ item: (icon: String, url: String)) -> some View {
        Link(destination: URL(string: item.url)!) {
            NodeCircle(icon: item.icon)
        }
    }

    // MARK: Prayer List (우측)

    private var prayerListSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            storageHeaderView
            if prayers.isEmpty {
                Spacer()
                Text("기도가 없습니다")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.35))
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(prayers.prefix(4), id: \.id) { prayer in
                        Link(destination: selectedStorage.deepLinkURL) {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(storageAccentColor)
                                    .frame(width: 5, height: 5)
                                Text(prayer.title)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .lineLimit(1)
                                    .foregroundColor(.white.opacity(0.9))
                                Spacer(minLength: 0)
                            }
                            .padding(.vertical, 4)
                            .padding(.horizontal, 7)
                            .background(storageAccentColor.opacity(0.13))
                            .cornerRadius(6)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
    }

    private var storageHeaderView: some View {
        HStack(spacing: 5) {
            Image(systemName: storageIcon)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 18, height: 18)
                .background(storageAccentColor)
                .clipShape(Circle())
            Text(storageLabel)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Spacer()
            Text("\(prayers.count)개")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.45))
        }
    }

    private var storageIcon: String {
        switch selectedStorage {
        case .wait:      return "clock.fill"
        case .yes:       return "checkmark.circle.fill"
        case .no:        return "xmark.circle.fill"
        case .favorites: return "heart.fill"
        }
    }

    private var storageAccentColor: Color {
        switch selectedStorage {
        case .wait:      return .orange
        case .yes:       return .green
        case .no:        return .red
        case .favorites: return .pink
        }
    }

    private var storageLabel: String {
        switch selectedStorage {
        case .wait:      return "Wait"
        case .yes:       return "Yes"
        case .no:        return "No"
        case .favorites: return "즐겨찾기"
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
            MediumAddPrayerWidgetView(prayers: entry.prayers, selectedStorage: entry.selectedStorage)
        default:
            SmallAddPrayerWidgetView()
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
        .configurationDisplayName("기도 위젯")
        .description("기도를 추가하고 보관소의 기도를 확인하세요.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
