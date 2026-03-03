import WidgetKit
import SwiftUI

// MARK: - Widget-specific Extensions

// PrayerStorage 위젯용 확장
extension PrayerStorage {
    var widgetColor: Color {
        switch self {
        case .wait: return Color.orange.opacity(0.8)
        case .yes: return Color.green.opacity(0.8)
        case .no: return Color.red.opacity(0.8)
        }
    }

    var widgetBackgroundColor: Color {
        switch self {
        case .wait: return Color.orange.opacity(0.1)
        case .yes: return Color.green.opacity(0.1)
        case .no: return Color.red.opacity(0.1)
        }
    }

    var simpleDisplayName: String {
        switch self {
        case .wait: return "Wait"
        case .yes: return "Yes"
        case .no: return "No"
        }
    }

    var deepLinkURL: URL {
        switch self {
        case .wait: return URL(string: "prayanswer://storage?type=wait")!
        case .yes: return URL(string: "prayanswer://storage?type=yes")!
        case .no: return URL(string: "prayanswer://storage?type=no")!
        }
    }
}

// MARK: - Shared Widget Components

// 공통 헤더 컴포넌트
struct WidgetHeader: View {
    let storage: PrayerStorage
    let prayerCount: Int
    let headerSize: HeaderSize

    enum HeaderSize {
        case small, medium, large

        var iconSize: CGFloat {
            switch self {
            case .small: return 14
            case .medium: return 18
            case .large: return 22
            }
        }

        var titleFont: Font {
            switch self {
            case .small: return .caption
            case .medium: return .subheadline
            case .large: return .headline
            }
        }

        var countFont: Font {
            switch self {
            case .small: return .caption2
            case .medium: return .caption
            case .large: return .callout
            }
        }
    }

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: storage.iconName)
                .font(.system(size: headerSize.iconSize, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: headerSize.iconSize + 6, height: headerSize.iconSize + 6)
                .background(storage.widgetColor)
                .clipShape(Circle())

            Text(storage.simpleDisplayName)
                .font(headerSize.titleFont)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Spacer()

            HStack(spacing: 2) {
                Image(systemName: "heart.fill")
                    .font(headerSize.countFont)
                    .foregroundColor(storage.widgetColor)

                Text("\(prayerCount)")
                    .font(headerSize.countFont)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// 즐겨찾기 전체 헤더 (보관소별 색상 없음)
struct FavoritesWidgetHeader: View {
    let prayerCount: Int
    let headerSize: WidgetHeader.HeaderSize

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "heart.fill")
                .font(.system(size: headerSize.iconSize, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: headerSize.iconSize + 6, height: headerSize.iconSize + 6)
                .background(Color.pink.opacity(0.8))
                .clipShape(Circle())

            Text("즐겨찾기")
                .font(headerSize.titleFont)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Spacer()

            Text("\(prayerCount)")
                .font(headerSize.countFont)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
        }
    }
}

// 공통 기도 행 컴포넌트 (storage별 색상)
struct WidgetPrayerRow: View {
    let prayer: PrayerWidgetData
    let storage: PrayerStorage
    let rowSize: RowSize

    enum RowSize {
        case small, medium, large

        var titleFont: Font {
            switch self {
            case .small: return .caption
            case .medium: return .caption
            case .large: return .subheadline
            }
        }

        var contentFont: Font {
            switch self {
            case .small: return .caption2
            case .medium: return .caption2
            case .large: return .caption
            }
        }

        var dotSize: CGFloat {
            switch self {
            case .small: return 5
            case .medium: return 6
            case .large: return 8
            }
        }

        var verticalPadding: CGFloat {
            switch self {
            case .small: return 4
            case .medium: return 5
            case .large: return 8
            }
        }

        var showContent: Bool { self == .large }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Circle()
                .fill(storage.widgetColor)
                .frame(width: rowSize.dotSize, height: rowSize.dotSize)
                .padding(.top, rowSize == .large ? 6 : 3)

