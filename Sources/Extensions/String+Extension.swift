//
//  String+Extension.swift
//
//
//  Created by 10-N3344 on 2023/06/14.
//

import Foundation
import UIKit
import CryptoKit

public extension String {
    func substring(from: Int, to: Int) -> String {
        guard from < count, to >= 0, to - from >= 0 else {
            return ""
        }
        
        // Index 값 획득
        let startIndex = index(self.startIndex, offsetBy: from)
        let endIndex = index(self.startIndex, offsetBy: to + 1) // '+1'이 있는 이유: endIndex는 문자열의 마지막 그 다음을 가리키기 때문
        
        // 파싱
        return String(self[startIndex ..< endIndex])
    }
    
    // 자릿수 제거
    // https://velog.io/@baecheese
    var toInt: Int {
        let value = self.replaceToPureNumber
        if value > Double(Int.max) {
            let str = self.substring(from: 0, to: (self.count-2))
            return Int(str.replaceToPureNumber)
        }
        return Int(self.replaceToPureNumber)
    }
    
    var toInt64: Int64 {
        let value = self.replaceToPureNumber
        if value > Double(Int64.max) {
            let str = self.substring(from: 0, to: (self.count-2))
            return Int64(str.replaceToPureNumber)
        }
        return Int64(self.replaceToPureNumber)
    }
    
    var toFloat: Float {
        return Float(self.replaceToPureNumber)
    }
    
    var toDouble: Double {
        return self.replaceToPureNumber
    }

    private var replaceToPureNumber: Double {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "ko_KR")
        let groupingSeparator = numberFormatter.groupingSeparator ?? "" // 천단위 기호
        let decimalSeparator = numberFormatter.decimalSeparator ?? "" // 소숫점 기호
        let valueString = self.replacingOccurrences(of: "[^\(decimalSeparator)\(groupingSeparator)0-9]", with: "", options: .regularExpression)
            .replacingOccurrences(of: groupingSeparator, with: "")
            .replacingOccurrences(of: decimalSeparator, with: ".") // 소숫점 기호를 .으로 변경
        return Double(valueString) ?? 0
    }

    var stringTrim: String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    // 문자열으로 버전 비교할때 "1.0.1" > "1.0.0"
    static func == (lhs: String, rhs: String) -> Bool {
        return lhs.compare(rhs, options: .numeric) == .orderedSame
    }

    static func < (lhs: String, rhs: String) -> Bool {
        return lhs.compare(rhs, options: .numeric) == .orderedAscending
    }

    static func <= (lhs: String, rhs: String) -> Bool {
        return lhs.compare(rhs, options: .numeric) == .orderedAscending || lhs.compare(rhs, options: .numeric) == .orderedSame
    }

    static func > (lhs: String, rhs: String) -> Bool {
        return lhs.compare(rhs, options: .numeric) == .orderedDescending
    }

    static func >= (lhs: String, rhs: String) -> Bool {
        return lhs.compare(rhs, options: .numeric) == .orderedDescending || lhs.compare(rhs, options: .numeric) == .orderedSame
    }
    
    private var decimalFilteredString: String {
       return String(unicodeScalars.filter(CharacterSet.decimalDigits.contains))
    }
    
    // https://minios.tistory.com/40
    func formated(by patternString: String, digit: Character = "#") -> String {
        let pattern: [Character] = Array(patternString)
        let input: [Character] = Array(self.decimalFilteredString)
        var formatted: [Character] = []
        var patternIndex = 0
        var inputIndex = 0
        while inputIndex < input.count {
            let inputCharacter = input[inputIndex]

            guard patternIndex < pattern.count else { break }

            switch pattern[patternIndex] == digit {
            case true:
                formatted.append(inputCharacter)
                inputIndex += 1
            case false:
                formatted.append(pattern[patternIndex])
            }
            patternIndex += 1
        }
        return String(formatted)
    }

    // MARK: - 휴대폰 번호 검증 (https://green1229.tistory.com/269)
    var isValidatePhone: Bool {
        let regex = "^01([0|1|6|7|8|9])-?([0-9]{3,4})-?([0-9]{4})$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }

    func toDate(format: String = "yyyy-MM-dd HH:mm:ss", locale: Locale = Locale.current, timeZone: TimeZone = TimeZone.current) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.setKSTFormatter(format: format)
        return dateFormatter.date(from: self)
    }
    
    func dateFormatChange(_ currentFormat: String = "yyyy-MM-dd HH:mm:ss", changeFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.setKSTFormatter(format: currentFormat)
        let date =  dateFormatter.date(from: self)
        dateFormatter.dateFormat = changeFormat
        let dateStr = dateFormatter.string(from: date ?? Date())
        return dateStr
    }
    
    var html2MutableAttributed: NSMutableAttributedString? {
        do {
            guard let data = self.data(using: .utf8) else {
                return nil
            }
            
            return try NSMutableAttributedString(data: data,
                                                 options: [.documentType: NSMutableAttributedString.DocumentType.html,
                                                           .characterEncoding: String.Encoding.utf8.rawValue],
                                                 documentAttributes: nil)
        } catch {
            return nil
        }
    }
    
    // html 태그 제거 + html entity들 디코딩. (https://eunjin3786.tistory.com/138)
    var htmlEscaped: String {
        guard let encodedData = self.data(using: .utf8) else {
            return self
        }
        do {
            let attributed = try NSAttributedString(data: encodedData,
                                                    options: [ .documentType: NSAttributedString.DocumentType.html,
                                                               .characterEncoding: String.Encoding.utf8.rawValue],
                                                    documentAttributes: nil)
            return attributed.string
        } catch {
            return self
        }
    }
    
    func height(forWith width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [NSAttributedString.Key.font: font],
                                            context: nil)

        return ceil(boundingBox.height)
    }

    func width(forHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [NSAttributedString.Key.font: font],
                                            context: nil)

        return ceil(boundingBox.width)
    }
    
    var isEmoji: Bool {
        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F, // Emoticons
                 0x1F300...0x1F5FF, // Misc Symbols and Pictographs
                 0x1F680...0x1F6FF, // Transport and Map
                 0x1F1E6...0x1F1FF, // Regional country flags
                 0x2600...0x26FF,   // Misc symbols
                 0x2700...0x27BF,   // Dingbats
                 0xFE00...0xFE0F,   // Variation Selectors
                 0x1F900...0x1F9FF, // Supplemental Symbols and Pictographs
                 127000...127600,   // Various asian characters
                 65024...65039,     // Variation selector
                 9100...9300,       // Misc items
                 8400...8447        // Combining Diacritical Marks for Symbols
                :
                return true
            default: continue
            }
        }
        return false
    }
    
    var localization: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localization(_ isBundle: Bool = true) -> String {
        return (isBundle ? NSLocalizedString(self, bundle: Bundle.module, comment: "") : NSLocalizedString(self, comment: ""))
    }

    var toEncoding: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
    
    var toDecoding: String {
        let returnString = self.replacingOccurrences(of: "+", with: "%20")
        return returnString.removingPercentEncoding ?? ""
    }

    var md5: String {
        let digest = Insecure.MD5.hash(data: self.data(using: .utf8) ?? Data())
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }

    func applyPatternOnNumbers(pattern: String, replacmentCharacter: Character) -> String {
        var pureNumber = self.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else { return pureNumber }
            let stringIndex = String.Index(utf16Offset: index, in: self)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacmentCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        return pureNumber
    }
}
