//
//  WordyTests.swift
//  WordyTests
//
//  Created by Joey Zhang on 2023/2/22.
//

import Combine
import XCTest

@testable import Wordy

final class WordyTests: XCTestCase {
    var ecdict: EC_DICT_REPO!
    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        ecdict = ECDcitRepo()
        ecdict.connect()
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                }
            } receiveValue: { _ in
                return
            }
            .store(in: &cancellables)
    }

    func testSearchingWordFromECDict() {
        let exp = expectation(description: #function)

        var error: Error?
        var word: Word?
        var isMainThread = false

        ecdict.search("hello")
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let err):
                    error = err
                }
            } receiveValue: { res in
                isMainThread = Thread.isMainThread
                word = res
                exp.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 1)

        XCTAssertTrue(isMainThread)
        XCTAssertNotNil(word)
        XCTAssertNil(error)
    }
}
