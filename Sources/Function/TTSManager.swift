//
//  TTSManager.swift
//
//
// Created by Dongju Lim on 2023/08/07.
//

import Foundation
import AVFoundation

// AVSpeechSynthesizer의 동작을 정의하는 프로토콜
protocol SpeechSynthesizing {
    var delegate: AVSpeechSynthesizerDelegate? { get set }
    func speak(_ utterance: AVSpeechUtterance)
    func stopSpeaking(at boundary: AVSpeechBoundary) -> Bool
}

// AVAudioSession의 동작을 정의하는 프로토콜
protocol AudioSessioning {
    // 실제 AVAudioSession의 sharedInstance()를 모방하거나 인스턴스를 주입받도록 설계
    func setCategory(_ category: AVAudioSession.Category, mode: AVAudioSession.Mode, options: AVAudioSession.CategoryOptions) throws
    func setActive(_ active: Bool) throws
}

// 기존 AVSpeechSynthesizer가 프로토콜을 준수하도록 확장
extension AVSpeechSynthesizer: SpeechSynthesizing {}

// AVAudioSession을 직접 프로토콜로 만들기 어려우므로, 래퍼(Wrapper) 클래스나 Mock을 사용합니다.
// 실제 앱에서는 AVAudioSession.sharedInstance()를 사용하는 래퍼를 만들어 주입할 수 있습니다.
class DefaultAudioSession: AudioSessioning {
    private let session = AVAudioSession.sharedInstance()

    func setCategory(_ category: AVAudioSession.Category, mode: AVAudioSession.Mode, options: AVAudioSession.CategoryOptions) throws {
        try session.setCategory(category, mode: mode, options: options)
    }

    func setActive(_ active: Bool) throws {
        try session.setActive(active)
    }
}

public class TTSManager: NSObject, AVSpeechSynthesizerDelegate {

    public static let shared = TTSManager() // 기존 싱글톤 유지

    // 프로토콜 타입으로 의존성 선언
    private var synthesizer: SpeechSynthesizing
    private var audioSession: AudioSessioning

    // @MainActor 어노테이션 유지
    @MainActor private var internalSynthesizer: AVSpeechSynthesizer? {
        synthesizer as? AVSpeechSynthesizer
    }

    // 기본 생성자 (실제 앱에서 사용)
    // synthesizer 생성 및 delegate 할당은 @MainActor 컨텍스트 내에서 수행되어야 할 수 있습니다.
    convenience override init() {
        let synth = AVSpeechSynthesizer()
        self.init(synthesizer: synth, audioSession: DefaultAudioSession())
        // 비동기적으로 delegate 할당 (MainActor 보장)
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            // 생성 시점에 delegate 설정
            self.synthesizer.delegate = self
        }
    }

    // 테스트용 생성자 (의존성 주입)
    init(synthesizer: SpeechSynthesizing, audioSession: AudioSessioning) {
        self.synthesizer = synthesizer
        self.audioSession = audioSession
        super.init()
        // 테스트 시에는 초기화 직후 delegate 설정 가능
        self.synthesizer.delegate = self
    }

    public func play(_ string: String, locale: Locale? = .current) {
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: locale?.collatorIdentifier ?? "ko-KR")
        utterance.rate = 0.4
        utterance.volume = 1.0

        // @MainActor 또는 DispatchQueue.main.async 사용 일관성 유지
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            do {
                // 주입된 audioSession 사용
                try self.audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers, .duckOthers])
                // 주입된 synthesizer 사용
                _ = self.synthesizer.stopSpeaking(at: .immediate)
                // delegate는 생성 시점에 설정되었으므로 여기서 재설정할 필요 없음
                self.synthesizer.speak(utterance)
            } catch {
                print(" 오디오 세션 카테고리 설정 오류: \(error)")
                // 실제 앱에서는 오류 처리를 더 견고하게 해야 합니다.
            }
        }
    }

    public func stop() {
        Task { @MainActor [weak self] in
            self?.synthesizer.stopSpeaking(at: .immediate)
        }
    }

    // MARK: - AVSpeechSynthesizerDelegate

    // delegate 메소드는 실제 AVSpeechSynthesizer 인스턴스를 받지만,
    // 내부 로직은 주입된 audioSession 프로토콜을 사용합니다.
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        Task { @MainActor [weak self] in
            do {
                try self?.audioSession.setActive(true)
            } catch {
                print(" 오디오 세션 활성화 오류: \(error)")
            }
        }
    }

    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor [weak self] in
            do {
                try self?.audioSession.setActive(false)
            } catch {
                print(" 오디오 세션 비활성화 오류: \(error)")
            }
        }
    }
}

/*
// https://eeyatho.tistory.com/173
public class TTSManager: NSObject, AVSpeechSynthesizerDelegate {

    public static let shared = TTSManager()

    @MainActor private var synthesizer = AVSpeechSynthesizer()

    public func play(_ string: String, locale: Locale? = .current) {
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: locale?.collatorIdentifier ?? "ko-KR")
        utterance.rate = 0.4
        utterance.volume = 1.0

        DispatchQueue.main.async { [weak self] in
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .duckOthers])
            self?.synthesizer.stopSpeaking(at: .immediate)
            self?.synthesizer.delegate = self
            self?.synthesizer.speak(utterance)
        }

    }

    public func stop() {
        DispatchQueue.main.async { [weak self] in
            self?.synthesizer.stopSpeaking(at: .immediate)
        }
    }

    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}
*/
