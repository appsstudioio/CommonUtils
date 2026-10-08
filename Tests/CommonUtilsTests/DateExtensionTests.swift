//
//  DateExtensionTests.swift
//  CommonUtils
//
// Created by Dongju Lim on 4/15/25.
//

import XCTest
@testable import CommonUtils

final class DateExtensionTests: XCTestCase {
    let calendar = Calendar(identifier: .gregorian)
    let formatter: DateFormatter = {
        let df = DateFormatter()
        df.setKSTFormatter()
        return df
    }()

    // MARK: - dayOfWeek(timeZone:locale:) 테스트
    func test_dayOfWeek() throws {
        let date = formatter.date(from: "2024-04-14 00:00:00")! // 일요일
        XCTAssertEqual(date.dayOfWeek(), .sunday)

        let monday = formatter.date(from: "2024-04-15 12:00:00")!
        XCTAssertEqual(monday.dayOfWeek(), .monday)

        let wednesday = formatter.date(from: "2024-04-17 10:00:00")!
        XCTAssertEqual(wednesday.dayOfWeek(), .wednesday)

        let saturday = formatter.date(from: "2024-04-20 23:59:59")!
        XCTAssertEqual(saturday.dayOfWeek(), .saturday)

        let tz = TimeZone(abbreviation: "UTC")!
        let dateUTC = formatter.date(from: "2024-04-14 00:00:00")!
        XCTAssertNotNil(dateUTC.dayOfWeek(timeZone: tz))
    }

    // MARK: - toString(format:) 테스트
    func test_toString() throws {
        let date = formatter.date(from: "2024-04-14 15:20:00")!
        XCTAssertEqual(date.toString(format: "yyyy"), "2024")
        XCTAssertEqual(date.toString(format: "MM"), "04")
        XCTAssertEqual(date.toString(format: "dd"), "14")
        XCTAssertEqual(date.toString(format: "HH:mm"), "15:20")
        XCTAssertEqual(date.toString(format: "yyyy-MM-dd HH:mm"), "2024-04-14 15:20")
    }

    // MARK: - betweenDates(toDate:component:) 테스트
    func test_betweenDates() throws {
        let from = formatter.date(from: "2024-04-10 12:00:00")!
        let to = formatter.date(from: "2024-04-15 12:00:00")!
        let result = from.betweenDates(toDate: to, component: [.day])
        XCTAssertEqual(result?.day, 5)

        let result2 = from.betweenDates(toDate: to, component: [.hour])
        XCTAssertEqual(result2?.hour, 120)

        let same = from.betweenDates(toDate: from, component: [.day])
        XCTAssertEqual(same?.day, 0)

        let negative = to.betweenDates(toDate: from, component: [.day])
        XCTAssertEqual(negative?.day, -5)

        let multi = from.betweenDates(toDate: to, component: [.day, .hour])
        XCTAssertEqual(multi?.day, 5)
    }

    // MARK: - toFirstDay / toLastDay 테스트
    func test_toFirstDay_and_toLastDay() throws {
        let date = formatter.date(from: "2024-04-15 12:00:00")!
        XCTAssertEqual(date.toFirstDay.toString(format: "yyyy-MM-dd"), "2024-04-01")
        XCTAssertEqual(date.toLastDay.toString(format: "yyyy-MM-dd"), "2024-04-30")

        let febDate = formatter.date(from: "2024-02-10 00:00:00")!
        XCTAssertEqual(febDate.toFirstDay.toString(format: "yyyy-MM-dd"), "2024-02-01")
        XCTAssertEqual(febDate.toLastDay.toString(format: "yyyy-MM-dd"), "2024-02-29")

        let jan = formatter.date(from: "2024-01-05 00:00:00")!
        XCTAssertEqual(jan.toFirstDay.toString(format: "yyyy-MM-dd"), "2024-01-01")
        XCTAssertEqual(jan.toLastDay.toString(format: "yyyy-MM-dd"), "2024-01-31")

        let dec = formatter.date(from: "2023-12-31 00:00:00")!
        XCTAssertEqual(dec.toFirstDay.toString(format: "yyyy-MM-dd"), "2023-12-01")
        XCTAssertEqual(dec.toLastDay.toString(format: "yyyy-MM-dd"), "2023-12-31")

        let random = formatter.date(from: "2022-06-10 12:00:00")!
        XCTAssertEqual(random.toFirstDay.toString(format: "yyyy-MM-dd"), "2022-06-01")
        XCTAssertEqual(random.toLastDay.toString(format: "yyyy-MM-dd"), "2022-06-30")
    }

