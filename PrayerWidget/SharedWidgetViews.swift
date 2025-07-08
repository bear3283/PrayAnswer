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
            case .small: return 16
            case .medium: return 20
            case .large: return 24
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
        HStack {
            // 아이콘
            Image(systemName: storage.iconName)
                .font(.system(size: headerSize.iconSize, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: headerSize.iconSize + 4, height: headerSize.iconSize + 4)
                .background(storage.widgetColor)
                .clipShape(Circle())
            
            // 타이틀
            Text(storage.simpleDisplayName)
                .font(headerSize.titleFont)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer()
            
            // 개수 표시
            HStack(spacing: 3) {
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

// 공통 기도 행 컴포넌트
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
            case .medium: return .caption
            case .large: return .caption
            }
        }
        
        var dotSize: CGFloat {
            switch self {
            case .small: return 4
            case .medium: return 6
            case .large: return 8
            }
        }
        
        var spacing: CGFloat {
            switch self {
            case .small: return 4
            case .medium: return 6
            case .large: return 8
            }
        }
        
        var showContent: Bool {
            return self == .large
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: rowSize.spacing) {
            // 상태 인디케이터
            Circle()
                .fill(storage.widgetColor)
                .frame(width: rowSize.dotSize, height: rowSize.dotSize)
                .padding(.top, rowSize == .large ? 6 : 2)
            
            VStack(alignment: .leading, spacing: 2) {
                // 제목
                Text(prayer.title)
                    .font(rowSize.titleFont)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                // 내용 (Large 사이즈에만 표시)
                if rowSize.showContent {
                    Text(prayer.content)
                        .font(rowSize.contentFont)
                        .lineLimit(2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, rowSize == .large ? 8 : 4)
        .padding(.horizontal, rowSize == .large ? 12 : 8)
        .background(storage.widgetBackgroundColor)
        .cornerRadius(8)
    }
}

// 빈 상태 컴포넌트
struct WidgetEmptyState: View {
    let storage: PrayerStorage
    let size: EmptyStateSize
    
    enum EmptyStateSize {
        case small, medium, large
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 20
            case .medium: return 28
            case .large: return 36
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
        VStack(spacing: 6) {
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

// MARK: - Size-specific Widgets

// MARK: - Small Widget (4개 표시)
struct SmallPrayerWidget: View {
    let prayers: [PrayerWidgetData]
    let storage: PrayerStorage
    
    private let maxItems = 4
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 헤더
            WidgetHeader(
                storage: storage,
                prayerCount: prayers.count,
                headerSize: .small
            )
            
            // 컨텐츠
            if prayers.isEmpty {
                WidgetEmptyState(storage: storage, size: .small)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(prayers.prefix(maxItems), id: \.id) { prayer in
                        WidgetPrayerRow(
                            prayer: prayer,
                            storage: storage,
                            rowSize: .small
                        )
                    }
                    
                    if prayers.count > maxItems {
                        HStack {
                            Spacer()
                            Text("외 \(prayers.count - maxItems)개")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
//                        .padding(.top, 2)
                    }
                }
                
//                Spacer()
            }
        }
        .padding(2)
        .containerBackground(.fill, for: .widget)
    }
}

// MARK: - Medium Widget (6개 표시, 왼쪽3개+오른쪽2개 레이아웃)
struct MediumPrayerWidget: View {
    let prayers: [PrayerWidgetData]
    let storage: PrayerStorage
    
    private let leftColumnItems = 3
    private let rightColumnItems = 2
    private let totalDisplayItems = 5  // 실제 표시되는 기도 개수
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 헤더
            WidgetHeader(
                storage: storage,
                prayerCount: prayers.count,
                headerSize: .medium
            )
            
            // 컨텐츠
            if prayers.isEmpty {
                WidgetEmptyState(storage: storage, size: .medium)
            } else {
                HStack(alignment: .top, spacing: 12) {
                    // 왼쪽 열 (3개)
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(prayers.prefix(leftColumnItems), id: \.id) { prayer in
                            WidgetPrayerRow(
                                prayer: prayer,
                                storage: storage,
                                rowSize: .medium
                            )
                        }
                    }
                    
                    // 오른쪽 열 (2개 + 추가 개수)
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(prayers.dropFirst(leftColumnItems).prefix(rightColumnItems), id: \.id) { prayer in
                            WidgetPrayerRow(
                                prayer: prayer,
                                storage: storage,
                                rowSize: .medium
                            )
                        }
                        
                        // 추가 기도 개수 표시 (오른쪽 열 하단, 중앙정렬)
                        if prayers.count > totalDisplayItems {
                            HStack {
                                Spacer()
                                Text("외 \(prayers.count - totalDisplayItems)개의 기도")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.top, 4)
                        }
                    }
                }
                
//                Spacer()
            }
        }
        .padding(4)
        .containerBackground(.fill, for: .widget)
    }
}

// MARK: - Large Widget (5개 표시)
struct LargePrayerWidget: View {
    let prayers: [PrayerWidgetData]
    let storage: PrayerStorage
    
    private let maxItems = 5
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 헤더
            WidgetHeader(
                storage: storage,
                prayerCount: prayers.count,
                headerSize: .large
            )
            
            // 컨텐츠
            if prayers.isEmpty {
                WidgetEmptyState(storage: storage, size: .large)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(prayers.prefix(maxItems), id: \.id) { prayer in
                        WidgetPrayerRow(
                            prayer: prayer,
                            storage: storage,
                            rowSize: .large
                        )
                    }
                    
                    if prayers.count > maxItems {
                        HStack {
                            Spacer()
                            Text("외 \(prayers.count - maxItems)개의 기도")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.top, 2)
                    }
                }
                
//                Spacer()
            }
        }
        .padding(6)
        .containerBackground(.fill, for: .widget)
    }
}

// MARK: - Shared Widget Entry View
struct SharedWidgetEntryView: View {
    let prayers: [PrayerWidgetData]
    let storage: PrayerStorage
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallPrayerWidget(prayers: prayers, storage: storage)
        case .systemMedium:
            MediumPrayerWidget(prayers: prayers, storage: storage)
        case .systemLarge:
            LargePrayerWidget(prayers: prayers, storage: storage)
        default:
            SmallPrayerWidget(prayers: prayers, storage: storage)
        }
    }
} 
