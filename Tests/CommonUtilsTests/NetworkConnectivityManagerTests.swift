//
// NetworkConnectivityManagerTests.swift
// CommonUtils
//
// Created by Dongju Lim on 4/28/25
//

import XCTest
import Combine
import Alamofire
@testable import CommonUtils

// Mock 클래스 준비
fileprivate final class MockNetworkReachabilityManager: NetworkReachabilityManagerProtocol {
    var onUpdate: ((NetworkStatusCode) -> Void)?

    func startReachabilityListening(onQueue queue: DispatchQueue, onUpdatePerforming listener: @escaping (NetworkStatusCode) -> Void) {
        onUpdate = listener
    }

    func stopListening() {
        // 필요하면 호출 여부 체크 가능
    }

    // 테스트 중에 직접 네트워크 상태를 보낼 때 사용
    func simulateStatusChange(_ status: NetworkStatusCode) {
        onUpdate?(status)
    }
}

final class NetworkConnectivityManagerTests: XCTestCase {

    // MARK: - Properties
    private var manager: NetworkConnectivityManager!
    private var mockNetworkManager: MockNetworkReachabilityManager!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkReachabilityManager()
        manager = NetworkConnectivityManager(networkReachabilityManager: mockNetworkManager)
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        manager = nil
        mockNetworkManager = nil
        super.tearDown()
    }

    // MARK: - Network Status Tests

    func test_whenNetworkIsReachableViaWiFi_shouldSetIsOnlineTrue() throws {
        let expectation = XCTestExpectation(description: "Network reachable via WiFi")

        manager.networkStatusPublisher
            .sink { status in
                XCTAssertEqual(status, .reachable(.ethernetOrWiFi))
                XCTAssertTrue(self.manager.isOnline)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        mockNetworkManager.simulateStatusChange(.reachable(.ethernetOrWiFi))

        wait(for: [expectation], timeout: 1.0)
    }

    func test_whenNetworkIsReachableViaCellular_shouldSetIsOnlineTrue() throws {
        let expectation = XCTestExpectation(description: "Network reachable via Cellular")

        manager.networkStatusPublisher
            .sink { status in
                XCTAssertEqual(status, .reachable(.cellular))
                XCTAssertTrue(self.manager.isOnline)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        mockNetworkManager.simulateStatusChange(.reachable(.cellular))

        wait(for: [expectation], timeout: 1.0)
    }

    func test_whenNetworkIsNotReachable_shouldSetIsOnlineFalse() throws {
        let expectation = XCTestExpectation(description: "Network not reachable")

        manager.networkStatusPublisher
            .sink { status in
                XCTAssertEqual(status, .notReachable)
                XCTAssertFalse(self.manager.isOnline)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        mockNetworkManager.simulateStatusChange(.notReachable)

        wait(for: [expectation], timeout: 1.0)
    }

    func test_whenNetworkStatusIsUnknown_shouldSetIsOnlineFalse() throws {
        let expectation = XCTestExpectation(description: "Network status unknown")

        manager.networkStatusPublisher
            .sink { status in
                XCTAssertEqual(status, .unknown)
                XCTAssertFalse(self.manager.isOnline)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        mockNetworkManager.simulateStatusChange(.unknown)

        wait(for: [expectation], timeout: 1.0)
    }

    func test_stopMonitoring_shouldNotCrash() throws {
        XCTAssertNoThrow(manager.stopMonitoring())
    }

    // MARK: - 복합 케이스 테스트

    func test_multipleNetworkStatusChanges_shouldUpdateIsOnlineAccordingly() throws {
        let expectation = XCTestExpectation(description: "Multiple network status changes")
        expectation.expectedFulfillmentCount = 3

        var results: [Bool] = []

        manager.networkStatusPublisher
            .sink { _ in
                results.append(self.manager.isOnline)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        mockNetworkManager.simulateStatusChange(.reachable(.ethernetOrWiFi))
        mockNetworkManager.simulateStatusChange(.notReachable)
        mockNetworkManager.simulateStatusChange(.reachable(.cellular))

        wait(for: [expectation], timeout: 2.0)

        XCTAssertEqual(results, [true, false, true])
    }
}
