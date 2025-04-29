//
// HangeulSearchTests.swift
// CommonUtils
//
// Created by Dongju Lim on 4/25/25
//

import XCTest
@testable import CommonUtils

final class HangeulSearchTests: XCTestCase {

    // MARK: - getDanmo
    func test_getDanmo() throws {
        XCTAssertEqual(HangeulSearch.getDanmo("ㅘ"), "ㅏ")
        XCTAssertEqual(HangeulSearch.getDanmo("ㅙ"), "ㅐ")
        XCTAssertEqual(HangeulSearch.getDanmo("ㅚ"), "ㅣ")
        XCTAssertEqual(HangeulSearch.getDanmo("ㅢ"), "ㅣ")
        XCTAssertEqual(HangeulSearch.getDanmo("ㅏ"), "ㅏ") // 변형 없는 모음
    }

    func test_getDanmo_additionalCases() throws {
        // 1. 복합 모음인 경우 (단모음 반환)
        XCTAssertEqual(HangeulSearch.getDanmo("ㅘ"), "ㅏ")
        // 2. 또 다른 복합 모음
        XCTAssertEqual(HangeulSearch.getDanmo("ㅟ"), "ㅣ")
        // 3. 단모음 자체 입력
        XCTAssertEqual(HangeulSearch.getDanmo("ㅏ"), "ㅏ")
        // 4. 자음 입력 시 변경 없음
        XCTAssertEqual(HangeulSearch.getDanmo("ㄱ"), "ㄱ")
        // 5. 존재하지 않는 자모 입력 시 그대로 반환
        XCTAssertEqual(HangeulSearch.getDanmo("A"), "A")
    }

    // MARK: - isDanmoDelete
    func test_isDanmoDelete() throws {
        XCTAssertTrue(HangeulSearch.isDanmoDelete(previous: ["ㄱ", "ㅏ"], current: ["ㄱ"]))
        XCTAssertFalse(HangeulSearch.isDanmoDelete(previous: ["ㄱ"], current: ["ㄱ", "ㅏ"]))
        XCTAssertTrue(HangeulSearch.isDanmoDelete(previous: ["ㄴ", "ㅞ", "ㄹ"], current: ["ㄴ", "ㅞ"]))
        XCTAssertFalse(HangeulSearch.isDanmoDelete(previous: ["ㄱ", "ㅏ"], current: ["ㄱ", "ㅏ"]))
        XCTAssertTrue(HangeulSearch.isDanmoDelete(previous: ["ㄱ", "ㅏ", "ㄴ"], current: ["ㄱ", "ㅏ"]))
    }

    func test_isDanmoDelete_additionalCases() throws {
        // 1. 고가중치 자모 삭제 (ㅃ: 8)
        XCTAssertTrue(HangeulSearch.isDanmoDelete(previous: ["ㅃ", "ㅣ"], current: ["ㅣ"]))
        // 2. 복합 종성 삭제 (ㄻ: 9)
        XCTAssertTrue(HangeulSearch.isDanmoDelete(previous: ["ㄹ", "ㅓ", "ㄻ"], current: ["ㄹ", "ㅓ"]))
        // 3. 복합 모음 삭제 (ㅘ: 4)
        XCTAssertTrue(HangeulSearch.isDanmoDelete(previous: ["ㄱ", "ㅘ"], current: ["ㄱ"]))
        // 4. 동등한 가중치의 자모 교체 (ㅁ → ㅂ, 둘 다 4)
        XCTAssertFalse(HangeulSearch.isDanmoDelete(previous: ["ㅁ"], current: ["ㅂ"]))
        // 5. 유효하지 않은 자모 포함 (무시됨, 삭제 아님)
        XCTAssertFalse(HangeulSearch.isDanmoDelete(previous: ["ㄱ", "?"], current: ["ㄱ"]))
        // 6. 중복 자모 중 하나 삭제 (ㅅ)
        XCTAssertTrue(HangeulSearch.isDanmoDelete(previous: ["ㅅ", "ㅅ", "ㅣ"], current: ["ㅅ", "ㅣ"]))
        // 7. 모두 삭제된 경우
        XCTAssertTrue(HangeulSearch.isDanmoDelete(previous: ["ㄱ", "ㅏ", "ㅁ"], current: []))
        // 8. 빈 이전 리스트에서 새 자모 추가 (삭제 아님)
        XCTAssertFalse(HangeulSearch.isDanmoDelete(previous: [], current: ["ㄴ"]))
        // 9. 가중치는 같지만 자모가 다른 경우 (삭제 아님)
        XCTAssertFalse(HangeulSearch.isDanmoDelete(previous: ["ㄱ", "ㅏ"], current: ["ㅂ", "ㅣ"]))
        // 10. 무시되는 문자가 추가된 경우 (삭제 아님)
        XCTAssertFalse(HangeulSearch.isDanmoDelete(previous: ["ㅂ", "ㅏ"], current: ["ㅂ", "ㅏ", "#"]))
    }

    // MARK: - isChosung
    func test_isChosung() throws {
        XCTAssertTrue(HangeulSearch.isChosung("ㄱ"))
        XCTAssertTrue(HangeulSearch.isChosung("ㄱㄴㄷ"))
        XCTAssertFalse(HangeulSearch.isChosung("가"))
        XCTAssertFalse(HangeulSearch.isChosung("ㄱㅏ"))
        XCTAssertFalse(HangeulSearch.isChosung("abc"))
    }

