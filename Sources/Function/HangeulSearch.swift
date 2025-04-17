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
    static var modernHangul: CharacterSet{
        return CharacterSet(charactersIn: ("가".unicodeScalars.first!)...("힣".unicodeScalars.first!))
    }
}

public class HangeulSearch {

    // UTF-8 기준
    static let INDEX_HANGUL_START:UInt32 = 44032  // "가"
    static let INDEX_HANGUL_END:UInt32 = 55199    // "힣"

    static let CYCLE_CHO :UInt32 = 588
    static let CYCLE_JUNG :UInt32 = 28

    static let CHO = [
        "ㄱ","ㄲ","ㄴ","ㄷ","ㄸ","ㄹ","ㅁ","ㅂ","ㅃ","ㅅ",
        "ㅆ","ㅇ","ㅈ","ㅉ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"
    ]

    static let JUNG = [
        "ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ","ㅕ", "ㅖ", "ㅗ", "ㅘ",
        "ㅙ", "ㅚ","ㅛ", "ㅜ", "ㅝ", "ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ",
        "ㅣ"
    ]

    static let JONG = [
        "","ㄱ","ㄲ","ㄳ","ㄴ","ㄵ","ㄶ","ㄷ","ㄹ","ㄺ",
        "ㄻ","ㄼ","ㄽ","ㄾ","ㄿ","ㅀ","ㅁ","ㅂ","ㅄ","ㅅ",
        "ㅆ","ㅇ","ㅈ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"
    ]

    static let JONG_DOUBLE = [
        "ㄳ":"ㄱㅅ","ㄵ":"ㄴㅈ","ㄶ":"ㄴㅎ","ㄺ":"ㄹㄱ","ㄻ":"ㄹㅁ",
        "ㄼ":"ㄹㅂ","ㄽ":"ㄹㅅ","ㄾ":"ㄹㅌ","ㄿ":"ㄹㅍ","ㅀ":"ㄹㅎ",
        "ㅄ":"ㅂㅅ"
    ]

    static let MO = [
        "ㅘ":"ㅏ", "ㅙ":"ㅐ", "ㅚ":"ㅣ", "ㅝ":"ㅓ", "ㅞ":"ㅔ", "ㅟ":"ㅣ", "ㅢ":"ㅣ"
    ]

    static let MO_LIST = [
        "ㅘ", "ㅙ", "ㅚ", "ㅝ", "ㅞ", "ㅟ", "ㅢ"
    ]

    static let JA = [
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

    class public func getDanmo(_ input: Character) -> Character {
        for (key, value) in MO {
            if key == "\(input)" {
                return Character(value)
            }
        }
        return input
    }

    //이전 입력한 내용과 비교해서 삭제인지 추가 입력인지 확인하는 함수
    class public func isDanmoDelete(preInputList: [String], inputList: [String]) -> Bool {
        var preCount = 0
        var curCount = 0

        for text in preInputList {
            for (key, value) in JA {
                if text == key  {
                    preCount += value
                    break
                }
            }
        }

        for text in inputList {
            for (key, value) in JA {
                if text == key {
                    curCount += value
                    break
                }
            }
        }

        // print(">><< curCount : \(curCount) preCount \(preCount) 비교 결과 : \(curCount < preCount)")
        if curCount < preCount {
            return true
        }
        return false
    }
    
    class public func isChosung(_ word: String) -> Bool {
        var isChosung = false
        for char in word {
            if 0 < CHO.filter({ $0.contains(char)}).count {
                isChosung = true
            } else {
                isChosung = false
                break
            }
        }
        return isChosung
    }

    // 주어진 "단어"를 초성만 가져와서 리턴하는 함수
    class public func getCho(_ input: String) -> String {
        var jamo = ""
        //let word = input.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: .punctuationCharacters)
        for scalar in input.unicodeScalars{
            jamo += getChoFromOneSyllable(scalar) ?? ""
        }
        return jamo
    }

    // 주어진 "단어"를 자모음으로 분해해서 리턴하는 함수
    class public func getJamo(_ input: String) -> String {
        var jamo = ""
        //let word = input.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: .punctuationCharacters)
        for scalar in input.unicodeScalars{
            jamo += getJamoFromOneSyllable(scalar) ?? ""
        }
        return jamo
    }

    class public func getJamoList(_ input: String) -> [String] {
        var jamos: [String] = []
        //let word = input.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: .punctuationCharacters)
        for scalar in input.unicodeScalars{
            jamos.append(getJamoFromOneSyllable(scalar) ?? "")
        }
        return jamos
    }

    // 주어진 "코드의 음절"을 자모음으로 분해해서 리턴하는 함수
    private class func getJamoFromOneSyllable(_ n: UnicodeScalar) -> String?{
        if CharacterSet.modernHangul.contains(n){
            let index = n.value - INDEX_HANGUL_START
            let cho = CHO[Int(index / CYCLE_CHO)]
            let jung = JUNG[Int((index % CYCLE_CHO) / CYCLE_JUNG)]
            var jong = JONG[Int(index % CYCLE_JUNG)]
            if let disassembledJong = JONG_DOUBLE[jong] {
                jong = disassembledJong
            }
            return cho + jung + jong
        } else {
            return String(UnicodeScalar(n))
        }
    }

    // 주어진 "코드의 음절"중 초성을 분해해서 리턴하는 함수
    private class func getChoFromOneSyllable(_ n: UnicodeScalar) -> String?{
        if CharacterSet.modernHangul.contains(n){
            let index = n.value - INDEX_HANGUL_START
            let cho = CHO[Int(index / CYCLE_CHO)]
            return cho
        } else {
            return String(UnicodeScalar(n))
        }
    }
}
