//
//  UITextField+Combine.swift
//  CombineCocoa
//
//  Created by Shai Mishali on 02/08/2019.
//  Copyright © 2020 Combine Community. All rights reserved.
//

#if !(os(iOS) && (arch(i386) || arch(arm)))
import Combine
import UIKit

@available(iOS 13.0, *)
public extension UITextField {
    /// A publisher emitting any text changes to a this text field.
    var textPublisher: AnyPublisher<String?, Never> {
        Publishers.ControlProperty(control: self, events: .defaultValueEvents, keyPath: \.text)
                  .eraseToAnyPublisher()
    }

    /// A publisher emitting any attributed text changes to this text field.
    var attributedTextPublisher: AnyPublisher<NSAttributedString?, Never> {
        Publishers.ControlProperty(control: self, events: .defaultValueEvents, keyPath: \.attributedText)
                  .eraseToAnyPublisher()
    }

    /// A publisher that emits whenever the user taps the return button and ends the editing on the text field.
    var returnPublisher: AnyPublisher<Void, Never> {
        controlEventPublisher(for: .editingDidEndOnExit)
    }

    /// A publisher that emits whenever the user taps the text fields and begin the editing.
    var didBeginEditingPublisher: AnyPublisher<Void, Never> {
        controlEventPublisher(for: .editingDidBegin)
    }
}

@available(iOS 13.0, *)
public extension UITextView {
    /// A Combine publisher that emits whenever the text of this UITextView changes.
    var textPublisher: AnyPublisher<String?, Never> {
        // Create a subject to relay text changes
        let subject = PassthroughSubject<String?, Never>()

        // Delegate 객체를 이용해 텍스트 변경 이벤트 감지
        let delegate = CombineTextViewDelegate(textSubject: subject)

        // delegate 속성 설정
        self.delegate = delegate

        // UITextView가 할당 해제될 때 delegate와 subject의 순환 참조 방지를 위해 메모리 관리 처리
        objc_setAssociatedObject(self, &AssociatedKeys.delegateKey, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        // subject를 publisher로 변환하여 반환
        return subject
            .receive(on: RunLoop.main) // 메인 쓰레드에서 처리
            .eraseToAnyPublisher()
    }
}

// Associated Keys 구조체 정의
private struct AssociatedKeys {
    static var delegateKey: UInt8 = 0  // String 대신 UInt8 같은 기본 타입 사용
}

// UITextViewDelegate를 이용해 텍스트 변경을 감지하는 클래스
private class CombineTextViewDelegate: NSObject, UITextViewDelegate {

    // 텍스트 변경 내용을 전달할 subject
    private let textSubject: PassthroughSubject<String?, Never>

    init(textSubject: PassthroughSubject<String?, Never>) {
        self.textSubject = textSubject
    }

    func textViewDidChange(_ textView: UITextView) {
        // 텍스트 변경 시 subject에 새로운 값을 전달
        textSubject.send(textView.text)
    }
}

#endif
