import WidgetKit
import AppIntents

// MARK: - Prayer Storage Intent (보관함 선택 위젯용)
struct SelectPrayerStorageIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "보관소 선택"
    static var description = IntentDescription("위젯에 표시할 기도 보관소를 선택하세요.")

    @Parameter(title: "보관소", default: .wait)
    var storage: PrayerStorageAppEnum
}

// MARK: - Prayer Storage App Enum (+ 즐겨찾기 전체)
enum PrayerStorageAppEnum: String, AppEnum {
    case wait = "wait"
    case yes = "yes"
    case no = "no"
    case favorites = "favorites"

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "보관소"
    static var caseDisplayRepresentations: [PrayerStorageAppEnum: DisplayRepresentation] = [
        .wait: "Wait 보관소",
        .yes: "Yes 보관소",
        .no: "No 보관소",
        .favorites: "즐겨찾기 전체"
    ]
}

// MARK: - Extension for conversion
extension PrayerStorageAppEnum {
    /// 즐겨찾기 전체 모드 여부
    var isFavorites: Bool { self == .favorites }

    /// PrayerStorage 변환 (favorites는 .wait 반환 - isFavorites로 먼저 체크)
    var toPrayerStorage: PrayerStorage {
        switch self {
        case .wait: return .wait
        case .yes: return .yes
        case .no: return .no
        case .favorites: return .wait
        }
    }

    /// 위젯 탭 시 이동할 URL
    var deepLinkURL: URL {
        switch self {
        case .wait: return URL(string: "prayanswer://storage?type=wait")!
        case .yes: return URL(string: "prayanswer://storage?type=yes")!
        case .no: return URL(string: "prayanswer://storage?type=no")!
        case .favorites: return URL(string: "prayanswer://favorites")!
        }
    }
}

// MARK: - Quick Action App Enum (기도 추가 위젯 메인 버튼용)
enum QuickActionAppEnum: String, AppEnum {
    case addPrayer = "add"
    case waitStorage = "wait"
    case yesStorage = "yes"
    case noStorage = "no"
    case favorites = "favorites"
    case statistics = "stats"

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "빠른 액션"
    static var caseDisplayRepresentations: [QuickActionAppEnum: DisplayRepresentation] = [
        .addPrayer: "기도 추가",
        .waitStorage: "Wait 보관소",
        .yesStorage: "Yes 보관소",
        .noStorage: "No 보관소",
        .favorites: "즐겨찾기",
        .statistics: "통계"
    ]

    var urlString: String {
        switch self {
        case .addPrayer: return "prayanswer://add"
        case .waitStorage: return "prayanswer://storage?type=wait"
        case .yesStorage: return "prayanswer://storage?type=yes"
        case .noStorage: return "prayanswer://storage?type=no"
        case .favorites: return "prayanswer://favorites"
        case .statistics: return "prayanswer://stats"
        }
    }

    var icon: String {
        switch self {
        case .addPrayer: return "hands.clap.fill"
        case .waitStorage: return "clock.fill"
        case .yesStorage: return "checkmark.circle.fill"
        case .noStorage: return "xmark.circle.fill"
        case .favorites: return "heart.fill"
        case .statistics: return "chart.bar.xaxis"
        }
    }

    var isMain: Bool { self == .addPrayer }
}

// MARK: - Add Prayer Widget Intent (기도 추가 위젯 설정용)
struct AddPrayerWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "기도 추가 위젯 설정"
    static var description = IntentDescription("메인 버튼의 동작을 설정하세요.")

    @Parameter(title: "메인 버튼", default: .addPrayer)
    var mainAction: QuickActionAppEnum
}
