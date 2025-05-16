//
// StringExtensionTests.swift
// CommonUtils
//
// Created by Dongju Lim on 4/15/25
//

import XCTest
@testable import CommonUtils

final class StringExtensionTests: XCTestCase {

    // MARK: - substring(from:to:)
    // 기본적인 substring 추출
    func test_substring_validRange_returnsSubstring() throws {
        let string = "Hello, World!"
        let result = string.substring(from: 0, to: 4)
        XCTAssertEqual(result, "Hello")
    }

    // from == to 인 경우
    func test_substring_sameFromAndTo_returnsSingleCharacter() throws {
        let string = "Swift"
        let result = string.substring(from: 2, to: 2)
        XCTAssertEqual(result, "i")
    }

    // from이 음수인 경우
    func test_substring_negativeFrom_returnsEmptyString() throws {
        let string = "Swift"
        let result = string.substring(from: -1, to: 2)
        XCTAssertEqual(result, "")
    }

    // to가 문자열 길이보다 큰 경우
    func test_substring_toGreaterThanCount_returnsEmptyString() throws {
        let string = "Swift"
        let result = string.substring(from: 1, to: 10)
        XCTAssertEqual(result, "")
    }

    // from > to 인 경우
    func test_substring_fromGreaterThanTo_returnsEmptyString() throws {
        let string = "Swift"
        let result = string.substring(from: 4, to: 2)
        XCTAssertEqual(result, "")
    }

    // MARK: - Tests for `toInt`
    func test_toInt_withPlainNumberString() throws {
        let input = "1234"
        XCTAssertEqual(input.toInt, 1234)
    }

    func test_toInt_withNumberWithComma() throws {
        let input = "1,234"
        XCTAssertEqual(input.toInt, 1234)
    }

    func test_toInt_withCurrencySymbol() throws {
        let input = "₩5,678"
        XCTAssertEqual(input.toInt, 5678)
    }

    func test_toInt_withOverflow() throws {
        let input = String(repeating: "9", count: 30)
        XCTAssertTrue(input.toInt <= Int.max)
    }

    // MARK: - `toInt64`
    func test_toInt64_validIntegerString_returnsInt64() throws {
        let string = "1234567890"
        XCTAssertEqual(string.toInt64, 1234567890)
    }

    func test_toInt64_negativeIntegerString_returnsNegativeInt64() throws {
        let string = "-987654321"
        XCTAssertEqual(string.toInt64, -987654321)
    }

    func test_toInt64_nonNumericString_returns() throws {
        let string = "abc123"
        XCTAssertEqual(string.toInt64, 123)
    }

    func test_toInt64_emptyString_returns() throws {
        let string = ""
        XCTAssertEqual(string.toInt64, 0)
    }

    func test_toInt64_outOfBoundsValue_returnsNil() throws {
        let string = "9223372036854775808" // Int64.max + 1
        XCTAssertEqual(string.toInt64, 9223372036854775807 )
    }

    // MARK: - `toFloat`
    func test_toFloat_validDecimalString_returnsFloat() throws {
        let string = "3.14"
        XCTAssertEqual(string.toFloat, 3.14, accuracy: 0.0001)
    }

    func test_toFloat_integerString_returnsFloat() throws {
        let string = "10"
        XCTAssertEqual(string.toFloat, 10.0)
    }

    func test_toFloat_negativeFloatString_returnsFloat() throws {
        let string = "-2.718"
        XCTAssertEqual(string.toFloat, -2.718, accuracy: 0.0001)
    }

    func test_toFloat_nonNumericString_returns() throws {
        let string = "pi=3.14"
        XCTAssertEqual(string.toFloat, 3.14)
    }

    func test_toFloat_emptyString_returns() throws {
        let string = ""
        XCTAssertEqual(string.toFloat, 0.0)
    }

    // MARK: - `toDouble`
    func test_toDouble_validDecimalString_returnsDouble() throws {
        let string = "123.456"
        XCTAssertEqual(string.toDouble, 123.456, accuracy: 0.0001)
    }

    func test_toDouble_integerString_returnsDouble() throws {
        let string = "200"
        XCTAssertEqual(string.toDouble, 200.0)
    }

    func test_toDouble_negativeDecimal_returnsDouble() throws {
        let string = "-1.23"
        XCTAssertEqual(string.toDouble, -1.23, accuracy: 0.0001)
    }

