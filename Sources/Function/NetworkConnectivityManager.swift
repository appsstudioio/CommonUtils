//
//  NetworkConnectivityManager.swift
//
//
//  Created by 10-N3344 on 10/11/24.
//
import Foundation
import Alamofire
import Combine
import UIKit

public typealias NetworkStatusCode = NetworkReachabilityManager.NetworkReachabilityStatus
public class NetworkConnectivityManager {
    private let reachabilityManager = NetworkReachabilityManager.default
    private var cancellables = Set<AnyCancellable>()

    // 네트워크 상태를 외부로 알리기 위한 Publisher
    private let networkStatusSubject = PassthroughSubject<NetworkStatusCode, Never>()
    public var networkStatusPublisher: AnyPublisher<NetworkStatusCode, Never> {
        return networkStatusSubject.eraseToAnyPublisher()
    }

    // 네트워크 상태 저장
    public var isOnline: Bool = true

    public init() {
        // 앱 상태에 따른 네트워크 모니터링 처리
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.startMonitoring()
            }.store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in
                self?.stopMonitoring()
            }.store(in: &cancellables)

        startMonitoring()
    }

    // 네트워크 모니터링 시작
    public func startMonitoring() {
        reachabilityManager?.startListening { [weak self] status in
            guard let self = self else { return }

            DispatchQueue.main.async {
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
    }

    // 네트워크 모니터링 중단
    public func stopMonitoring() {
        reachabilityManager?.stopListening()
    }
}
