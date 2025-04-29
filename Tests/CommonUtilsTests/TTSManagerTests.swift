//
// TTSManagerTests.swift
// CommonUtils
//
// Created by Dongju Lim on 4/28/25
//
import Foundation
import AVFoundation
import XCTest // 목 객체 내에서 Expectation을 사용할 수 있도록 import
@testable import CommonUtils

// SpeechSynthesizing 프로토콜을 따르는 목 객체
class MockSpeechSynthesizer: SpeechSynthesizing {
    var delegate: AVSpeechSynthesizerDelegate?

    // 호출 여부 및 파라미터 저장을 위한 변수
    var didCallSpeak = false
    var didCallStopSpeaking = false
    var lastUtterance: AVSpeechUtterance?
    var stopBoundary: AVSpeechBoundary?

    // 비동기 테스트를 위한 Expectation
    var speakExpectation: XCTestExpectation?
    var stopExpectation: XCTestExpectation?
    // 반환할 값 설정 (테스트 시나리오에 따라 변경 가능)
    var stopSpeakingReturnValue: Bool = true

    func speak(_ utterance: AVSpeechUtterance) {
        didCallSpeak = true
        lastUtterance = utterance
        print("Mock: speak 호출됨 - \(utterance.speechString)")
        speakExpectation?.fulfill() // speak 호출 시 expectation 충족
    }

    func stopSpeaking(at boundary: AVSpeechBoundary) -> Bool {
        didCallStopSpeaking = true
        stopBoundary = boundary
        print("Mock: stopSpeaking 호출됨 - \(boundary)")
        stopExpectation?.fulfill()
        return stopSpeakingReturnValue // 설정된 반환 값 사용
    }

    // 테스트에서 delegate 메소드 호출을 시뮬레이션하기 위한 헬퍼 함수
    func simulateDidStart(utterance: AVSpeechUtterance) {
        // delegate 메소드는 실제 AVSpeechSynthesizer 타입을 요구합니다.
        // 더미 인스턴스를 생성하여 전달합니다.
        let dummySynthesizer = AVSpeechSynthesizer()
        delegate?.speechSynthesizer?(dummySynthesizer, didStart: utterance)
    }

    func simulateDidFinish(utterance: AVSpeechUtterance) {
        let dummySynthesizer = AVSpeechSynthesizer()
        delegate?.speechSynthesizer?(dummySynthesizer, didFinish: utterance)
    }
}

// AudioSessioning 프로토콜을 따르는 목 객체
class MockAudioSession: AudioSessioning {
    var category: AVAudioSession.Category?
    var mode: AVAudioSession.Mode?
    var options: AVAudioSession.CategoryOptions?
    var activeState: Bool? // 마지막으로 설정된 활성 상태 저장

    var didCallSetCategory = false
    var didCallSetActive = false

    // 비동기 테스트를 위한 Expectation
    var setCategoryExpectation: XCTestExpectation?
    var setActiveExpectation: XCTestExpectation?

    func setCategory(_ category: AVAudioSession.Category, mode: AVAudioSession.Mode, options: AVAudioSession.CategoryOptions) throws {
        print("Mock: setCategory 호출됨 - \(category), \(mode), \(options)")
        self.category = category
        self.mode = mode
        self.options = options
        didCallSetCategory = true
        setCategoryExpectation?.fulfill()
    }

    func setActive(_ active: Bool) throws {
        print("Mock: setActive 호출됨 - \(active)")
        self.activeState = active
        didCallSetActive = true
        setActiveExpectation?.fulfill()
    }
}

class TTSManagerTests: XCTestCase {

    var mockSynthesizer: MockSpeechSynthesizer!
    var mockAudioSession: MockAudioSession!
    var sut: TTSManager! // System Under Test (테스트 대상 시스템)

    // 각 테스트 케이스 실행 전에 호출됩니다.
    override func setUpWithError() throws {
        try super.setUpWithError()
        // 새로운 목 객체 생성
        mockSynthesizer = MockSpeechSynthesizer()
        mockAudioSession = MockAudioSession()
        // 목 객체를 주입하여 SUT 인스턴스 생성
        sut = TTSManager(synthesizer: mockSynthesizer, audioSession: mockAudioSession)
    }

    // 각 테스트 케이스 실행 후에 호출됩니다.
    override func tearDownWithError() throws {
        sut = nil
        mockSynthesizer = nil
        mockAudioSession = nil
        try super.tearDownWithError()
    }

    // MARK: - 테스트 케이스

