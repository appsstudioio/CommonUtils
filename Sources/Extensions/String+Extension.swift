//
//  String+Extension.swift
//
//
// Created by Dongju Lim on 2023/06/14.
//

import Foundation
import UIKit
import CryptoKit

public extension String {
    func substring(from: Int, to: Int) -> String {
        guard from >= 0, to >= from, from < count, to < count else {
            return ""
        }

        guard let startIndex = self.index(self.startIndex, offsetBy: from, limitedBy: self.endIndex),
              let endIndex = self.index(self.startIndex, offsetBy: to + 1, limitedBy: self.endIndex) else {
            return ""
        }
        return String(self[startIndex ..< endIndex])
    }
    
    // 자릿수 제거
    // https://velog.io/@baecheese
    var toInt: Int {
        let pureNumberString = self.pureNumberString
        if let number = Decimal(string: pureNumberString) {
            let intMax = Decimal(Int.max)
            let intMin = Decimal(Int.min)

            if number > intMax {
                return Int.max
            } else if number < intMin {
                return Int.min
            } else {
                return NSDecimalNumber(decimal: number).intValue
            }
        }
        return 0
    }
    
    var toInt64: Int64 {
        let pureNumberString = self.pureNumberString

        if let number = Decimal(string: pureNumberString) {
            let int64Max = Decimal(Int64.max)
            let int64Min = Decimal(Int64.min)

            if number > int64Max {
                return Int64.max
            } else if number < int64Min {
                return Int64.min
            } else {
                return NSDecimalNumber(decimal: number).int64Value
            }
        }

        return 0
    }

    var toFloat: Float {
        guard let value = self.replaceToPureNumber else { return 0 }
        return Float(value)
    }
    
    var toDouble: Double {
        guard let value = self.replaceToPureNumber else { return 0 }
        return value
    }