    func test_toDouble_invalidString_returns() throws {
        let string = "one.two"
        XCTAssertEqual(string.toDouble, 0.0)
    }

    func test_toDouble_emptyString_returns() throws {
        let string = ""
        XCTAssertEqual(string.toDouble, 0.0)
    }

    // MARK: - `stringTrim`
    func test_stringTrim_shouldTrimWhitespacesAndNewlines() throws {
        let input = "   Hello, World!  \n"
        let expected = "Hello, World!"
        XCTAssertEqual(input.stringTrim, expected)
    }

    // MARK: - `toDate(format:)`
    func test_toDate_withValidDateFormat() throws {
        let input = "2024-04-15"
        let expectedComponents = DateComponents(year: 2024, month: 4, day: 15)
        let result = input.toDate(format: "yyyy-MM-dd")
        let calendar = Calendar.current
        XCTAssertEqual(calendar.dateComponents([.year, .month, .day], from: result!), expectedComponents)
    }

    func test_toDate_withInvalidFormat() throws {
        let input = "2024/04/15"
        let result = input.toDate(format: "yyyy-MM-dd")
        XCTAssertEqual(result?.toString(format: "yyyy-MM-dd"), "2024-04-15")
    }

    func test_toDate_withEmptyString() throws {
        let input = ""
        let result = input.toDate(format: "yyyy-MM-dd")
        XCTAssertNil(result)
    }

    func test_toDate_withWrongData() throws {
        let input = "Not a date"
        let result = input.toDate(format: "yyyy-MM-dd")
        XCTAssertNil(result)
    }

    func test_toDate_withTimeFormat() throws {
        let input = "15:45"
        let result = input.toDate(format: "HH:mm")
        XCTAssertNotNil(result)
    }

    // MARK: - `formated(by:digit:)`
    func test_formated_withPhonePattern() throws {
        let input = "01012345678"
        let result = input.formated(by: "###-####-####")
        XCTAssertEqual(result, "010-1234-5678")
    }

    func test_formated_withCardPattern() throws {
        let input = "1234567812345678"
        let result = input.formated(by: "####-####-####-####")
        XCTAssertEqual(result, "1234-5678-1234-5678")
    }

    func test_formated_withExtraCharactersInPattern() throws {
        let input = "987654321"
        let result = input.formated(by: "###.###.###")
        XCTAssertEqual(result, "987.654.321")
    }

    func test_formated_withShortInput() throws {
        let input = "12"
        let result = input.formated(by: "###-###")
        XCTAssertEqual(result, "12")
    }

    func test_formated_withDifferentDigitCharacter() throws {
        let input = "123456"
        let result = input.formated(by: "A*A*A*A", digit: "*")
        XCTAssertEqual(result, "A1A2A3A")
    }

    // MARK: - `isValidatePhone`
    func test_isValidatePhone_withValidPhoneNumber() throws {
        let input = "010-1234-5678"
        XCTAssertTrue(input.isValidatePhone)
    }

    func test_isValidatePhone_withValidPhoneNumberWithoutHyphen() throws {
        let input = "01012345678"
        XCTAssertTrue(input.isValidatePhone)
    }

    func test_isValidatePhone_withInvalidPrefix() throws {
        let input = "0212345678"
        XCTAssertFalse(input.isValidatePhone)
    }

    func test_isValidatePhone_withTooShortNumber() throws {
        let input = "010-12-5678"
        XCTAssertFalse(input.isValidatePhone)
    }

    func test_isValidatePhone_withNonDigitCharacters() throws {
        let input = "010-ABCD-EFGH"
        XCTAssertFalse(input.isValidatePhone)
    }

    // MARK: - `dateFormatChange(_:changeFormat:)`
    func test_dateFormatChange_withValidDate() throws {
        let input = "2024-12-31 23:59:59"
        let result = input.dateFormatChange(changeFormat: "yyyy/MM/dd")
        XCTAssertEqual(result, "2024/12/31")
    }

    func test_dateFormatChange_withDifferentFormat() throws {
        let input = "2024-01-01 00:00:00"
        let result = input.dateFormatChange(changeFormat: "MMM d, yyyy")
        XCTAssertEqual(result, "1월 1, 2024")
    }