            VStack(alignment: .leading, spacing: 2) {
                Text(prayer.title)
                    .font(rowSize.titleFont)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .foregroundColor(.primary)

                if rowSize.showContent && !prayer.content.isEmpty {
                    Text(prayer.content)
                        .font(rowSize.contentFont)
                        .lineLimit(2)
                        .foregroundColor(.secondary)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, rowSize.verticalPadding)
        .padding(.horizontal, rowSize == .large ? 10 : 7)
        .frame(maxWidth: .infinity)
        .background(storage.widgetBackgroundColor)
        .cornerRadius(7)
    }
}

// 즐겨찾기 전체 기도 행 (각 기도의 storage 색상 사용)
struct FavoritesWidgetPrayerRow: View {
    let prayer: PrayerWidgetData
    let rowSize: WidgetPrayerRow.RowSize

    private var storage: PrayerStorage { prayer.prayerStorage }

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Circle()
                .fill(storage.widgetColor)
                .frame(width: rowSize.dotSize, height: rowSize.dotSize)
                .padding(.top, 3)

            Text(prayer.title)
                .font(rowSize.titleFont)
                .fontWeight(.medium)
                .lineLimit(1)
                .foregroundColor(.primary)

            Spacer(minLength: 0)
        }
        .padding(.vertical, rowSize.verticalPadding)
        .padding(.horizontal, 7)
        .frame(maxWidth: .infinity)
        .background(storage.widgetBackgroundColor)
        .cornerRadius(7)
    }
}

// 빈 상태 컴포넌트
struct WidgetEmptyState: View {
    let storage: PrayerStorage?
    let size: EmptyStateSize

    init(storage: PrayerStorage? = nil, size: EmptyStateSize) {
        self.storage = storage
        self.size = size
    }

    enum EmptyStateSize {
        case small, medium, large

        var iconSize: CGFloat {
            switch self {
            case .small: return 18
            case .medium: return 26
            case .large: return 34
            }
        }

        var titleFont: Font {
            switch self {
            case .small: return .caption2
            case .medium: return .caption
            case .large: return .callout
            }
        }
    }

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: "heart.slash")
                .font(.system(size: size.iconSize))
                .foregroundColor(.secondary)

            Text("기도가 없습니다")
                .font(size.titleFont)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Storage-specific Prayer Widgets

// MARK: - Small Widget (4개 표시)
struct SmallPrayerWidget: View {
    let prayers: [PrayerWidgetData]
    let storage: PrayerStorage

    private let maxItems = 4

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            WidgetHeader(storage: storage, prayerCount: prayers.count, headerSize: .small)

