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

// MARK: - Add Prayer Widget Intent (기도 위젯 설정용)
struct AddPrayerWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "기도 위젯 설정"
    static var description = IntentDescription("Medium 위젯에 표시할 기도 보관소를 선택하세요.")

    @Parameter(title: "보관소", default: .wait)
    var storage: PrayerStorageAppEnum
}