    // play 함수 테스트: 오디오 세션 설정 및 speak 호출 확인
    func testPlay_ShouldConfigureAudioSessionAndSpeak() {
        let testString = "테스트 문장입니다."
        let testLocale = Locale(identifier: "ko-KR")

        // 비동기 작업 완료를 기다리기 위한 Expectation 설정
        let categoryExpectation = expectation(description: "오디오 세션 카테고리 설정 대기")
        let speakExpectation = expectation(description: "Synthesizer speak 호출 대기")

        // 목 객체에 Expectation 연결
        mockAudioSession.setCategoryExpectation = categoryExpectation
        mockSynthesizer.speakExpectation = speakExpectation

        // --- When ---
        sut.play(testString, locale: testLocale)

        // --- Then ---
        // 지정된 타임아웃 동안 Expectation이 충족되기를 기다림
        wait(for: [categoryExpectation, speakExpectation], timeout: 2.0) // 타임아웃 시간은 환경에 맞게 조절

        // 오디오 세션 설정 검증
        XCTAssertTrue(mockAudioSession.didCallSetCategory, "setCategory가 호출되어야 합니다.")
        XCTAssertEqual(mockAudioSession.category, .playback)
        XCTAssertEqual(mockAudioSession.mode, .default)
        XCTAssertEqual(mockAudioSession.options, [.mixWithOthers, .duckOthers])

        // Synthesizer 상호작용 검증
        XCTAssertTrue(mockSynthesizer.didCallStopSpeaking, "speak 전에 stopSpeaking이 호출되어야 합니다.")
        XCTAssertEqual(mockSynthesizer.stopBoundary, .immediate)

        XCTAssertTrue(mockSynthesizer.didCallSpeak, "speak가 호출되어야 합니다.")
        XCTAssertNotNil(mockSynthesizer.lastUtterance, "Utterance 객체가 생성되어야 합니다.")
        XCTAssertEqual(mockSynthesizer.lastUtterance?.speechString, testString)
        XCTAssertEqual(mockSynthesizer.lastUtterance?.voice?.language, "ko-KR")
        XCTAssertEqual(mockSynthesizer.lastUtterance?.rate, 0.4)
        XCTAssertEqual(mockSynthesizer.lastUtterance?.volume, 1.0)

        // Delegate가 올바르게 설정되었는지 확인 (생성자에서 설정됨)
        XCTAssertTrue(mockSynthesizer.delegate === sut, "TTSManager 인스턴스가 delegate여야 합니다.")
    }

    // play 함수 테스트: 기본 로케일 사용 확인
    func testPlay_WhenLocaleIsNil_ShouldUseDefaultLocale() {
        let testString = "Hello"
        let speakExpectation = expectation(description: "Speak 호출 대기 (기본 로케일)")
        mockSynthesizer.speakExpectation = speakExpectation

        // --- When ---
        sut.play(testString, locale: nil) // locale을 nil로 전달

        // --- Then ---
        wait(for: [speakExpectation], timeout: 1.0)

        XCTAssertTrue(mockSynthesizer.didCallSpeak)
        XCTAssertNotNil(mockSynthesizer.lastUtterance)
        // 기본 로케일 또는 코드상의 fallback("ko-KR") 언어 코드가 사용되었는지 확인
        let expectedFallbackLanguage = "ko-KR"
        XCTAssertEqual(mockSynthesizer.lastUtterance?.voice?.language, expectedFallbackLanguage, "Locale이 nil일 때 지정된 fallback 언어 코드('ko-KR')가 사용되어야 합니다.")
    }

    // stop 함수 테스트: stopSpeaking 호출 확인
    func testStop_ShouldCallStopSpeaking() {
        let stopExpectation = expectation(description: "Synthesizer stopSpeaking 호출 대기")
        mockSynthesizer.stopExpectation = stopExpectation

        // --- When ---
        sut.stop()

        // --- Then ---
        wait(for: [stopExpectation], timeout: 1.0)
        XCTAssertTrue(mockSynthesizer.didCallStopSpeaking, "stopSpeaking이 호출되어야 합니다.")
        XCTAssertEqual(mockSynthesizer.stopBoundary, .immediate)
    }

    // Delegate 메소드 테스트: didStart 시 오디오 세션 활성화 확인
    func testDelegate_WhenDidStart_ShouldActivateAudioSession() {
        let setActiveExpectation = expectation(description: "Audio session setActive(true) 호출 대기")
        mockAudioSession.setActiveExpectation = setActiveExpectation

        // --- Given ---
        // delegate 메소드를 직접 호출하기 위한 더미 객체
        let dummyUtterance = AVSpeechUtterance(string: "시작")
        let dummySynthesizer = AVSpeechSynthesizer() // delegate 메소드 시그니처 충족용

        // --- When ---
        // SUT의 delegate 메소드를 직접 호출 (원래는 Synthesizer가 호출)
        sut.speechSynthesizer(dummySynthesizer, didStart: dummyUtterance)

        // --- Then ---
        wait(for: [setActiveExpectation], timeout: 1.0)
        XCTAssertTrue(mockAudioSession.didCallSetActive, "setActive가 호출되어야 합니다.")
        XCTAssertEqual(mockAudioSession.activeState, true, "오디오 세션이 활성화(true)되어야 합니다.")
    }

    // Delegate 메소드 테스트: didFinish 시 오디오 세션 비활성화 확인
    func testDelegate_WhenDidFinish_ShouldDeactivateAudioSession() {
        let setActiveExpectation = expectation(description: "Audio session setActive(false) 호출 대기")
        mockAudioSession.setActiveExpectation = setActiveExpectation

        // --- Given ---
        let dummyUtterance = AVSpeechUtterance(string: "종료")
        let dummySynthesizer = AVSpeechSynthesizer()

        // --- When ---
        sut.speechSynthesizer(dummySynthesizer, didFinish: dummyUtterance)

        // --- Then ---
        wait(for: [setActiveExpectation], timeout: 1.0)
        XCTAssertTrue(mockAudioSession.didCallSetActive, "setActive가 호출되어야 합니다.")
        XCTAssertEqual(mockAudioSession.activeState, false, "오디오 세션이 비활성화(false)되어야 합니다.")
    }
}
