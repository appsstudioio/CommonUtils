//
//  UIControl+Combine.swift
//  CombineCocoa
//
//  Created by Wes Wickwire on 9/23/20.
//  Copyright © 2020 Combine Community. All rights reserved.
//

#if !(os(iOS) && (arch(i386) || arch(arm)))
import Combine
import UIKit

@available(iOS 13.0, *)
public extension UIControl {
    /// A publisher emitting events from this control.
    func controlEventPublisher(for events: UIControl.Event) -> AnyPublisher<Void, Never> {
        Publishers.ControlEvent(control: self, events: events)
                  .eraseToAnyPublisher()
    }

    // 입력 제한 1초에 한번만.. (화면 이동이나 네트웍 요청할때는 해당 기능을 쓰는게 좋을듯)
    func throttleControlPublisher(for event: UIControl.Event) -> Publishers.Throttle<UIControl.EventPublisher, RunLoop> {
        return UIControl.EventPublisher(control: self, event: event).throttle(for: .seconds(1), scheduler: RunLoop.main, latest: false)
    }

    // Publisher
    struct EventPublisher: Publisher {
        public typealias Output = UIControl
        public typealias Failure = Never

        let control: UIControl
        let event: UIControl.Event

        public func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, UIControl == S.Input {
            let subscription = EventSubscription(control: control, subscrier: subscriber, event: event)
            subscriber.receive(subscription: subscription)
        }
    }

    // Subscription
    fileprivate class EventSubscription<EventSubscriber: Subscriber>: Subscription where EventSubscriber.Input == UIControl, EventSubscriber.Failure == Never {

        let control: UIControl
        let event: UIControl.Event
        var subscriber: EventSubscriber?

        init(control: UIControl, subscrier: EventSubscriber, event: UIControl.Event) {
            self.control = control
            self.subscriber = subscrier
            self.event = event

            control.addTarget(self, action: #selector(eventDidOccur), for: event)
        }

        func request(_ demand: Subscribers.Demand) {}

        func cancel() {
            subscriber = nil
            control.removeTarget(self, action: #selector(eventDidOccur), for: event)
        }

        @objc func eventDidOccur() {
            _ = subscriber?.receive(control)
        }
    }
}
#endif
