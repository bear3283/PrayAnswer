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
    case urlTooLong

    var errorDescription: String? {
        switch self {
        case .encodingFailed: return "기도제목을 패키징하는 데 실패했습니다."
        case .decodingFailed: return "받은 기도제목 파일을 읽는 데 실패했습니다."
        case .urlTooLong: return "기도제목 내용이 너무 많아 링크로 전달할 수 없습니다."
        }
    }
}

enum PrayerExchangePackager {

    // App Store URL — 출시 후 실제 ID로 교체
    static let appStoreURL = "https://apps.apple.com/kr/app/prayanswer/id6748534851"

    private static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    private static let compactEncoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        // 공간 절약을 위해 prettyPrinted 미사용
        return e
    }()

    private static let prettyEncoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        e.outputFormatting = .prettyPrinted
        return e
    }()

    // MARK: - 딥링크 방식 (앱 → 앱)

    /// Package → prayanswer://receive?data=BASE64URL 딥링크 문자열
    static func toDeepLink(_ package: PrayerExchangePackage) throws -> String {
        let data = try compactEncoder.encode(package)
        // URL-safe base64: + → -, / → _, = 제거
        let base64url = data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        return "prayanswer://receive?data=\(base64url)"
    }

    /// prayanswer://receive?data=BASE64URL → Package
    static func fromDeepLink(_ url: URL) throws -> PrayerExchangePackage {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let base64url = components.queryItems?.first(where: { $0.name == "data" })?.value
        else { throw PrayerExchangePackageError.decodingFailed }

        // URL-safe base64 → standard base64
        var base64 = base64url
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        // 패딩 복원
        let remainder = base64.count % 4
        if remainder > 0 { base64 += String(repeating: "=", count: 4 - remainder) }

        guard let data = Data(base64Encoded: base64) else {
            throw PrayerExchangePackageError.decodingFailed
        }
        return try decoder.decode(PrayerExchangePackage.self, from: data)
    }

    // MARK: - 스마트 공유 텍스트 생성

    /// 앱 유무에 관계없이 전달 가능한 공유 메시지 생성
    static func makeShareMessage(_ package: PrayerExchangePackage) -> String {
        var lines: [String] = []

        lines.append("\(package.sender)님의 기도제목 🙏")
        lines.append("")

        for item in package.prayers {
            lines.append("• \(item.title)")
            if !item.content.isEmpty {
                // 내용은 2줄까지만 미리보기
                let preview = item.content
                    .components(separatedBy: "\n")
                    .prefix(2)
                    .joined(separator: " ")
                let truncated = preview.count > 60 ? String(preview.prefix(60)) + "..." : preview
                lines.append("  \(truncated)")
            }
        }

        lines.append("")
        lines.append("─────────────────")

        // 딥링크 생성 (실패해도 텍스트만 전달)
        if let deepLink = try? toDeepLink(package) {
            lines.append("PrayAnswer 앱이 있다면 아래 링크로 바로 받으세요:")
            lines.append(deepLink)
            lines.append("")
        }

        lines.append("앱 다운로드: \(appStoreURL)")

        return lines.joined(separator: "\n")
    }

    // MARK: - 파일 방식 (AirDrop 등)

    /// Exchange Package → 임시 .prayanswer 파일 URL
    static func writeToFile(_ package: PrayerExchangePackage) throws -> URL {
        let data = try prettyEncoder.encode(package)
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

    /// Data → Exchange Package
    static func decode(from data: Data) throws -> PrayerExchangePackage {
        return try decoder.decode(PrayerExchangePackage.self, from: data)
    }
}
