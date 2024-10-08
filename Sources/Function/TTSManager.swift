//
//  TTSManager.swift
//
//
//  Created by 10-N3344 on 2023/08/07.
//

import AVFoundation
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
