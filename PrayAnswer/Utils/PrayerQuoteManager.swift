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

    // MARK: - 성경 말씀 & 신학자 인용구

    let quotes: [PrayerQuote] = [

        // MARK: 성경 - 염려와 불안
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

        // MARK: 성경 - 응답 확신
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
        PrayerQuote(
            text: "너희 중에 두 사람이 땅에서 합심하여 무엇이든지 구하면 하늘에 계신 내 아버지께서 그들을 위하여 이루게 하시리라",
            author: "마태복음 18:19",
            source: nil
        ),

        // MARK: 성경 - 성령 도우심
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
        PrayerQuote(
            text: "여호와의 눈은 의인을 향하시고 그의 귀는 그들의 부르짖음에 기울이시는도다",
            author: "시편 34:15",
            source: nil
        ),
        PrayerQuote(
            text: "주는 기도를 들으시는 주여 모든 육체가 주께 나아오리이다",
            author: "시편 65:2",
            source: nil
        ),
        PrayerQuote(
            text: "내가 너를 불렀더니 네가 내게 대답하였고 내가 힘 있고 견고하게 하였도다",
            author: "시편 138:3",
            source: nil
        ),

        // MARK: 성경 - 기도 습관
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
        PrayerQuote(
            text: "이것은 기도 외에 다른 것으로는 이런 종류가 나갈 수 없느니라",
            author: "마가복음 9:29",
            source: nil
        ),

        // MARK: 신학자 - 기도 필수성
        PrayerQuote(
            text: "숨을 쉬지 않고 살아 있는 것이 불가능하듯, 기도 없이 영적으로 살아 있는 것은 불가능합니다",
            author: "마르틴 루터",
            source: nil
        ),
        PrayerQuote(
            text: "오늘 할 일이 많을수록 더 오래 기도해야 합니다",
            author: "마틴 루터",
            source: nil
        ),
        PrayerQuote(
            text: "기도는 영혼을 하나님께로 올라가게 하는 사다리입니다",
            author: "마틴 루터",
            source: nil
        ),
        PrayerQuote(
            text: "기도를 잘 할 수 있는 사람은 공부도 잘 합니다",
            author: "마틴 루터",
            source: nil
        ),
        PrayerQuote(
            text: "기도는 믿음의 가장 주된 훈련이며, 날마다 하나님의 은혜를 받는 통로입니다",
            author: "장 칼뱅",
            source: "기독교강요"
        ),
        PrayerQuote(
            text: "우리가 기도하지 않는 것은 하나님이 베풀기를 원하시는 것들을 거부하는 것입니다",
            author: "존 칼뱅",
            source: nil
        ),
        PrayerQuote(
            text: "기도는 영혼이 하늘을 향해 날아오르는 날개다",
            author: "리처드 백스터",
            source: nil
        ),

        // MARK: 신학자 - 안식과 신뢰
        PrayerQuote(
            text: "주님, 당신은 당신을 위하여 우리를 지으셨으므로, 우리 마음은 당신 안에서 안식을 얻기까지 쉬지 못합니다",
            author: "아우구스티누스",
            source: "고백록"
        ),
        PrayerQuote(
            text: "기도는 영혼의 호흡입니다",
            author: "아우구스티누스",
            source: nil
        ),
        PrayerQuote(
            text: "기도한다는 것은 단순히 말을 뱉는 것이 아니라, 하나님의 침묵 속에서 그분의 음성을 듣는 것입니다",
            author: "디트리히 본회퍼",
            source: nil
        ),
        PrayerQuote(
            text: "기도는 내 말로 하나님께 나아가는 것이 아니라, 하나님의 말씀이 내 입술을 통해 흘러나오는 것입니다",
            author: "디트리히 본회퍼",
            source: "신도의 공동생활"
        ),
        PrayerQuote(
            text: "매일 기도하는 사람은 그 날을 다르게 살아갑니다",
            author: "디트리히 본회퍼",
            source: nil
        ),

        // MARK: 신학자 - 자아 변화
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
        PrayerQuote(
            text: "기도는 하나님의 마음을 바꾸는 것이 아니라, 우리의 마음을 바꾸는 것입니다",
            author: "C.S. 루이스",
            source: nil
        ),
        PrayerQuote(
            text: "기도는 인격적인 하나님과의 대화입니다. 그분은 우리의 말에 실제로 응답하십니다",
            author: "C.S. 루이스",
            source: nil
        ),

        // MARK: 신학자 - 담대함과 행동
        PrayerQuote(
            text: "두 손을 모아 기도하는 것은 세상의 흐름에 맞서는, 가장 조용하고도 거룩한 반란의 시작이다",
            author: "칼 바르트",
            source: nil
        ),
        PrayerQuote(
            text: "기도를 드리는 사람은 하나님이 역사 안에서 행동하신다는 것을 믿는 사람입니다",
            author: "칼 바르트",
            source: nil
        ),
        PrayerQuote(
            text: "하나님은 기도를 통해 세상을 빚어 가신다. 하나님은 더 강한 사람이 아니라 더 나은 사람, 곧 기도하는 사람을 찾으신다",
            author: "E.M. 바운즈",
            source: nil
        ),
        PrayerQuote(
            text: "기도는 하나님과 함께 일하는 것이며, 그분의 목적을 이루기 위한 동역입니다",
            author: "E.M. 바운즈",
            source: "기도의 능력"
        ),
        PrayerQuote(
            text: "하나님의 사역은 기도하는 사람들을 통해 이루어집니다",
            author: "E.M. 바운즈",
            source: nil
        ),
        PrayerQuote(
            text: "기도는 하나님과 인간 사이의 가장 친밀한 교제입니다",
            author: "E.M. 바운즈",
            source: nil
        ),

        // MARK: 신학자 - 기타
        PrayerQuote(
            text: "기도는 전능하신 분께 우리의 무력함을 가져가는 것입니다",
            author: "앤드류 머레이",
            source: "기도의 능력"
        ),
        PrayerQuote(
            text: "기도는 힘이 아닌 믿음으로 하는 것입니다",
            author: "앤드류 머레이",
            source: nil
        ),
        PrayerQuote(
            text: "기도는 하나님의 능력이 흐르는 통로입니다",
            author: "앤드류 머레이",
            source: nil
        ),
        PrayerQuote(
            text: "기도는 단순히 의무를 이행하는 것이 아니라 하나님과 친밀히 교제하는 것입니다",
            author: "존 번연",
            source: nil
        ),
        PrayerQuote(
            text: "기도는 영혼의 방패, 하나님께 드리는 제물, 사탄에 대한 채찍입니다",
            author: "존 번연",
            source: nil
        ),
        PrayerQuote(
            text: "기도하는 무릎은 제단이며, 진실한 마음은 제물입니다",
            author: "C.H. 스펄전",
            source: nil
        ),
        PrayerQuote(
            text: "기도 없이는 큰 일을 기대하지 마십시오. 기도 없이는 위대한 일을 시도하지 마십시오",
            author: "C.H. 스펄전",
            source: nil
        ),
        PrayerQuote(
            text: "짧은 기도가 하늘에 닿을 수 있습니다. 화살은 멀리 나는 데 오랜 활시위가 필요하지 않습니다",
            author: "C.H. 스펄전",
            source: nil
        ),
        PrayerQuote(
            text: "기도는 우리가 원하는 것을 얻는 방법이 아니라, 하나님이 원하시는 것이 무엇인지 발견하는 방법입니다",
            author: "A.W. 토저",
            source: nil
        ),
        PrayerQuote(
            text: "하나님을 향해 마음을 들어올리십시오. 그분은 당신의 기도를 듣고 계십니다",
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
            text: "침묵 속에서 하나님은 말씀하십니다. 우리는 듣기 위해 침묵이 필요합니다",
            author: "마더 테레사",
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
        let year = Calendar.current.component(.year, from: Date())
        let hash = abs((year * 366 + dayOfYear) &* 1_000_003)
        return quotes[hash % quotes.count]
    }

    /// 알림용 인용구 (습관별·날짜별로 비선형 분산 — 같은 구절이 연속 반복되지 않음)
    func quoteForNotification(habitID: Int) -> PrayerQuote {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let year = calendar.component(.year, from: Date())
        let absoluteDay = year * 366 + dayOfYear
        // Knuth multiplicative hash — 연속된 날짜가 연속된 인용구로 매핑되지 않도록 분산
        let hash = abs((absoluteDay &* 1_000_003) ^ (habitID &* 999_983))
        return quotes[hash % quotes.count]
    }

    /// 랜덤 인용구
    var randomQuote: PrayerQuote {
        quotes.randomElement() ?? quotes[0]
    }
}
