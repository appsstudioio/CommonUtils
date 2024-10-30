//
//  BaseNetworkProvider.swift
//
//
//  Created by 10-N3344 on 8/28/24.
//

import Foundation
import Combine
#if canImport(Moya)
import Moya
#endif

public enum NetworkException: Error {
    case errorStatusCode(Int)
    case serverError(Error)
}

#if canImport(Moya)
public extension MoyaProvider {
    func requestPublisher(_ target: Target, progress: ProgressBlock? = nil, callbackQueue: DispatchQueue? = nil) -> AnyPublisher<Response, NetworkException> {
        return MoyaPublisher { [weak self] subscriber in
            return self?.request(target, callbackQueue: callbackQueue, progress: progress) { result in
                switch result {
                case let .success(response):
                    switch response.statusCode {
                    case 200...299:
                        _ = subscriber.receive(response) // 요청한 쪽에 response 전달하기 때문에 이전에 문제가 있으면 사전에 차단
                    default:
                        subscriber.receive(completion: .failure(.errorStatusCode(response.statusCode)))
                    }
                case let .failure(error):
                    subscriber.receive(completion: .failure(.serverError(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

public extension AnyPublisher where Output == Response, Failure == NetworkException {

    /// Filters out responses that don't fall within the given range, generating errors when others are encountered.
    func filter<R: RangeExpression>(statusCodes: R) -> AnyPublisher<Response, NetworkException> where R.Bound == Int {
        return unwrapThrowable { response in
            try response.filter(statusCodes: statusCodes)
        }
    }

    /// Filters out responses that has the specified `statusCode`.
    func filter(statusCode: Int) -> AnyPublisher<Response, NetworkException> {
        return unwrapThrowable { response in
            try response.filter(statusCode: statusCode)
        }
    }

    /// Filters out responses where `statusCode` falls within the range 200 - 299.
    func filterSuccessfulStatusCodes() -> AnyPublisher<Response, NetworkException> {
        return unwrapThrowable { response in
            try response.filterSuccessfulStatusCodes()
        }
    }

    /// Filters out responses where `statusCode` falls within the range 200 - 399
    func filterSuccessfulStatusAndRedirectCodes() -> AnyPublisher<Response, NetworkException> {
        return unwrapThrowable { response in
            try response.filterSuccessfulStatusAndRedirectCodes()
        }
    }

    /// Maps data received from the signal into an Image. If the conversion fails, the signal errors.
    func mapImage() -> AnyPublisher<Image, NetworkException> {
        return unwrapThrowable { response in
            try response.mapImage()
        }
    }

    /// Maps data received from the signal into a JSON object. If the conversion fails, the signal errors.
    func mapJSON(failsOnEmptyData: Bool = true) -> AnyPublisher<Any, NetworkException> {
        return unwrapThrowable { response in
            try response.mapJSON(failsOnEmptyData: failsOnEmptyData)
        }
    }

    /// Maps received data at key path into a String. If the conversion fails, the signal errors.
    func mapString(atKeyPath keyPath: String? = nil) -> AnyPublisher<String, NetworkException> {
        return unwrapThrowable { response in
            try response.mapString(atKeyPath: keyPath)
        }
    }

    /// Maps received data at key path into a Decodable object. If the conversion fails, the signal errors.
    func map<D: Decodable>(_ type: D.Type, atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true) -> AnyPublisher<D, NetworkException> {
        return unwrapThrowable { response in
            try response.map(type, atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
        }
    }

}

internal class MoyaPublisher<Output>: Publisher {

    internal typealias Failure = NetworkException

    private class Subscription: Combine.Subscription {
        private let performCall: () -> Moya.Cancellable?
        private var cancellable: Moya.Cancellable?

        init(subscriber: AnySubscriber<Output, NetworkException>, callback: @escaping (AnySubscriber<Output, NetworkException>) -> Moya.Cancellable?) {
            performCall = { callback(subscriber) }
        }

        func request(_ demand: Subscribers.Demand) {
            guard demand > .none else { return }

            cancellable = performCall()
        }

        func cancel() {
            cancellable?.cancel()
        }
    }

    private let callback: (AnySubscriber<Output, NetworkException>) -> Moya.Cancellable?

    init(callback: @escaping (AnySubscriber<Output, NetworkException>) -> Moya.Cancellable?) {
        self.callback = callback
    }

    internal func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = Subscription(subscriber: AnySubscriber(subscriber), callback: callback)
        subscriber.receive(subscription: subscription)
    }
}

public extension AnyPublisher where Failure == NetworkException {

    // Workaround for a lot of things, actually. We don't have Publishers.Once, flatMap
    // that can throw and a lot more. So this monster was created because of that. Sorry.
    private func unwrapThrowable<T>(throwable: @escaping (Output) throws -> T) -> AnyPublisher<T, NetworkException> {
        self.tryMap { element in
            try throwable(element)
        }
        .mapError { error -> NetworkException in
            if let moyaError = error as? NetworkException {
                return moyaError
            }
            return NetworkException.serverError(error)
        }
        .eraseToAnyPublisher()
    }
}
#endif