    private var pureNumberString: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "ko_KR")
        let groupingSeparator = numberFormatter.groupingSeparator ?? ""
        let decimalSeparator = numberFormatter.decimalSeparator ?? ""

        return self.replacingOccurrences(of: "[^\(decimalSeparator)\(groupingSeparator)0-9\\-]", with: "", options: .regularExpression)
            .replacingOccurrences(of: groupingSeparator, with: "")
            .replacingOccurrences(of: decimalSeparator, with: ".")
    }

    private var replaceToPureNumber: Double? {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "ko_KR")
        let groupingSeparator = numberFormatter.groupingSeparator ?? "" // 천단위 기호
        let decimalSeparator = numberFormatter.decimalSeparator ?? "" // 소숫점 기호

        let valueString = self
            .replacingOccurrences(of: "[^\(decimalSeparator)\(groupingSeparator)0-9\\-]", with: "", options: .regularExpression)
            .replacingOccurrences(of: groupingSeparator, with: "")
            .replacingOccurrences(of: decimalSeparator, with: ".")

        return Double(valueString)
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
                DebugLog("Error creating attributed string: \(self)")
                return nil
            }
            
            return try NSMutableAttributedString(data: data,
                                                 options: [.documentType: NSMutableAttributedString.DocumentType.html,
                                                           .characterEncoding: String.Encoding.utf8.rawValue],
                                                 documentAttributes: nil)
        } catch {
            DebugLog("Error creating attributed string: \(error.localizedDescription)")
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
            // 더 정확한 이모지 확인 조건 추가
            if scalar.properties.isEmoji && scalar.properties.isEmojiPresentation {
                return true
            }
            continue
        }
        return false
    }

    /// Checks if the string is a valid email address.
    /// - Returns: A boolean indicating if the email is valid according to RFC 5322 format and disallows consecutive dots in domain.
    var isValidEmail: Bool {
        let emailRegEx = #"^(?:[\p{L}0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[\p{L}0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[\p{L}0-9](?:[a-z0-9-]*[\p{L}0-9])?\.)+[\p{L}0-9](?:[\p{L}0-9-]*[\p{L}0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[\p{L}0-9-]*[\p{L}0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])$"#

        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        guard predicate.evaluate(with: self) else { return false }

        // Prevent domain part from containing consecutive dots (e.g., "domain..com")
        if let domainPart = self.components(separatedBy: "@").last,
           domainPart.contains("..") {
            return false
        }

        return true
    }

    // Extracts the domain part from an email address
    // - Returns: Optional string containing the domain, or nil if not a valid email
    var emailDomain: String? {
        guard self.isValidEmail else { return nil }
        let components = self.components(separatedBy: "@")
        return components.count > 1 ? components[1] : nil
    }

    // Extracts the username part from an email address
    // - Returns: Optional string containing the username, or nil if not a valid email
    var emailUsername: String? {
        guard self.isValidEmail else { return nil }
        let components = self.components(separatedBy: "@")
        return components.first
    }

    var localization: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localization(_ isBundle: Bool = true) -> String {
        return (isBundle ? NSLocalizedString(self, bundle: Bundle.module, comment: "") : NSLocalizedString(self, comment: ""))
    }

    func toEncoding(withAllowedCharacters characters: CharacterSet) -> String {
        return self.addingPercentEncoding(withAllowedCharacters: characters) ?? self
    }
    
    var toDecoding: String {
        let returnString = self.replacingOccurrences(of: "+", with: "%20")
        return returnString.removingPercentEncoding ?? self
    }

    var md5: String {
        let digest = Insecure.MD5.hash(data: self.data(using: .utf8) ?? Data())
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }

    func applyPatternOnNumbers(pattern: String, replacmentCharacter: Character) -> String {
        let numbers = self.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var numberIndex = numbers.startIndex
        for ch in pattern {
            if ch == replacmentCharacter {
                guard numberIndex < numbers.endIndex else { break }
                result.append(numbers[numberIndex])
                numberIndex = numbers.index(after: numberIndex)
            } else {
                result.append(ch)
            }
        }
        return result
    }

    // UTF-16 기반의 실제 커서 위치를 계산하는 방법
    var utf16Count: Int {
        return utf16.count
    }

    // NSString을 사용한 길이 계산
    var length: Int {
        return (self as NSString).length
    }

    var isNumeric : Bool {
        return NumberFormatter().number(from: self) != nil
    }

    /// 텍스트를 이미지로 변환하는 함수
    /// - Parameters:
    ///   - font: 텍스트에 사용할 폰트
    ///   - textColor: 텍스트 색상
    ///   - backgroundColor: 배경 색상 (기본값: 투명)
    ///   - size: 생성할 이미지의 크기
    /// - Returns: 변환된 UIImage
    func toImage(
        font: UIFont,
        textColor: UIColor,
        backgroundColor: UIColor = .clear,
        size: CGSize
    ) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            // 배경 색상 설정
            if backgroundColor != .clear {
                context.cgContext.setFillColor(backgroundColor.cgColor)
                context.cgContext.fill(CGRect(origin: .zero, size: size))
            }

            // 텍스트 속성 설정
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: textColor
            ]

            // 텍스트 크기 계산
            let textSize = self.size(withAttributes: attributes)

            // 텍스트를 이미지 중앙에 위치시키기
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            self.draw(in: textRect, withAttributes: attributes)
        }
    }

    ///  확장자를  반환합니다.
    var fileExtension: String? {
        let url = URL(fileURLWithPath: self)
        let ext = url.pathExtension
        return ext.isEmpty ? nil : ext
    }

    /// 파일 경로 또는 파일명에서 확장자를 제외한 파일 이름을 반환합니다.
    var fileName: String {
        let url = URL(fileURLWithPath: self)
        return url.deletingPathExtension().lastPathComponent
    }

}

public extension Character {
    var isEmoji: Bool {
        guard let scalar = self.unicodeScalars.first else { return false }
        // "1"은 유니코드 스칼라에서 이모티콘으로 간주되는 특성이 있음, 숫자(0-9), #, *와 같은 텍스트 기반 유니코드 심볼을 무시 (0x238C)
        return scalar.properties.isEmoji && (scalar.properties.isEmojiPresentation || scalar.value > 0x238C)
    }
}
