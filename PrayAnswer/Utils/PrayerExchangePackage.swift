import Foundation

// MARK: - 교환 패키지 모델

struct PrayerExchangePackage: Codable, Identifiable {
    var id: String { "\(sender)_\(timestamp.timeIntervalSince1970)" }
    let version: Int
    let sender: String
    let timestamp: Date
    let prayers: [ExchangePrayerItem]

    init(sender: String, prayers: [ExchangePrayerItem]) {
        self.version = 1
        self.sender = sender
        self.timestamp = Date()
        self.prayers = prayers
    }
}

struct ExchangePrayerItem: Codable, Identifiable {
    let id: UUID
    let title: String
    let content: String
    let category: String

    init(title: String, content: String, category: String) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.category = category
    }

    init(from prayer: Prayer) {
        self.id = UUID()
        self.title = prayer.title
        self.content = prayer.content
        self.category = prayer.category.rawValue
    }
}

// MARK: - 직렬화 / 역직렬화

enum PrayerExchangePackageError: LocalizedError {
    case encodingFailed
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .encodingFailed: return "기도제목을 패키징하는 데 실패했습니다."
        case .decodingFailed: return "받은 기도제목 파일을 읽는 데 실패했습니다."
        }
    }
}

enum PrayerExchangePackager {

    private static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    private static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        e.outputFormatting = .prettyPrinted
        return e
    }()

    /// Exchange Package → 임시 .prayanswer 파일 URL
    static func writeToFile(_ package: PrayerExchangePackage) throws -> URL {
        let data = try encoder.encode(package)
        let fileName = "기도제목_\(package.sender).prayanswer"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try data.write(to: url)
        return url
    }

    /// .prayanswer 파일 URL → Exchange Package
    static func read(from url: URL) throws -> PrayerExchangePackage {
        let data = try Data(contentsOf: url)
        return try decoder.decode(PrayerExchangePackage.self, from: data)
    }

    /// Data → Exchange Package (Share Extension용)
    static func decode(from data: Data) throws -> PrayerExchangePackage {
        return try decoder.decode(PrayerExchangePackage.self, from: data)
    }
}