            if prayers.isEmpty {
                WidgetEmptyState(storage: storage, size: .small)
            } else {
                VStack(alignment: .leading, spacing: 3) {
                    ForEach(prayers.prefix(maxItems), id: \.id) { prayer in
                        WidgetPrayerRow(prayer: prayer, storage: storage, rowSize: .small)
                    }
                    if prayers.count > maxItems {
                        Text("외 \(prayers.count - maxItems)개")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(10)
        .containerBackground(for: .widget) { Color(.systemBackground) }
    }
}

// MARK: - Medium Widget (5개 표시, 왼쪽3개+오른쪽2개 레이아웃)
struct MediumPrayerWidget: View {
    let prayers: [PrayerWidgetData]
    let storage: PrayerStorage

    private let leftColumnItems = 3
    private let rightColumnItems = 2
    private let totalDisplayItems = 5

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            WidgetHeader(storage: storage, prayerCount: prayers.count, headerSize: .medium)

            if prayers.isEmpty {
                WidgetEmptyState(storage: storage, size: .medium)
            } else {
                HStack(alignment: .top, spacing: 8) {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(prayers.prefix(leftColumnItems), id: \.id) { prayer in
                            WidgetPrayerRow(prayer: prayer, storage: storage, rowSize: .medium)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(prayers.dropFirst(leftColumnItems).prefix(rightColumnItems), id: \.id) { prayer in
                            WidgetPrayerRow(prayer: prayer, storage: storage, rowSize: .medium)
                        }
                        if prayers.count > totalDisplayItems {
                            Text("외 \(prayers.count - totalDisplayItems)개")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(10)
        .containerBackground(for: .widget) { Color(.systemBackground) }
    }
}

// MARK: - Large Widget (5개 표시)
struct LargePrayerWidget: View {
    let prayers: [PrayerWidgetData]
    let storage: PrayerStorage

    private let maxItems = 5

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            WidgetHeader(storage: storage, prayerCount: prayers.count, headerSize: .large)

            if prayers.isEmpty {
                WidgetEmptyState(storage: storage, size: .large)
            } else {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(prayers.prefix(maxItems), id: \.id) { prayer in
                        WidgetPrayerRow(prayer: prayer, storage: storage, rowSize: .large)
                    }
                    if prayers.count > maxItems {
                        Text("외 \(prayers.count - maxItems)개의 기도")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(12)
        .containerBackground(for: .widget) { Color(.systemBackground) }
    }
}

// MARK: - Favorites Prayer Widgets (즐겨찾기 전체)

struct SmallFavoritesWidget: View {
    let prayers: [PrayerWidgetData]
    private let maxItems = 4

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            FavoritesWidgetHeader(prayerCount: prayers.count, headerSize: .small)

            if prayers.isEmpty {
                WidgetEmptyState(size: .small)
            } else {
                VStack(alignment: .leading, spacing: 3) {
                    ForEach(prayers.prefix(maxItems), id: \.id) { prayer in
                        FavoritesWidgetPrayerRow(prayer: prayer, rowSize: .small)
                    }
                    if prayers.count > maxItems {
                        Text("외 \(prayers.count - maxItems)개")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(10)
        .containerBackground(for: .widget) { Color(.systemBackground) }
    }
}

struct MediumFavoritesWidget: View {
    let prayers: [PrayerWidgetData]
    private let leftColumnItems = 3
    private let rightColumnItems = 2
    private let totalDisplayItems = 5

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            FavoritesWidgetHeader(prayerCount: prayers.count, headerSize: .medium)

            if prayers.isEmpty {
                WidgetEmptyState(size: .medium)
            } else {
                HStack(alignment: .top, spacing: 8) {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(prayers.prefix(leftColumnItems), id: \.id) { prayer in
                            FavoritesWidgetPrayerRow(prayer: prayer, rowSize: .medium)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(prayers.dropFirst(leftColumnItems).prefix(rightColumnItems), id: \.id) { prayer in
                            FavoritesWidgetPrayerRow(prayer: prayer, rowSize: .medium)
                        }
                        if prayers.count > totalDisplayItems {
                            Text("외 \(prayers.count - totalDisplayItems)개")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(10)
        .containerBackground(for: .widget) { Color(.systemBackground) }
    }
}

struct LargeFavoritesWidget: View {
    let prayers: [PrayerWidgetData]
    private let maxItems = 5

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            FavoritesWidgetHeader(prayerCount: prayers.count, headerSize: .large)

            if prayers.isEmpty {
                WidgetEmptyState(size: .large)
            } else {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(prayers.prefix(maxItems), id: \.id) { prayer in
                        FavoritesWidgetPrayerRow(prayer: prayer, rowSize: .large)
                    }
                    if prayers.count > maxItems {
                        Text("외 \(prayers.count - maxItems)개의 기도")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(12)
        .containerBackground(for: .widget) { Color(.systemBackground) }
    }
}

// MARK: - Shared Widget Entry Views

struct SharedWidgetEntryView: View {
    let prayers: [PrayerWidgetData]
    let storage: PrayerStorage
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallPrayerWidget(prayers: prayers, storage: storage)
                .widgetURL(storage.deepLinkURL)
        case .systemMedium:
            MediumPrayerWidget(prayers: prayers, storage: storage)
                .widgetURL(storage.deepLinkURL)
        case .systemLarge:
            LargePrayerWidget(prayers: prayers, storage: storage)
                .widgetURL(storage.deepLinkURL)
        default:
            SmallPrayerWidget(prayers: prayers, storage: storage)
                .widgetURL(storage.deepLinkURL)
        }
    }
}

struct FavoritesWidgetEntryView: View {
    let prayers: [PrayerWidgetData]
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallFavoritesWidget(prayers: prayers)
                .widgetURL(URL(string: "prayanswer://favorites")!)
        case .systemMedium:
            MediumFavoritesWidget(prayers: prayers)
                .widgetURL(URL(string: "prayanswer://favorites")!)
        case .systemLarge:
            LargeFavoritesWidget(prayers: prayers)
                .widgetURL(URL(string: "prayanswer://favorites")!)
        default:
            SmallFavoritesWidget(prayers: prayers)
                .widgetURL(URL(string: "prayanswer://favorites")!)
        }
    }
}
