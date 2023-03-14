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
        sut = DataController(modelName: "FlyingWords", directory: testDirectory)
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

        sut.fetch(WordEntity.request())
            //.compactMap { $0.first?.words?.toArray(of: WordEntity.self) }
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    XCTFail(error.localizedDescription, file: #file, line: #line)
                }
            } receiveValue: { words in
                XCTAssertEqual(words, [], file: #file, line: #line)
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 1)
    }

    func testInaccessibleDirectory() {
        let sut = DataController(modelName: "FlyingWords", directory: .adminApplicationDirectory, domainMask: .systemDomainMask)
        let exp = XCTestExpectation(description: #function)

        sut.fetch(UserDataEntity.request())
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

        sut.count(UserDataEntity.request())
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
        
        sut.save { context in
            let entity = WordEntity(context: context)
            entity.word = testWord
            entity.visited = Date()
        }
        .flatMap { self.sut.fetch(WordEntity.request()) }
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
        
        sut.save { context in
            let entity = WordEntity(context: context)
            entity.word = testWord
            entity.visited = Date()
        }
        .flatMap { self.sut.fetch(WordEntity.request()) }
        .compactMap { $0.first }
        .flatMap { entity in
            self.sut.save { _ in
                entity.word = updatedWord
            }
        }
        .flatMap { self.sut.fetch(WordEntity.request()) }
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
        
        sut.save { context in
            let entity = WordEntity(context: context)
            entity.word = testWord
            entity.visited = Date()
        }
        .flatMap { self.sut.fetch(WordEntity.request()) }
        .compactMap { $0.first }
        .flatMap { entity in
            self.sut.save { context in
                context.delete(entity)
            }
        }
        .flatMap {
            self.sut.count(WordEntity.request())
        }
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

    func testFetchingUserData() {
        let exp = XCTestExpectation(description: #function)

        sut.save { context in
            let userData = UserDataEntity(context: context)
            let word = WordEntity(context: context)
            word.word = "whatever"
            word.visited = Date()
            userData.addToWords(word)
            userData.wordTag = "cet4"
            userData.target = 60
        }
        .flatMap { self.sut.fetch(UserDataEntity.request()) }
        .compactMap { $0.first }
        .sink { completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                XCTFail(error.localizedDescription, file: #file, line: #line)
            }
        } receiveValue: { userData in
            XCTAssertEqual(userData.target, 60, file: #file, line: #line)
            XCTAssertEqual(userData.wordTag, "cet4", file: #file, line: #line)
            XCTAssertEqual(userData.words?.count, 1, file: #file, line: #line)
            exp.fulfill()
        }
        .store(in: cancelBag)

        wait(for: [exp], timeout: 1)
    }
}
