//
//  PrayerContentNumbering.swift
//  PrayAnswer
//
//  기도 내용을 줄바꿈 기준으로 번호 목록("1. …" / "2. …")으로 변환하는 헬퍼.
//  한 사람의 기도제목을 여러 개 한꺼번에 입력할 때 사용한다.
//

import Foundation

/// 기도 내용의 번호 상태. 버튼이 "지금 누르면 무슨 일이 일어나는지"를 말하도록 셋으로 나눈다.
enum PrayerNumberingState: Equatable {
    /// 번호가 하나도 없음 → 누르면 번호를 매긴다
    case none
    /// 1부터 순서대로 매겨져 있음 → 누르면 번호를 없앤다
    case ordered
    /// 번호는 있지만 순서가 어긋나거나 일부에만 있음 → 누르면 다시 매긴다
    case disordered
}

extension String {

    // MARK: - 상태 조회

    /// 줄바꿈 기준으로 나눈 항목들 (빈 줄 제외, 번호 접두사 제거 후 trim)
    var prayerLineItems: [String] {
        components(separatedBy: .newlines)
            .map { $0.strippingPrayerNumberPrefix.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    /// 번호가 붙은 마지막 줄의 번호 (없으면 nil).
    /// 내용이 아직 비어 있는 "3. " 같은 줄도 번호로 센다 — 줄바꿈 직후 다음 번호를 이어 붙이기 위해.
    var lastLineNumber: Int? {
        components(separatedBy: .newlines)
            .compactMap { $0.leadingPrayerNumber }
            .last
    }

    /// 번호 상태 (없음 / 순서대로 / 어긋남)
    var numberingState: PrayerNumberingState {
        let numbers = components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .map { $0.leadingPrayerNumber }

        guard !numbers.isEmpty else { return .none }
        if numbers.allSatisfy({ $0 == nil }) { return .none }
        let isOrdered = numbers.enumerated().allSatisfy { $0.element == $0.offset + 1 }
        return isOrdered ? .ordered : .disordered
    }

    /// 이미 1부터 순서대로 번호가 매겨져 있는지 여부.
    /// 번호가 있지만 순서가 어긋난 경우(줄 삭제·추가 후)는 false → 다시 매길 수 있게 한다.
    var isSequentiallyNumbered: Bool {
        numberingState == .ordered
    }

    // MARK: - 변환

    /// 줄바꿈마다 "1. ", "2. " … 번호를 매긴 문자열.
    /// 기존 번호는 제거 후 다시 매기므로 반복 적용해도 중복되지 않는다.
    var numberedByLines: String {
        prayerLineItems
            .enumerated()
            .map { "\($0.offset + 1). \($0.element)" }
            .joined(separator: "\n")
    }

    /// 각 줄의 번호 접두사를 제거한 문자열
    var numberingRemoved: String {
        prayerLineItems.joined(separator: "\n")
    }

    // MARK: - 번호 접두사 파싱

    /// 줄 앞의 번호를 반환 (없으면 nil). "1. ", "2) ", "3] " 형태를 인식한다.
    fileprivate var leadingPrayerNumber: Int? {
        var rest: Substring = self.drop(while: { $0 == " " || $0 == "\t" })

        let digits: Substring = rest.prefix(while: { $0.isNumber })
        // 3자리 이상은 연도·금액 등으로 보고 번호로 취급하지 않음 ("2025. 목표")
        guard !digits.isEmpty, digits.count <= 2, let number = Int(digits) else { return nil }

        rest = rest.dropFirst(digits.count).drop(while: { $0 == " " })
        guard let separator = rest.first, ".)]".contains(separator) else { return nil }

        return number
    }

    /// 줄 앞의 번호 접두사를 제거한 문자열 (번호가 없으면 원본 그대로)
    fileprivate var strippingPrayerNumberPrefix: String {
        guard leadingPrayerNumber != nil else { return self }

        var rest: Substring = self.drop(while: { $0 == " " || $0 == "\t" })
        rest = rest.drop(while: { $0.isNumber })
        rest = rest.drop(while: { $0 == " " })
        rest = rest.dropFirst()   // 구분자(. ) ])
        return String(rest.drop(while: { $0 == " " || $0 == "\t" }))
    }
}
