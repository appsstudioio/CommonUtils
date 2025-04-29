//
//  HangeulSearch.swift
// 
//
// Created by Dongju Lim on 12/5/23.
//

import Foundation

// 참고
// https://velog.io/@woojusm/Swift-%ED%95%9C%EA%B8%80-%EC%9E%90%EB%AA%A8-%EB%B6%84%EB%A6%AC-%EA%B2%80%EC%83%89

public extension CharacterSet {
    static let modernHangul = CharacterSet(charactersIn: ("가"..."힣"))
}

public final class HangeulSearch {

    // UTF-8 기준
    private static let indexStart: UInt32 = 0xAC00 // 가
    private static let indexEnd: UInt32   = 0xD7A3   // 힣
    private static let cycleCho: UInt32   = 588
    private static let cycleJung: UInt32  = 28

    private static let cho = [
        "ㄱ","ㄲ","ㄴ","ㄷ","ㄸ","ㄹ","ㅁ","ㅂ","ㅃ","ㅅ",
        "ㅆ","ㅇ","ㅈ","ㅉ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"
    ]

    private static let jung = [
        "ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ","ㅕ", "ㅖ", "ㅗ", "ㅘ",
        "ㅙ", "ㅚ","ㅛ", "ㅜ", "ㅝ", "ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ",
        "ㅣ"
    ]

    private static let jong = [
        "","ㄱ","ㄲ","ㄳ","ㄴ","ㄵ","ㄶ","ㄷ","ㄹ","ㄺ",
        "ㄻ","ㄼ","ㄽ","ㄾ","ㄿ","ㅀ","ㅁ","ㅂ","ㅄ","ㅅ",
        "ㅆ","ㅇ","ㅈ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"
    ]

    private static let jongDouble = [
        "ㄳ":"ㄱㅅ", "ㄵ":"ㄴㅈ", "ㄶ":"ㄴㅎ", "ㄺ":"ㄹㄱ", "ㄻ":"ㄹㅁ",
        "ㄼ":"ㄹㅂ", "ㄽ":"ㄹㅅ", "ㄾ":"ㄹㅌ", "ㄿ":"ㄹㅍ", "ㅀ":"ㄹㅎ",
        "ㅄ":"ㅂㅅ"
    ]

    private static let mo = [
        "ㅘ":"ㅏ", "ㅙ":"ㅐ", "ㅚ":"ㅣ", "ㅝ":"ㅓ", "ㅞ":"ㅔ", "ㅟ":"ㅣ", "ㅢ":"ㅣ"
    ]

    private static let jaValue: [String: Int] = [
        "ㄱ":2, "ㄲ":4, "ㄴ":2, "ㄷ":3, "ㄸ":6,
        "ㄹ":5, "ㅁ":4, "ㅂ":4, "ㅃ":8, "ㅅ":2,
        "ㅆ":4, "ㅇ":1, "ㅈ":3, "ㅉ":6, "ㅊ":4,
        "ㅋ":3, "ㅌ":4, "ㅍ":4, "ㅎ":3, "ㅏ":2,
        "ㅐ":3, "ㅑ":3, "ㅒ":4, "ㅓ":2, "ㅔ":3,
        "ㅕ":3, "ㅖ":4, "ㅗ":2, "ㅘ":4, "ㅙ":5,
        "ㅚ":3, "ㅛ":3, "ㅜ":2, "ㅝ":4, "ㅞ":5,
        "ㅟ":3, "ㅠ":3, "ㅡ":1, "ㅢ":2, "ㅣ":1,
        "ㄳ":4, "ㄵ":5, "ㄶ":5, "ㄺ":7, "ㄻ":9,
        "ㄼ":9, "ㄽ":7, "ㄾ":9, "ㄿ":9, "ㅀ":8,
        "ㅄ":6
    ]

    // MARK: - Public
    public static func getDanmo(_ input: Character) -> Character {
        return Character(mo[String(input)] ?? String(input))
    }

    //이전 입력한 내용과 비교해서 삭제인지 추가 입력인지 확인하는 함수
    public static func isDanmoDelete(previous: [String], current: [String]) -> Bool {
        let preCount = previous.reduce(0) { $0 + (jaValue[$1] ?? 0) }
        let curCount = current.reduce(0) { $0 + (jaValue[$1] ?? 0) }
        return curCount < preCount
    }

    public static func isChosung(_ word: String) -> Bool {
        guard !word.isEmpty else { return false }
        return word.allSatisfy { char in cho.contains { $0.contains(char) } }
    }

    // 주어진 "단어"를 초성만 가져와서 리턴하는 함수
    public static func getCho(_ input: String) -> String {
        return input.unicodeScalars.map { getChoFromScalar($0) ?? "" }.joined()
    }

    // 주어진 "단어"를 자모음으로 분해해서 리턴하는 함수
    public static func getJamo(_ input: String) -> String {
        return input.unicodeScalars.map { getJamoFromScalar($0) ?? "" }.joined()
    }

    public static func getJamoList(_ input: String) -> [String] {
        return input.unicodeScalars.map { getJamoFromScalar($0) ?? "" }
    }

    // MARK: - Private

    private static func getJamoFromScalar(_ scalar: UnicodeScalar) -> String? {
        guard CharacterSet.modernHangul.contains(scalar) else {
            return String(scalar)
        }

        let index = scalar.value - indexStart
        let cho = cho[Int(index / cycleCho)]
        let jung = jung[Int((index % cycleCho) / cycleJung)]
        var jong = jong[Int(index % cycleJung)]

        if let splitJong = jongDouble[jong] {
            jong = splitJong
        }

        return cho + jung + jong
    }

    private static func getChoFromScalar(_ scalar: UnicodeScalar) -> String? {
        guard CharacterSet.modernHangul.contains(scalar) else {
            return String(scalar)
        }

        let index = scalar.value - indexStart
        return cho[Int(index / cycleCho)]
    }
}
