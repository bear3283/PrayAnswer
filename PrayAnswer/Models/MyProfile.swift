import Foundation

/// 나의 프로필 — UserDefaults 기반 (SwiftData 불필요)
final class MyProfile: ObservableObject {
    static let shared = MyProfile()

    private let nameKey = "myProfile.name"

    @Published var name: String {
        didSet { UserDefaults.standard.set(name, forKey: nameKey) }
    }

    private init() {
        self.name = UserDefaults.standard.string(forKey: "myProfile.name") ?? ""
    }
}
