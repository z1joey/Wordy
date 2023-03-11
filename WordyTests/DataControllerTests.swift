//
//  DataControllerTests.swift
//  WordyUITests
//
//  Created by Joey Zhang on 2023/3/12.
//

import XCTest
import Combine
import CoreData

@testable import Wordy

final class DataControllerTests: XCTestCase {
    let testDirectory: FileManager.SearchPathDirectory = .cachesDirectory

    var sut: DataController!
    var cancelBag = CancelBag()

    override func setUp() {
        eraseDBFiles()
        sut = DataController(directory: testDirectory)
    }

    override func tearDown() {
        cancelBag = CancelBag()
        sut = nil
        eraseDBFiles()
    }

    func eraseDBFiles() {
        if let url = DataController.dbFileURL(testDirectory, .userDomainMask) {
            try? FileManager().removeItem(at: url)
        }
    }

    func testInitialization() {
        let exp = XCTestExpectation(description: #function)

        sut.fetch()
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    XCTFail(error.localizedDescription, file: #file, line: #line)
                }
            } receiveValue: { values in
                XCTAssertEqual(values, [], file: #file, line: #line)
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 1)
    }

    func testInaccessibleDirectory() {
        let sut = DataController(directory: .adminApplicationDirectory, domainMask: .systemDomainMask)
        let exp = XCTestExpectation(description: #function)

        sut.fetch()
            .sink { completion in
                switch completion {
                case .finished:
                    XCTFail("Unexpected success", file: #file, line: #line)
                case .failure(let error):
                    XCTAssertNotNil(error)
                    exp.fulfill()
                }
            } receiveValue: { _ in
                XCTFail("Unexpected success", file: #file, line: #line)
            }
            .store(in: cancelBag)

        wait(for: [exp], timeout: 1)
    }

    func testCouting() {
        let exp = XCTestExpectation(description: #function)

        sut.count()
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    XCTFail(error.localizedDescription, file: #file, line: #line)
                }
            } receiveValue: { count in
                XCTAssertEqual(count, 0, file: #file, line: #line)
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 1)
    }

    func testSavingAndFetching() {
        let exp = XCTestExpectation(description: #function)
        let testWord = "Hello"

        sut.save(word: testWord)
            .flatMap { self.sut.fetch() }
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    XCTFail(error.localizedDescription, file: #file, line: #line)
                }
            } receiveValue: { val in
                let word = val.first?.word
                XCTAssertEqual(word, testWord, file: #file, line: #line)
                exp.fulfill()
            }
            .store(in: cancelBag)

        wait(for: [exp], timeout: 1)
    }

    func testUpdating() {
        let exp = XCTestExpectation(description: #function)
        let testWord = "Hello"
        let updatedWord = "World"
        
        sut.save(word: testWord)
            .flatMap { self.sut.fetch() }
            .compactMap { $0.first }
            .map { $0.word = updatedWord }
            .flatMap { self.sut.save() }
            .flatMap { self.sut.fetch() }
            .compactMap { $0.first }
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    XCTFail(error.localizedDescription, file: #file, line: #line)
                }
            } receiveValue: { res in
                XCTAssertEqual(res.word, updatedWord, file: #file, line: #line)
                exp.fulfill()
            }
            .store(in: cancelBag)

        wait(for: [exp], timeout: 1)
    }

    func testDeleting() {
        let exp = XCTestExpectation(description: #function)
        let testWord = "Hello"
        
        sut.save(word: testWord)
            .flatMap { self.sut.fetch() }
            .compactMap { $0.first }
            .flatMap { self.sut.delete($0) }
            .flatMap { self.sut.count() }
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    XCTFail(error.localizedDescription, file: #file, line: #line)
                }
            } receiveValue: { count in
                XCTAssertEqual(count, 0, file: #file, line: #line)
                exp.fulfill()
            }
            .store(in: cancelBag)

        wait(for: [exp], timeout: 1)
    }

}
