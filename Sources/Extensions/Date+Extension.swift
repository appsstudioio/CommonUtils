//
//  Date+Extension.swift
//
//
//  Created by 10-N3344 on 8/12/24.
//

import Foundation

public typealias DateWeekType = Date.DateWeekType
public extension DateWeekType {
    var shortName: String {
        switch self {
        case .sunday: return "일"
        case .monday: return "월"
        case .tuesday: return "화"
        case .wednesday: return "수"
        case .thursday: return "목"
        case .friday: return "금"
        case .saturday: return "토"
        }
    }

    var name: String {
        return (self.shortName + "요일")
    }
}

public extension Date {

    enum DateWeekType: Int, CaseIterable {
        case sunday = 1
        case monday = 2
        case tuesday = 3
        case wednesday = 4
        case thursday = 5
        case friday = 6
        case saturday = 7
    }

    // returns an integer from 1 - 7, with 1 being Sunday and 7 being Saturday
    func dayOfWeek(timeZone: TimeZone = TimeZone.autoupdatingCurrent, locale: Locale? = Locale.current) -> DateWeekType? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        calendar.locale = locale
        guard let weekday = calendar.dateComponents([.weekday], from: self).weekday else { return nil }

        return (DateWeekType(rawValue: weekday) ?? nil)
    }

    func toString(format: String, timeZone: TimeZone = .current, locale: Locale = Locale.current) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.setKSTFormatter(format: format)
        return dateFormatter.string(from: self)
    }

    // D-Day
    func betweenDates(toDate: Date, component: [Calendar.Component]) -> DateComponents? {
        let calendar = Calendar(identifier: .gregorian)
    //    calendar.locale = Locale(identifier: "ko_KR")
        let unitFlags = Set<Calendar.Component>(component)
        let components = calendar.dateComponents(unitFlags, from: self, to: toDate)
        return components
    }

    func getComponetValue(components: Set<Calendar.Component>, timeZone: TimeZone = TimeZone.autoupdatingCurrent, locale: Locale? = Locale.current) -> DateComponents? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        calendar.locale = locale
        return calendar.dateComponents(components, from: self)
    }

    func toYearDate(_ year: Int) -> Date? {
        let yearOffset = DateComponents(year: year)
        let calendar = Calendar(identifier: .gregorian)
        if let afterYear = calendar.date(byAdding: yearOffset, to: self) {
            return afterYear
        }
        return nil
    }

    func toMonthDate(_ month: Int) -> Date? {
        let monthOffset = DateComponents(month: month)
        let calendar = Calendar(identifier: .gregorian)
        if let afterMonth = calendar.date(byAdding: monthOffset, to: self) {
            return afterMonth
        }
        return nil
    }

    func toHourhDate(_ hour: Int) -> Date? {
        let hourOffset = DateComponents(hour: hour)
        let calendar = Calendar(identifier: .gregorian)
        if let afterHour = calendar.date(byAdding: hourOffset, to: self) {
            return afterHour
        }
        return nil
    }

    func toMinuteDate(_ minute: Int) -> Date? {
        let minuteOffset = DateComponents(minute: minute)
        let calendar = Calendar(identifier: .gregorian)
        if let afterminute = calendar.date(byAdding: minuteOffset, to: self) {
            return afterminute
        }
        return nil
    }

    func toDayDate(_ day: Int) -> Date? {
        let dayOffset = DateComponents(day: day)
        let calendar = Calendar(identifier: .gregorian)
        if let afterDay = calendar.date(byAdding: dayOffset, to: self) {
            return afterDay
        }
        return nil
    }

    var dateKST: Date? {
        return datetime_KST()
    }

    func datetime_KST() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.setKSTFormatter(format: "yyyy-MM-dd HH:mm:ss")
        let dateStr = dateFormatter.string(from: self)
        return dateFormatter.date(from: dateStr)!
    }

    var toUnixTimeStamp: Int {
        return Int(self.timeIntervalSince1970 * 1000)
    }

    var toFirstDay: Date {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ko_kr")

        // 여기에 기입하지 않은 날짜는 1로 초기화가 된다
        let year = self.getComponetValue(components: [.year])?.year
        let month = self.getComponetValue(components: [.month])?.month
        let myDateComponents = DateComponents(year: year, month: month)

        // day를 기입하지 않아서 현재 달의 첫번쨰 날짜가 나오게 된다
        return calendar.date(from: myDateComponents)!
    }

    var toLastDay: Date {
        let nextMonth = self.toFirstDay.toMonthDate(1)!
        return nextMonth.toDayDate(-1)!
    }
}

// MARK: - DateFormatter
public extension DateFormatter {
    func setFormatter(format: String = "yyyy-MM-dd HH:mm:ss",
                      timeZone: TimeZone? = TimeZone.current,
                      locale: Locale? = Locale.current) {
        self.dateFormat = format
        self.calendar   = Calendar(identifier: .gregorian)
        if let setTimeZone = timeZone {
            self.timeZone = setTimeZone
        }
        if locale != nil {
            self.locale = locale
        }
    }

    func setKSTFormatter(format: String = "yyyy-MM-dd HH:mm:ss") {
        self.setFormatter(format: format,
                          timeZone: TimeZone(abbreviation: "KST"),
                          locale: Locale(identifier: "ko_kr"))
    }
}