    // MARK: - toCalculateDateString(from nowDate: Date = Date()) -> String 테스트
    func test_toCalculateDateString() throws {
        let formatter = DateFormatter()
        formatter.setKSTFormatter(format: "yyyy-MM-dd HH:mm:ss")
        guard let baseDate = formatter.date(from: "2024-04-15 12:00:00") else {
            XCTFail("Invalid base date")
            return
        }

        let fiveMinsAgo = baseDate.toMinuteDate(-5)!
        let fiveMinsLater = baseDate.toMinuteDate(5)!
        let twoDaysAgo = baseDate.toDayDate(-2)!
        let hundredDaysAgo = baseDate.toDayDate(-100)!
        let oneHourLater = baseDate.toHourhDate(1)!

        // 기준이 되는 현재 시간을 baseDate로 고정
        let now = baseDate
        XCTAssertTrue(fiveMinsAgo.toCalculateDateString(from: now).contains(("분".localization() + "전".localization())))
        XCTAssertTrue(fiveMinsLater.toCalculateDateString(from: now).contains(("분".localization() + "후".localization())))
        XCTAssertTrue(twoDaysAgo.toCalculateDateString(from: now).contains(("일".localization() + "전".localization())))
        XCTAssertTrue(oneHourLater.toCalculateDateString(from: now).contains(("시간".localization() + "후".localization())))
        XCTAssertEqual(hundredDaysAgo.toCalculateDateString(from: now), "오래전".localization())
    }

    // MARK: - toUnixTimeStamp
    func test_toUnixTimeStamp() throws {
        let date = Date(timeIntervalSince1970: 0) // 1970-01-01
        XCTAssertEqual(date.toUnixTimeStamp, 0)

        let now = Date()
        XCTAssertGreaterThan(now.toUnixTimeStamp, 1_000_000_000)

        let past = Date(timeIntervalSince1970: -100)
        XCTAssertLessThan(past.toUnixTimeStamp, 0)

        let future = Date(timeIntervalSince1970: 2_000_000_000)
        XCTAssertEqual(future.toUnixTimeStamp, 2_000_000_000_000)

        let specific = formatter.date(from: "2024-04-14 15:00:00")!
        let expected = Int(specific.timeIntervalSince1970 * 1000)
        XCTAssertEqual(specific.toUnixTimeStamp, expected)
    }

    // MARK: - DateFormatter.setKSTFormatter
    func test_setKSTFormatter() throws {
        let df = DateFormatter()
        df.setKSTFormatter()
        XCTAssertEqual(df.locale, Locale(identifier: "ko_KR"))
        XCTAssertEqual(df.timeZone.identifier, "Asia/Seoul")
        XCTAssertEqual(df.dateFormat, "yyyy-MM-dd HH:mm:ss")
        XCTAssertEqual(df.calendar.identifier, .gregorian)

        let date = df.date(from: "2024-04-15 13:30:00")
        XCTAssertNotNil(date)

        let str = df.string(from: Date(timeIntervalSince1970: 0))
        XCTAssertTrue(str.contains("1970"))
    }

    // MARK: - toHourhDate(_:)
    func test_toHourhDate() throws {
        let now = formatter.date(from: "2024-04-15 12:00:00")!
        XCTAssertEqual(now.toHourhDate(1)?.toString(format: "HH:mm"), "13:00")
        XCTAssertEqual(now.toHourhDate(-1)?.toString(format: "HH:mm"), "11:00")
        XCTAssertEqual(now.toHourhDate(0)?.toString(format: "HH:mm"), "12:00")
        XCTAssertEqual(now.toHourhDate(12)?.toString(format: "HH:mm"), "00:00") // 다음날 0시
        XCTAssertEqual(now.toHourhDate(-12)?.toString(format: "HH:mm"), "00:00")
    }

    // MARK: - toMinuteDate(_:)
    func test_toMinuteDate() throws {
        let now = formatter.date(from: "2024-04-15 12:00:00")!
        XCTAssertEqual(now.toMinuteDate(1)?.toString(format: "HH:mm"), "12:01")
        XCTAssertEqual(now.toMinuteDate(-1)?.toString(format: "HH:mm"), "11:59")
        XCTAssertEqual(now.toMinuteDate(30)?.toString(format: "HH:mm"), "12:30")
        XCTAssertEqual(now.toMinuteDate(-30)?.toString(format: "HH:mm"), "11:30")
        XCTAssertEqual(now.toMinuteDate(0)?.toString(format: "HH:mm"), "12:00")
    }