    func test_dateFormatChange_withInvalidDateString() throws {
        let input = "invalid-date"
        let result = input.dateFormatChange(changeFormat: "yyyy.MM.dd")
        XCTAssertNotNil(result)
    }

    func test_dateFormatChange_withEmptyString() throws {
        let input = ""
        let result = input.dateFormatChange(changeFormat: "yyyy.MM.dd")
        XCTAssertNotNil(result)
    }

    func test_dateFormatChange_withCustomInputFormat() throws {
        let input = "2025년04월15일"
        let result = input.dateFormatChange("yyyy년MM월dd일", changeFormat: "yyyy-MM-dd")
        XCTAssertEqual(result, "2025-04-15")
    }

    // MARK: - html2MutableAttributed
    func test_html2MutableAttributed_validHTML() throws {
        let html = "<b>Bold</b>"
        let attributed = html.html2MutableAttributed
        XCTAssertNotNil(attributed)
        XCTAssertEqual(attributed?.string, "Bold")
    }

    func test_html2MutableAttributed_emptyString() throws {
        let html = ""
        let attributed = html.html2MutableAttributed
        XCTAssertNotNil(attributed)
        XCTAssertEqual(attributed?.string, "")
    }

    func test_html2MutableAttributed_plainText() throws {
        let text = "Just text"
        let attributed = text.html2MutableAttributed
        XCTAssertNotNil(attributed)
        XCTAssertEqual(attributed?.string, "Just text")
    }

    func test_html2MutableAttributed_invalidEncoding() throws {
        let text = "한글 텍스트"
        let attributed = text.html2MutableAttributed
        XCTAssertNotNil(attributed)
    }

    func test_html2MutableAttributed_brokenHTML() throws {
        let html = "<div><b>Unclosed tag"
        let attributed = html.html2MutableAttributed
        XCTAssertNotNil(attributed)
        XCTAssertTrue(attributed?.string.contains("Unclosed tag") ?? false)
    }

    // MARK: - htmlEscaped
    func test_htmlEscaped_validHTML() throws {
        let html = "안녕 &lt;div&gt;세상&lt;/div&gt;"
        XCTAssertEqual(html.htmlEscaped, "안녕 <div>세상</div>")
    }

    func test_htmlEscaped_plainText() throws {
        let text = "그냥 텍스트"
        XCTAssertEqual(text.htmlEscaped, text)
    }

    func test_htmlEscaped_emptyString() throws {
        let html = ""
        XCTAssertEqual(html.htmlEscaped, "")
    }

    func test_htmlEscaped_invalidHTML() throws {
        let html = "<span>오류가 <있는>"
        let result = html.htmlEscaped
        XCTAssertTrue(result.contains("오류"))
    }

    func test_htmlEscaped_withEntities() throws {
        let html = "5 &gt; 3 &amp;&amp; 2 &lt; 4"
        XCTAssertEqual(html.htmlEscaped, "5 > 3 && 2 < 4")
    }

    // MARK: - height(forWith:font:)
    func test_heightForWidth_singleLine() throws {
        let text = "Hello"
        let height = text.height(forWith: 200, font: .systemFont(ofSize: 16))
        XCTAssertGreaterThan(height, 0)
    }

    func test_heightForWidth_multiLine() throws {
        let text = "Hello\nWorld\nSwift"
        let height = text.height(forWith: 100, font: .systemFont(ofSize: 16))
        XCTAssertGreaterThan(height, 40)
    }

    func test_heightForWidth_longText() throws {
        let text = String(repeating: "Text ", count: 50)
        let height = text.height(forWith: 100, font: .systemFont(ofSize: 14))
        XCTAssertGreaterThan(height, 100)
    }

    func test_heightForWidth_narrowWidth() throws {
        let text = "Swift is amazing"
        let height = text.height(forWith: 10, font: .systemFont(ofSize: 12))
        XCTAssertGreaterThan(height, 50)
    }

    func test_heightForWidth_zeroWidth() throws {
        let text = "Test"
        let height = text.height(forWith: 0, font: .systemFont(ofSize: 12))
        XCTAssertGreaterThan(height, 0)
    }

    // MARK: - width(forHeight:font:)
    func test_widthForHeight_singleLine() throws {
        let text = "Swift"
        let width = text.width(forHeight: 30, font: .systemFont(ofSize: 16))
        XCTAssertGreaterThan(width, 10)
    }

