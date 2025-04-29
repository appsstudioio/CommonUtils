//
//  NetworkConnectivityManager.swift
//
//
// Created by Dongju Lim on 10/11/24.
//
import Foundation
import Alamofire
import Combine
import UIKit

public typealias NetworkStatusCode = NetworkReachabilityManager.NetworkReachabilityStatus
public protocol NetworkReachabilityManagerProtocol: AnyObject {
    func startReachabilityListening(onQueue queue: DispatchQueue, onUpdatePerforming listener: @escaping (NetworkStatusCode) -> Void)
    func stopListening()
}

extension NetworkReachabilityManager: NetworkReachabilityManagerProtocol {
    public func startReachabilityListening(onQueue queue: DispatchQueue, onUpdatePerforming listener: @escaping (NetworkStatusCode) -> Void) {
        _ = self.startListening(onQueue: queue, onUpdatePerforming: listener)
    }
}

public final class NetworkConnectivityManager {
    private var cancellables = Set<AnyCancellable>()
    private let networkReachabilityManager: NetworkReachabilityManagerProtocol?
    private let networkStatusSubject = PassthroughSubject<NetworkStatusCode, Never>()

    public var networkStatusPublisher: AnyPublisher<NetworkStatusCode, Never> {
        return networkStatusSubject.eraseToAnyPublisher()
    }

    public var isOnline: Bool = true

    public init(networkReachabilityManager: NetworkReachabilityManagerProtocol? = NetworkReachabilityManager.default) {
        self.networkReachabilityManager = networkReachabilityManager

        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.startMonitoring()
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in
                self?.stopMonitoring()
            }
            .store(in: &cancellables)

        startMonitoring()
    }

    public func startMonitoring() {
        networkReachabilityManager?.startReachabilityListening(onQueue: .main) { [weak self] status in
            guard let self else { return }

            switch status {
            case .notReachable:
                DebugLog("### >>> The network is not reachable")
                self.isOnline = false
            case .reachable(.ethernetOrWiFi), .reachable(.cellular):
                DebugLog("### >>> The network is reachable :: \(status)")
                self.isOnline = true
            case .unknown:
                DebugLog("### >>> The network status is unknown")
                self.isOnline = false
            }
            self.networkStatusSubject.send(status)
        }
    }

    public func stopMonitoring() {
        networkReachabilityManager?.stopListening()
    }
}