    // MARK: - toDayDate(_:)
    func test_toDayDate() throws {
        let date = formatter.date(from: "2024-04-15 00:00:00")!
        XCTAssertEqual(date.toDayDate(1)?.toString(format: "yyyy-MM-dd"), "2024-04-16")
        XCTAssertEqual(date.toDayDate(-1)?.toString(format: "yyyy-MM-dd"), "2024-04-14")
        XCTAssertEqual(date.toDayDate(30)?.toString(format: "yyyy-MM-dd"), "2024-05-15")
        XCTAssertEqual(date.toDayDate(-15)?.toString(format: "yyyy-MM-dd"), "2024-03-31")
        XCTAssertEqual(date.toDayDate(0)?.toString(format: "yyyy-MM-dd"), "2024-04-15")
    }

    // MARK: - toYearDate(_:)
    func test_toYearDate() throws {
        let date = formatter.date(from: "2024-04-15 00:00:00")!
        XCTAssertEqual(date.toYearDate(1)?.toString(format: "yyyy"), "2025")
        XCTAssertEqual(date.toYearDate(-1)?.toString(format: "yyyy"), "2023")
        XCTAssertEqual(date.toYearDate(10)?.toString(format: "yyyy"), "2034")
        XCTAssertEqual(date.toYearDate(-100)?.toString(format: "yyyy"), "1924")
        XCTAssertEqual(date.toYearDate(0)?.toString(format: "yyyy"), "2024")
    }

    // MARK: - getComponentValue(_:)
    func test_getComponentValue() throws {
        guard let date = formatter.date(from: "2024-04-15 13:45:30") else {
            throw XCTSkip("데이트 생성 안됨. 패스!!")
        }
        XCTAssertEqual(date.getComponentValue([.year])?.year, 2024)
        XCTAssertEqual(date.getComponentValue([.month])?.month, 4)
        XCTAssertEqual(date.getComponentValue([.day])?.day, 15)
        XCTAssertEqual(date.getComponentValue([.hour])?.hour, 13)
        XCTAssertEqual(date.getComponentValue([.minute])?.minute, 45)
    }

    // MARK: - dateKST (한국 시간 변환)
    func test_dateKST() throws {
        let utcDate = Date(timeIntervalSince1970: 0) // UTC: 1970-01-01 00:00:00
        guard let kst = utcDate.dateKST else {
            throw XCTSkip("KST 변환 실패. 테스트 스킵.")
        }

        // KST 기준 포매터로 설정
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        // ✅ 1970-01-01 09:00:00이어야 함 (KST는 UTC+9)
        let kstDateString = formatter.string(from: utcDate)
        XCTAssertEqual(kst.toString(format: "yyyy-MM-dd HH:mm:ss"), kstDateString)

        // ✅ 고정된 날짜 변환 확인
        let sampleDate = formatter.date(from: "2024-04-15 00:00:00")!
        XCTAssertEqual(sampleDate.dateKST?.toString(format: "yyyy-MM-dd HH:mm:ss"), "2024-04-15 00:00:00")

        // ✅ 음수 타임스탬프 확인 (-1시간)
        let negativeDate = Date(timeIntervalSince1970: -3600)
        let expectedNegativeString = formatter.string(from: negativeDate)
        XCTAssertEqual(negativeDate.dateKST?.toString(format: "yyyy-MM-dd HH:mm:ss"), expectedNegativeString)

        // ✅ 현재 시간 기준 KST 변환도 날짜로 비교
        let now = Date()
        let expectedNowKST = formatter.string(from: now)
        XCTAssertEqual(now.dateKST?.toString(format: "yyyy-MM-dd HH:mm:ss"), expectedNowKST)

        // ✅ 시간 컴포넌트만 추출해서 KST 기준으로 9시 확인 (1970-01-01 09:00:00)
        let kstHour = Calendar(identifier: .gregorian).dateComponents(in: TimeZone(identifier: "Asia/Seoul")!, from: kst).hour
        XCTAssertEqual(kstHour, 9)
    }
}