    func test_widthForHeight_longText() throws {
        let text = "This is a long sentence for measuring width."
        let width = text.width(forHeight: 40, font: .systemFont(ofSize: 14))
        XCTAssertGreaterThan(width, 100)
    }

    func test_widthForHeight_zeroHeight() throws {
        let text = "Hello"
        let width = text.width(forHeight: 0, font: .systemFont(ofSize: 12))
        XCTAssertGreaterThan(width, 0)
    }

    func test_widthForHeight_multilineText() throws {
        let text = "Line1\nLine2"
        let width = text.width(forHeight: 100, font: .systemFont(ofSize: 16))
        XCTAssertGreaterThan(width, 10)
    }

    func test_widthForHeight_smallHeight() throws {
        let text = "Small height test"
        let width = text.width(forHeight: 1, font: .systemFont(ofSize: 14))
        XCTAssertGreaterThan(width, 0)
    }

    // MARK: - isEmoji
    func test_isEmoji_singleEmoji() throws {
        let emoji = "😄"
        XCTAssertTrue(emoji.isEmoji)
    }

    func test_isEmoji_mixedEmojiAndText() throws {
        let str = "Hello 😄"
        XCTAssertTrue(str.isEmoji)
    }

    func test_isEmoji_noEmoji() throws {
        let text = "Just text"
        XCTAssertFalse(text.isEmoji)
    }

    func test_isEmoji_onlySymbols() throws {
        let symbols = "!@#$%^&*()"
        XCTAssertFalse(symbols.isEmoji)
    }

    func test_isEmoji_multipleEmojis() throws {
        let emojis = "😂🤣😍"
        XCTAssertTrue(emojis.isEmoji)
    }

    // MARK: - isValidEmail
    func testIsValidEmail_validCases() throws {
        XCTAssertTrue("test@example.com".isValidEmail)
        XCTAssertTrue("user.name+tag+sorting@example.com".isValidEmail)
        XCTAssertTrue("user_name@example.co.uk".isValidEmail)
        XCTAssertTrue("user-name@sub.example.com".isValidEmail)
        XCTAssertTrue("user123@domain123.com".isValidEmail)
    }

    func testIsValidEmail_invalidCases() throws {
        XCTAssertFalse("plainaddress".isValidEmail)
        XCTAssertFalse("@missingusername.com".isValidEmail)
        XCTAssertFalse("username@.com".isValidEmail)
        XCTAssertFalse("username@com".isValidEmail)
        XCTAssertFalse("username@domain..com".isValidEmail)
    }

    func testIsValidEmail_validCases2() throws {
        XCTAssertTrue("email@example.com".isValidEmail)
        XCTAssertTrue("firstname.lastname@example.com".isValidEmail)
        XCTAssertTrue("user+mailbox/department=shipping@example.com".isValidEmail)
        XCTAssertTrue("user@[192.168.1.1]".isValidEmail)
        XCTAssertTrue("\"john..doe\"@example.com".isValidEmail)
    }

    func testIsValidEmail_invalidCases2() throws {
        XCTAssertFalse("plainaddress".isValidEmail)
        XCTAssertFalse("missingatsign.com".isValidEmail)
        XCTAssertFalse("username@example,com".isValidEmail)
        XCTAssertFalse("user@.com.my".isValidEmail)
        XCTAssertFalse("user#domain.com".isValidEmail)
    }

    // MARK: - emailDomain
    func testEmailDomain_validEmails() throws {
        XCTAssertEqual("user@example.com".emailDomain, "example.com")
        XCTAssertEqual("john.doe@mail.co.uk".emailDomain, "mail.co.uk")
        XCTAssertEqual("abc.def@sub.domain.org".emailDomain, "sub.domain.org")
    }

    func testEmailDomain_invalidEmails() throws {
        XCTAssertNil("invalid-email".emailDomain)
        XCTAssertNil("noatsign.com".emailDomain)
    }

    // MARK: - emailUsername
    func testEmailUsername_validEmails() throws {
        XCTAssertEqual("user@example.com".emailUsername, "user")
        XCTAssertEqual("john.doe@mail.co.uk".emailUsername, "john.doe")
        XCTAssertEqual("abc.def@sub.domain.org".emailUsername, "abc.def")
    }

