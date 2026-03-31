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

    // MARK: - 신학자 & 성경 인용구

    let quotes: [PrayerQuote] = [
        // 아우구스티누스 (Augustine, 354–430)
        PrayerQuote(
            text: "우리의 마음이 주 안에서 안식을 얻기까지 쉼이 없습니다",
            author: "아우구스티누스",
            source: "고백록"
        ),
        PrayerQuote(
            text: "기도는 영혼의 호흡입니다",
            author: "아우구스티누스",
            source: nil
        ),
        PrayerQuote(
            text: "하나님, 당신은 우리를 당신을 위해 만드셨고, 우리 마음은 당신 안에 쉴 때까지 안식이 없습니다",
            author: "아우구스티누스",
            source: "고백록"
        ),

        // 마틴 루터 (Martin Luther, 1483–1546)
        PrayerQuote(
            text: "기도는 영혼을 하나님께로 올라가게 하는 사다리입니다",
            author: "마틴 루터",
            source: nil
        ),
        PrayerQuote(
            text: "오늘 할 일이 많을수록 더 오래 기도해야 합니다",
            author: "마틴 루터",
            source: nil
        ),
        PrayerQuote(
            text: "기도를 잘 할 수 있는 사람은 공부도 잘 합니다",
            author: "마틴 루터",
            source: nil
        ),

        // 존 칼뱅 (John Calvin, 1509–1564)
        PrayerQuote(
            text: "기도는 믿음의 중요한 훈련이며, 우리가 매일 하나님께 받는 것들을 얻는 통로입니다",
            author: "존 칼뱅",
            source: "기독교강요"
        ),
        PrayerQuote(
            text: "우리가 기도하지 않는 것은 하나님이 베풀기를 원하시는 것들을 거부하는 것입니다",
            author: "존 칼뱅",
            source: nil
        ),

        // 존 번연 (John Bunyan, 1628–1688)
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

        // C.H. 스펄전 (Charles Spurgeon, 1834–1892)
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

        // 앤드류 머레이 (Andrew Murray, 1828–1917)
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

        // E.M. 바운즈 (E.M. Bounds, 1835–1913)
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

        // A.W. 토저 (A.W. Tozer, 1897–1963)
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

        // 디트리히 본회퍼 (Dietrich Bonhoeffer, 1906–1945)
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

        // C.S. 루이스 (C.S. Lewis, 1898–1963)
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

        // 마더 테레사 (Mother Teresa, 1910–1997)
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

        // 칼 바르트 (Karl Barth, 1886–1968)
        PrayerQuote(
            text: "기도를 드리는 사람은 하나님이 역사 안에서 행동하신다는 것을 믿는 사람입니다",
            author: "칼 바르트",
            source: nil
        ),

        // 리처드 포스터 (Richard Foster)
        PrayerQuote(
            text: "기도는 단순히 말을 하는 것이 아니라 하나님의 임재 안에 있는 것입니다",
            author: "리처드 포스터",
            source: "기도"
        ),

        // 필립 얀시 (Philip Yancey)
        PrayerQuote(
            text: "기도는 하나님과의 우정을 키워가는 과정입니다",
            author: "필립 얀시",
            source: "기도란 무엇인가"
        ),

        // 성경 말씀
        PrayerQuote(
            text: "아무것도 염려하지 말고 다만 모든 일에 기도와 간구로, 너희 구할 것을 감사함으로 하나님께 아뢰라",
            author: "빌립보서 4:6",
            source: nil
        ),
        PrayerQuote(
            text: "쉬지 말고 기도하라",
            author: "데살로니가전서 5:17",
            source: nil
        ),
        PrayerQuote(
            text: "구하라 그리하면 너희에게 주실 것이요 찾으라 그리하면 찾아낼 것이요 문을 두드리라 그리하면 너희에게 열릴 것이니",
            author: "마태복음 7:7",
            source: nil
        ),
        PrayerQuote(
            text: "너희 중에 두 사람이 땅에서 합심하여 무엇이든지 구하면 하늘에 계신 내 아버지께서 그들을 위하여 이루게 하시리라",
            author: "마태복음 18:19",
            source: nil
        ),
        PrayerQuote(
            text: "여호와의 눈은 의인을 향하시고 그의 귀는 그들의 부르짖음에 기울이시는도다",
            author: "시편 34:15",
            source: nil
        ),
        PrayerQuote(
            text: "이르시되 이것은 기도 외에 다른 것으로는 이런 종류가 나갈 수 없느니라",
            author: "마가복음 9:29",
            source: nil
        ),
        PrayerQuote(
            text: "내가 너를 불렀더니 네가 내게 대답하였고 내가 힘 있고 견고하게 하였도다",
            author: "시편 138:3",
            source: nil
        ),
        PrayerQuote(
            text: "주는 기도를 들으시는 주여 모든 육체가 주께 나아오리이다",
            author: "시편 65:2",
            source: nil
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