    func test_isChosung_additionalCases() throws {
        // 1. 초성으로만 구성된 문자열
        XCTAssertTrue(HangeulSearch.isChosung("ㄱㄴㄷ"))
        // 2. 중간에 일반 문자 포함
        XCTAssertFalse(HangeulSearch.isChosung("ㄱaㄷ"))
        // 3. 빈 문자열
        XCTAssertFalse(HangeulSearch.isChosung(""))
        // 4. 모음만 포함된 경우
        XCTAssertFalse(HangeulSearch.isChosung("ㅏㅓ"))
        // 5. 일반 문자만 있는 경우
        XCTAssertFalse(HangeulSearch.isChosung("abc"))
    }

    // MARK: - getCho
    func test_getCho() throws {
        XCTAssertEqual(HangeulSearch.getCho("가나다"), "ㄱㄴㄷ")
        XCTAssertEqual(HangeulSearch.getCho("하하하"), "ㅎㅎㅎ")
        XCTAssertEqual(HangeulSearch.getCho("감사합니다"), "ㄱㅅㅎㄴㄷ")
        XCTAssertEqual(HangeulSearch.getCho("ABC"), "ABC")
        XCTAssertEqual(HangeulSearch.getCho("한굴aB"), "ㅎㄱaB")
    }

    func test_getCho_additionalCases() throws {
        // 1. 한글 단어의 초성 추출
        XCTAssertEqual(HangeulSearch.getCho("강아지"), "ㄱㅇㅈ")
        // 2. 숫자 포함 시 그대로 포함
        XCTAssertEqual(HangeulSearch.getCho("나3"), "ㄴ3")
        // 3. 초성이 없는 영어 입력
        XCTAssertEqual(HangeulSearch.getCho("ABC"), "ABC")
        // 4. 공백 포함 시 처리
        XCTAssertEqual(HangeulSearch.getCho("가 나"), "ㄱ ㄴ")
        // 5. 특수문자 포함 시 처리
        XCTAssertEqual(HangeulSearch.getCho("ㄱ!ㄴ"), "ㄱ!ㄴ")
    }

    // MARK: - getJamo
    func test_getJamo() throws {
        XCTAssertEqual(HangeulSearch.getJamo("가"), "ㄱㅏ")
        XCTAssertEqual(HangeulSearch.getJamo("각"), "ㄱㅏㄱ")
        XCTAssertEqual(HangeulSearch.getJamo("값"), "ㄱㅏㅂㅅ")
        XCTAssertEqual(HangeulSearch.getJamo("한"), "ㅎㅏㄴ")
        XCTAssertEqual(HangeulSearch.getJamo("한a"), "ㅎㅏㄴa")
    }

    func test_getJamo_additionalCases() throws {
        // 1. 기본 음절 분해
        XCTAssertEqual(HangeulSearch.getJamo("가"), "ㄱㅏ")
        // 2. 받침 있는 음절
        XCTAssertEqual(HangeulSearch.getJamo("강"), "ㄱㅏㅇ")
        // 3. 복합 받침
        XCTAssertEqual(HangeulSearch.getJamo("닭"), "ㄷㅏㄹㄱ")
        // 4. 한글 + 숫자 조합
        XCTAssertEqual(HangeulSearch.getJamo("하2"), "ㅎㅏ2")
        // 5. 영어와 섞인 경우
        XCTAssertEqual(HangeulSearch.getJamo("가a나"), "ㄱㅏaㄴㅏ")
    }

    // MARK: - getJamoList
    func test_getJamoList() throws {
        XCTAssertEqual(HangeulSearch.getJamoList("가"), ["ㄱㅏ"])
        XCTAssertEqual(HangeulSearch.getJamoList("각"), ["ㄱㅏㄱ"])
        XCTAssertEqual(HangeulSearch.getJamoList("값"), ["ㄱㅏㅂㅅ"])
        XCTAssertEqual(HangeulSearch.getJamoList("한"), ["ㅎㅏㄴ"])
        XCTAssertEqual(HangeulSearch.getJamoList("한a"), ["ㅎㅏㄴ", "a"])
    }

    func test_getJamoList_additionalCases() throws {
        // 1. 여러 음절 분해
        XCTAssertEqual(HangeulSearch.getJamoList("강아지"), ["ㄱㅏㅇ", "ㅇㅏ", "ㅈㅣ"])
        // 2. 빈 문자열 처리
        XCTAssertEqual(HangeulSearch.getJamoList(""), [])
        // 3. 특수문자 포함
        XCTAssertEqual(HangeulSearch.getJamoList("가!나"), ["ㄱㅏ", "!", "ㄴㅏ"])
        // 4. 영어 포함
        XCTAssertEqual(HangeulSearch.getJamoList("가b나"), ["ㄱㅏ", "b", "ㄴㅏ"])
        // 5. 숫자 포함
        XCTAssertEqual(HangeulSearch.getJamoList("하3루"), ["ㅎㅏ", "3", "ㄹㅜ"])
    }
}