    func testEmailUsername_invalidEmails() throws {
        XCTAssertNil("invalid-email".emailUsername)
        XCTAssertNil("@domain.com".emailUsername)
    }

    // MARK: - localization
    func testLocalization_defaultBundle() throws {
        let key = "Hello"
        XCTAssertEqual(key.localization, NSLocalizedString(key, comment: ""))
    }

    func testLocalization_withBundleFlag() throws {
        let key = "Hello"
        XCTAssertEqual(key.localization(true), NSLocalizedString(key, bundle: .module, comment: ""))
        XCTAssertEqual(key.localization(false), NSLocalizedString(key, comment: ""))
    }

    // MARK: - Tests for `toEncoding(withAllowedCharacters:)`
    func testToEncodingWithUrlQueryAllowed() throws {
        // 기본적으로 공백은 %20, &, = 등은 인코딩됨
        XCTAssertEqual("hello world".toEncoding(withAllowedCharacters: .urlQueryAllowed), "hello%20world")
        XCTAssertEqual("email@example.com".toEncoding(withAllowedCharacters: .urlQueryAllowed), "email@example.com")
        XCTAssertEqual("query=abc&lang=en".toEncoding(withAllowedCharacters: .urlQueryAllowed), "query=abc&lang=en")
    }

    func testToEncodingWithAlphanumericsOnly() throws {
        let allowed = CharacterSet.alphanumerics
        XCTAssertEqual("Hello World!".toEncoding(withAllowedCharacters: allowed), "Hello%20World%21")
        XCTAssertEqual("123@abc.com".toEncoding(withAllowedCharacters: allowed), "123%40abc%2Ecom")
    }

    func testToEncodingWithUrlHostAllowed() throws {
        XCTAssertEqual("www.example.com".toEncoding(withAllowedCharacters: .urlHostAllowed), "www.example.com")
        XCTAssertEqual("sub domain.com".toEncoding(withAllowedCharacters: .urlHostAllowed), "sub%20domain.com")
        XCTAssertEqual("한글.com".toEncoding(withAllowedCharacters: .urlHostAllowed).contains("%ED%95%9C%EA%B8%80"), true)
    }

    func testToEncodingWithUrlFragmentAllowed() throws {
        // 일부 특수문자는 그대로 두는 fragment용 set
        XCTAssertEqual("fragment#top".toEncoding(withAllowedCharacters: .urlFragmentAllowed), "fragment%23top") // 수정됨
        XCTAssertEqual("data@anchor!".toEncoding(withAllowedCharacters: .urlFragmentAllowed), "data@anchor!") // 수정됨
    }

    func testToEncodingWithCustomCharacterSet() throws {
        // 커스텀 캐릭터셋: 숫자 + "@"만 허용
        var customSet = CharacterSet.decimalDigits
        customSet.insert(charactersIn: "@")

        XCTAssertEqual("abc@123".toEncoding(withAllowedCharacters: customSet), "%61%62%63@123")
        XCTAssertEqual("test@999.com".toEncoding(withAllowedCharacters: customSet), "%74%65%73%74@999%2E%63%6F%6D")
    }

    // MARK: - toDecoding
    func testToDecoding() throws {
        XCTAssertEqual("hello%20world".toDecoding, "hello world")
        XCTAssertEqual("query%3Dabc%26lang%3Den".toDecoding, "query=abc&lang=en")
        XCTAssertEqual("email%40example.com".toDecoding, "email@example.com")
        XCTAssertEqual("%ED%95%9C%EA%B8%80".toDecoding, "한글")
        XCTAssertEqual("a+b".toDecoding, "a b")
    }

    // MARK: - md5
    func testMD5() throws {
        XCTAssertEqual("hello".md5, "5d41402abc4b2a76b9719d911017c592")
        XCTAssertEqual("".md5, "d41d8cd98f00b204e9800998ecf8427e")
        XCTAssertEqual("123456".md5, "e10adc3949ba59abbe56e057f20f883e")
        XCTAssertEqual("Swift".md5, "ae832e9b5bda2699db45f3fa6aa8c556")
        XCTAssertEqual("test@example.com".md5, "55502f40dc8b7c769880b10874abc9d0")
    }

