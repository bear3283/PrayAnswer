import WidgetKit
import AppIntents

// MARK: - Prayer Storage Intent
struct SelectPrayerStorageIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "보관소 선택"
    static var description = IntentDescription("위젯에 표시할 기도 보관소를 선택하세요.")
    
    @Parameter(title: "보관소", default: .wait)
    var storage: PrayerStorageAppEnum
}

// MARK: - Prayer Storage App Enum
enum PrayerStorageAppEnum: String, AppEnum {
    case wait = "wait"
    case yes = "yes"
    case no = "no"
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "보관소"
    static var caseDisplayRepresentations: [PrayerStorageAppEnum: DisplayRepresentation] = [
        .wait: "Wait",
        .yes: "Yes", 
        .no: "No"
    ]
}

// MARK: - Extension for conversion
extension PrayerStorageAppEnum {
    var toPrayerStorage: PrayerStorage {
        switch self {
        case .wait:
            return .wait
        case .yes:
            return .yes
        case .no:
            return .no
        }
    }
} 