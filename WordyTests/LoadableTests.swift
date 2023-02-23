//
//  LoadableTests.swift
//  WordyTests
//
//  Created by Joey Zhang on 2023/2/23.
//

import XCTest
import Combine
@testable import Wordy

final class LoadableTests: XCTestCase {
    let testError = NSError(domain: "test", code: 0, userInfo: [NSLocalizedDescriptionKey: "Test error"])
    let cancelBag = CancelBag()

    func testLoadableValues() {
        let testValues: [Loadable<Int>] = [
            .notRequested,
            .isLoading(last: nil, cancelBag: cancelBag),
            .loaded(1),
            .loaded(2),
            .failed(testError)
        ]
        
        testValues.enumerated().forEach { idx, val in
            switch idx {
            case 0:
                XCTAssertEqual(val, .notRequested)
                XCTAssertNil(val.error)
                XCTAssertNil(val.value)
            case 1:
                XCTAssertEqual(val, .isLoading(last: nil, cancelBag: cancelBag))
                XCTAssertEqual(val.value, nil)
                XCTAssertNil(val.error)
            case 2:
                XCTAssertEqual(val, .loaded(1))
                XCTAssertEqual(val.value, 1)
                XCTAssertNil(val.error)
            case 3:
                XCTAssertEqual(val, .loaded(2))
                XCTAssertEqual(val.value, 2)
                XCTAssertNil(val.error)
            case 4:
                XCTAssertEqual(val, .failed(testError))
                XCTAssertNotNil(val.error)
                XCTAssertNil(val.value)
            default:
                break
            }
        }
    }
    
    func testCancelLoading() {
        let subject = PassthroughSubject<Int, Never>()
        subject.sink { _ in }.store(in: cancelBag)
        XCTAssertEqual(cancelBag.subscribers.count, 1)

        var loadable = Loadable<Int>.isLoading(last: nil, cancelBag: cancelBag)
        XCTAssertEqual(cancelBag.subscribers.count, 1)

        loadable.cancelLoading()
        XCTAssertEqual(cancelBag.subscribers.count, 0)
    }
}
