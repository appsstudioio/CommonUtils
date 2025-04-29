//
// MoyaProviderTests.swift
// CommonUtils
//
// Created by Dongju Lim on 4/29/25
//

import XCTest
import Moya
import Combine
import UIKit
@testable import CommonUtils

final class MoyaCombineTests: XCTestCase {

    private var cancellables: Set<AnyCancellable>!
    private var provider: MoyaProvider<MockService>!

    override func setUp() {
        super.setUp()
        cancellables = []
        provider = MoyaProvider<MockService>(stubClosure: MoyaProvider.immediatelyStub)
    }

    override func tearDown() {
        cancellables = nil
        provider = nil
        super.tearDown()
    }

    // MARK: - requestPublisher Tests

    func test_requestPublisher_successfulResponse_returnsResponse() throws {
        let expectation = self.expectation(description: "response received")

        provider.requestPublisher(.success)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Expected success, but got failure")
                }
            }, receiveValue: { response in
                XCTAssertEqual(response.statusCode, 200)
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)
    }

    func test_requestPublisher_errorStatusCode_returnsFailure() throws {
        let expectation = self.expectation(description: "error received")

        provider = MoyaProvider<MockService>(endpointClosure: { target in
            return Endpoint(url: URL(target: target).absoluteString,
                            sampleResponseClosure: { .networkResponse(404, Data()) },
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        }, stubClosure: MoyaProvider.immediatelyStub)

        provider.requestPublisher(.error)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    XCTAssertEqual(error, NetworkException.errorStatusCode(404))
                    expectation.fulfill()
                }
            }, receiveValue: { _ in
                XCTFail("Expected failure, got value")
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)
    }

    // MARK: - filterSuccessfulStatusCodes

    func test_filterSuccessfulStatusCodes_passesValidResponse() throws {
        let expectation = self.expectation(description: "valid response passed")

        provider.requestPublisher(.success)
            .filterSuccessfulStatusCodes()
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Expected success, got failure")
                }
            }, receiveValue: { response in
                XCTAssertEqual(response.statusCode, 200)
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)
    }

    func test_filterSuccessfulStatusCodes_failsOnInvalidResponse() throws {
        let expectation = self.expectation(description: "failure on invalid status")

        provider = MoyaProvider<MockService>(endpointClosure: { target in
            return Endpoint(url: URL(target: target).absoluteString,
                            sampleResponseClosure: { .networkResponse(500, Data()) },
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        }, stubClosure: MoyaProvider.immediatelyStub)

        provider.requestPublisher(.error)
            .filterSuccessfulStatusCodes()
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    expectation.fulfill()
                }
            }, receiveValue: { _ in
                XCTFail("Expected failure")
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)
    }

    // MARK: - map

    func test_mapJSON_decodesValidJSON() throws {
        let expectation = self.expectation(description: "decoded JSON")

        provider = MoyaProvider<MockService>(endpointClosure: { target in
            let jsonData = try! JSONSerialization.data(withJSONObject: ["message": "hello"], options: [])
            return Endpoint(url: URL(target: target).absoluteString,
                            sampleResponseClosure: { .networkResponse(200, jsonData) },
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        }, stubClosure: MoyaProvider.immediatelyStub)

        provider.requestPublisher(.json)
            .mapJSON()
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Expected JSON success")
                }
            }, receiveValue: { json in
                if let dict = json as? [String: String] {
                    XCTAssertEqual(dict["message"], "hello")
                    expectation.fulfill()
                } else {
                    XCTFail("Invalid type")
                }
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)
    }

    // MARK: - 서버로부터 텍스트 데이터 수신 및 매핑 성공

    func test_mapString_decodesValidString() throws {
        let expectation = self.expectation(description: "decoded String")

        provider = MoyaProvider<MockService>(endpointClosure: { target in
            return Endpoint(url: URL(target: target).absoluteString,
                            sampleResponseClosure: { .networkResponse(200, "hello world".data(using: .utf8)!) },
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        }, stubClosure: MoyaProvider.immediatelyStub)

        provider.requestPublisher(.success)
            .mapString()
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Expected String success")
                }
            }, receiveValue: { string in
                XCTAssertEqual(string, "hello world")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)
    }

    func test_mapImage_decodesValidImage() throws {
#if canImport(UIKit)
        let expectation = self.expectation(description: "decoded Image")

        provider = MoyaProvider<MockService>(endpointClosure: { target in
            let image = UIImage(systemName: "house") ?? UIImage()
            let imageData = image.pngData() ?? Data()
            return Endpoint(url: URL(target: target).absoluteString,
                            sampleResponseClosure: { .networkResponse(200, imageData) },
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        }, stubClosure: MoyaProvider.immediatelyStub)

        provider.requestPublisher(.success)
            .mapImage()
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Expected Image success")
                }
            }, receiveValue: { image in
                XCTAssertNotNil(image)
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)
#endif
    }

    func test_requestPublisher_serverFailure_returnsServerError() throws {
        let expectation = self.expectation(description: "server error received")

        let customError = NSError(domain: "test", code: 1234, userInfo: nil)
        provider = MoyaProvider<MockService>(endpointClosure: { target in
            return Endpoint(url: URL(target: target).absoluteString,
                            sampleResponseClosure: { .networkError(customError) },
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        }, stubClosure: MoyaProvider.immediatelyStub)

        provider.requestPublisher(.error)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    if case let .serverError(innerError) = error,
                       case let moyaError as MoyaError = innerError,
                       case let .underlying(underlyingError, _) = moyaError {
                        XCTAssertEqual((underlyingError as NSError).code, 1234)
                        expectation.fulfill()
                    } else {
                        XCTFail("Expected serverError")
                    }
                }
            }, receiveValue: { _ in
                XCTFail("Expected failure")
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)
    }
}

// MARK: - Mock Service

enum MockService: TargetType {
    case success
    case error
    case json

    var baseURL: URL { return URL(string: "https://example.com")! }

    var path: String {
        switch self {
        case .success: return "/success"
        case .error: return "/error"
        case .json: return "/json"
        }
    }

    var method: Moya.Method { return .get }

    var sampleData: Data {
        switch self {
        case .success:
            return Data()
        case .error:
            return Data()
        case .json:
            return """
            { "message": "hello" }
            """.data(using: .utf8)!
        }
    }

    var task: Task { return .requestPlain }

    var headers: [String: String]? { return ["Content-Type": "application/json"] }
}
