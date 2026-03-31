import Foundation

// MARK: - 기도 인용구 모델

struct PrayerQuote {
    let text: String
    let author: String
    let source: String?

    var formatted: String {
        if let source {
            return "\(text)\n— \(author), 《\(source)》"
        }
        return "\(text)\n— \(author)"
    }

    var notificationLine: String {
        "\"\(text)\" — \(author)"
    }
}

// MARK: - 기도 인용구 관리자

final class PrayerQuoteManager {
    static let shared = PrayerQuoteManager()
    private init() {}

    // MARK: - 성경 말씀

    let quotes: [PrayerQuote] = [

        // 염려와 불안
        PrayerQuote(
            text: "아무 것도 염려하지 말고 다만 모든 일에 기도와 간구로, 너희 구할 것을 감사함으로 하나님께 아뢰라. 그리하면 모든 지각에 뛰어난 하나님의 평강이 그리스도 예수 안에서 너희 마음과 생각을 지키시리라",
            author: "빌립보서 4:6-7",
            source: nil
        ),
        PrayerQuote(
            text: "환난 날에 나를 부르라. 내가 너를 건지리니 네가 나를 영화롭게 하리로다",
            author: "시편 50:15",
            source: nil
        ),
        PrayerQuote(
            text: "너희 염려를 다 주께 맡기라. 이는 그가 너희를 돌보심이라",
            author: "베드로전서 5:7",
            source: nil
        ),

        // 응답 확신
        PrayerQuote(
            text: "너는 내게 부르짖으라. 내가 네게 응답하겠고 네가 알지 못하는 크고 은밀한 일을 네게 보이리라",
            author: "예레미야 33:3",
            source: nil
        ),
        PrayerQuote(
            text: "구하라 그리하면 너희에게 주실 것이요, 찾으라 그리하면 찾아낼 것이요, 문을 두드리라 그리하면 너희에게 열릴 것이니. 구하는 이마다 받을 것이요, 찾는 이는 찾아낼 것이요, 두드리는 이에게는 열릴 것이니라",
            author: "마태복음 7:7-8",
            source: nil
        ),
        PrayerQuote(
            text: "무엇이든지 기도하고 구하는 것은 받은 줄로 믿으라. 그리하면 너희에게 그대로 되리라",
            author: "마가복음 11:24",
            source: nil
        ),
        PrayerQuote(
            text: "그의 뜻대로 무엇을 구하면 들으심이라. 우리가 무엇이든지 구하는 바를 들으시는 줄을 안즉 우리가 그에게 구한 그것을 얻은 줄을 또한 아느니라",
            author: "요한일서 5:14",
            source: nil
        ),

        // 성령 도우심
        PrayerQuote(
            text: "성령도 우리의 연약함을 도우시나니 우리는 마땅히 기도할 바를 알지 못하나 오직 성령이 말할 수 없는 탄식으로 우리를 위하여 친히 간구하시느니라",
            author: "로마서 8:26",
            source: nil
        ),
        PrayerQuote(
            text: "여호와께서는 자기에게 간구하는 모든 자, 곧 진실하게 간구하는 모든 자에게 가까이 하시는도다",
            author: "시편 145:18",
            source: nil
        ),

        // 기도 습관
        PrayerQuote(
            text: "항상 기뻐하라. 쉬지 말고 기도하라. 범사에 감사하라. 이것이 그리스도 예수 안에서 너희를 향하신 하나님의 뜻이니라",
            author: "데살로니가전서 5:16-18",
            source: nil
        ),
        PrayerQuote(
            text: "기도를 계속하고 기도에 감사함으로 깨어 있으라",
            author: "골로새서 4:2",
            source: nil
        ),
        PrayerQuote(
            text: "모든 기도와 간구를 하되 항상 성령 안에서 기도하고 이를 위하여 깨어 구하기를 항상 힘쓰며 여러 성도를 위하여 구하라",
            author: "에베소서 6:18",
            source: nil
        ),

        // MARK: - 신학자 인용구

        // 기도 필수성
        PrayerQuote(
            text: "숨을 쉬지 않고 살아 있는 것이 불가능하듯, 기도 없이 영적으로 살아 있는 것은 불가능합니다",
            author: "마르틴 루터",
            source: nil
        ),
        PrayerQuote(
            text: "기도는 믿음의 가장 주된 훈련이며, 날마다 하나님의 은혜를 받는 통로입니다",
            author: "장 칼뱅",
            source: "기독교강요"
        ),
        PrayerQuote(
            text: "기도는 영혼이 하늘을 향해 날아오르는 날개다",
            author: "리처드 백스터",
            source: nil
        ),

        // 안식과 신뢰
        PrayerQuote(
            text: "주님, 당신은 당신을 위하여 우리를 지으셨으므로, 우리 마음은 당신 안에서 안식을 얻기까지 쉬지 못합니다",
            author: "아우구스티누스",
            source: "고백록"
        ),
        PrayerQuote(
            text: "기도한다는 것은 단순히 말을 뱉는 것이 아니라, 하나님의 침묵 속에서 그분의 음성을 듣는 것입니다",
            author: "디트리히 본회퍼",
            source: nil
        ),

        // 자아 변화
        PrayerQuote(
            text: "기도는 하나님을 변화시키는 것이 아니라, 기도하는 사람을 변화시킨다",
            author: "쇠렌 키르케고르",
            source: nil
        ),
        PrayerQuote(
            text: "나는 어쩔 수 없어서 기도합니다. 기도하지 않으면 내 안에 무언가가 시들어 가기 때문입니다. 기도는 하나님을 바꾸는 것이 아니라 나 자신을 바꿉니다",
            author: "C.S. 루이스",
            source: nil
        ),

        // 담대함과 행동
        PrayerQuote(
            text: "두 손을 모아 기도하는 것은 세상의 흐름에 맞서는, 가장 조용하고도 거룩한 반란의 시작이다",
            author: "칼 바르트",
            source: nil
        ),
        PrayerQuote(
            text: "하나님은 기도를 통해 세상을 빚어 가신다. 하나님은 더 강한 사람이 아니라 더 나은 사람, 곧 기도하는 사람을 찾으신다",
            author: "E.M. 바운즈",
            source: nil
        ),

        // 기타 신학자
        PrayerQuote(
            text: "기도는 전능하신 분께 우리의 무력함을 가져가는 것입니다",
            author: "앤드류 머레이",
            source: "기도의 능력"
        ),
        PrayerQuote(
            text: "기도는 영혼의 방패, 하나님께 드리는 제물, 사탄에 대한 채찍입니다",
            author: "존 번연",
            source: nil
        ),
        PrayerQuote(
            text: "기도는 우리가 원하는 것을 얻는 방법이 아니라, 하나님이 원하시는 것이 무엇인지 발견하는 방법입니다",
            author: "A.W. 토저",
            source: nil
        ),
        PrayerQuote(
            text: "기도는 단순히 말을 하는 것이 아니라 하나님의 임재 안에 있는 것입니다",
            author: "리처드 포스터",
            source: "기도"
        ),
        PrayerQuote(
            text: "기도의 열매는 믿음, 믿음의 열매는 사랑, 사랑의 열매는 섬김입니다",
            author: "마더 테레사",
            source: nil
        ),
        PrayerQuote(
            text: "기도하는 무릎은 제단이며, 진실한 마음은 제물입니다",
            author: "C.H. 스펄전",
            source: nil
        ),
        PrayerQuote(
            text: "기도는 하나님과의 우정을 키워가는 과정입니다",
            author: "필립 얀시",
            source: "기도란 무엇인가"
        ),
    ]

    // MARK: - 인용구 선택

    /// 오늘 날짜 기반 고정 인용구 (하루에 하나, 일관성 유지)
    var todayQuote: PrayerQuote {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return quotes[dayOfYear % quotes.count]
    }

    /// 알림용 인용구 (습관별로 다른 quote, 날짜 rotation)
    func quoteForNotification(habitID: Int) -> PrayerQuote {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = (dayOfYear + habitID) % quotes.count
        return quotes[index]
    }

    /// 랜덤 인용구
    var randomQuote: PrayerQuote {
        quotes.randomElement() ?? quotes[0]
    }
}