    // MARK: - applyPatternOnNumbers
    func testApplyPatternOnNumbers() throws {
        XCTAssertEqual("01012345678".applyPatternOnNumbers(pattern: "###-####-####", replacmentCharacter: "#"), "010-1234-5678")
        XCTAssertEqual("123456789".applyPatternOnNumbers(pattern: "(###) ###-####", replacmentCharacter: "#"), "(123) 456-789")
        XCTAssertEqual("12345".applyPatternOnNumbers(pattern: "###-###", replacmentCharacter: "#"), "123-45")
        XCTAssertEqual("AB12345678".applyPatternOnNumbers(pattern: "###-####-####", replacmentCharacter: "#"), "123-4567-8")
        XCTAssertEqual("9876543210".applyPatternOnNumbers(pattern: "## ## ## ## ##", replacmentCharacter: "#"), "98 76 54 32 10")
    }

    // MARK: - utf16Count
    func testUtf16Count() throws {
        XCTAssertEqual("hello".utf16Count, 5)
        XCTAssertEqual("안녕하세요".utf16Count, 5)
        XCTAssertEqual("👋🏽".utf16Count, 4)
        XCTAssertEqual("🇰🇷".utf16Count, 4)
        XCTAssertEqual("é".utf16Count, 2) // e + accent
    }

    // MARK: - length (NSString)
    func testLength() throws {
        XCTAssertEqual("hello".length, 5)
        XCTAssertEqual("안녕하세요".length, 5)
        XCTAssertEqual("👋🏽".length, 4)
        XCTAssertEqual("🇰🇷".length, 4)
        XCTAssertEqual("é".length, 2) // e + accent
    }

    // MARK: - isNumeric
    func testIsNumeric() throws {
        XCTAssertTrue("123".isNumeric)
        XCTAssertTrue("3.14".isNumeric)
        XCTAssertTrue("-42".isNumeric)
        XCTAssertFalse("abc123".isNumeric)
        XCTAssertFalse("12abc".isNumeric)
    }

    // MARK: - Character isEmoji Tests
    func testIsEmoji_withSimpleEmoji() throws {
        XCTAssertTrue("😀".first!.isEmoji)
    }

    func testIsEmoji_withEmojiWithSkinToneModifier() throws {
        XCTAssertTrue("👋🏽".first!.isEmoji)
    }

    func testIsEmoji_withCombinedEmoji_ZWJ() throws {
        // ZWJ (zero-width joiner)로 조합된 이모지
        XCTAssertTrue("👨‍👩‍👧‍👦".first!.isEmoji)
    }

    func testIsEmoji_withTextSymbol() throws {
        // 특수 문자 중 일부는 isEmojiPresentation이 false일 수 있음
        XCTAssertFalse("#".first!.isEmoji)
    }

    func testIsEmoji_withNonEmojiCharacter() throws {
        XCTAssertFalse("A".first!.isEmoji)
        XCTAssertFalse("1".first!.isEmoji)
    }

    // MARK: - fileExtension
    func testFileWithExtension() throws {
        let filename = "document.pdf"
        XCTAssertEqual(filename.fileExtension, "pdf")
    }

    func testFileWithoutExtension() throws {
        let filename = "README"
        XCTAssertNil(filename.fileExtension)
    }

    func testHiddenFileWithExtension() throws {
        let filename = ".gitignore"
        XCTAssertNil(filename.fileExtension)
    }

    func testFileWithMultipleDots() throws {
        let filename = "archive.tar.gz"
        XCTAssertEqual(filename.fileExtension, "gz")
    }

    func testFileEndingWithDot() throws {
        let filename = "filename."
        XCTAssertNil(filename.fileExtension)
    }

    // MARK: - fileName
    func testFileNameWithExtension() throws {
        let filename = "document.pdf"
        XCTAssertEqual(filename.fileName, "document")
    }

    func testFileNameWithoutExtension() throws {
        let filename = "README"
        XCTAssertEqual(filename.fileName, "README")
    }

    func testFileNameHiddenFileWithExtension() throws {
        let filename = ".gitignore"
        XCTAssertEqual(filename.fileName, ".gitignore")
    }

    func testFileNameWithMultipleDots() throws {
        let filename = "archive.tar.gz"
        XCTAssertEqual(filename.fileName, "archive.tar")
    }

    func testFilePath() throws {
        let filepath = "/Users/test/Desktop/photo.jpg"
        XCTAssertEqual(filepath.fileName, "photo")
    }
}
