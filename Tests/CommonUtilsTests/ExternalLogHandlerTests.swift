import XCTest
@testable import CommonUtils

final class ExternalLogHandlerTests: XCTestCase {
    private var originalHandler: DebugLoggerManager.ExternalLogHandler?

    override func setUp() {
        super.setUp()
        originalHandler = DebugLoggerManager.externalLogHandler
    }

    override func tearDown() {
        DebugLoggerManager.externalLogHandler = originalHandler
        super.tearDown()
    }

    func testExplicitEventForwardsDetailsAndCallSiteWithFileLoggingDisabled() {
        var called = false
        DebugLoggerManager.externalLogHandler = { event, message, level, details, file, function, line in
            called = true
            XCTAssertEqual(event, "sample_diagnostic")
            XCTAssertEqual(message, "진단 정보")
            XCTAssertEqual(level, .warning)
            XCTAssertEqual(details["attempt"] as? Int, 3)
            XCTAssertEqual(file, "Feature.swift")
            XCTAssertEqual(function, "retry()")
            XCTAssertEqual(line, 42)
        }
        DebugLog("진단 정보", level: .warning, file: "Feature.swift", funcName: "retry()", line: 42,
                 param: ["attempt": 3], isFileLog: false, externalEventName: "sample_diagnostic")
        XCTAssertTrue(called)
    }

    func testExistingLogsAreNotForwardedWithoutExplicitEvent() {
        var calls = 0
        DebugLoggerManager.externalLogHandler = { _, _, _, _, _, _, _ in calls += 1 }
        DebugLog("기존 일반 로그", level: .error, isFileLog: false)
        XCTAssertEqual(calls, 0)
    }

    func testHandlerCanReuseExistingLogWithoutRecursiveForwarding() {
        var calls = 0
        DebugLoggerManager.externalLogHandler = { _, message, level, _, _, _, _ in
            calls += 1
            DebugLog(message, level: level, isFileLog: false)
        }
        DebugLog("외부 이벤트", isFileLog: false, externalEventName: "sample_diagnostic")
        XCTAssertEqual(calls, 1)
    }

    func testExplicitEventWithoutHandlerDoesNotInterruptCaller() {
        DebugLoggerManager.externalLogHandler = nil
        DebugLog("외부 이벤트", isFileLog: false, externalEventName: "sample_diagnostic")
    }
}
