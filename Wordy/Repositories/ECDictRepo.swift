//
//  ECDictRepo.swift
//
//  Created by Joey Zhang on 2023/2/21.
//

import Foundation
import Combine
import SQLite

public protocol EC_DICT_REPO {
    func connect() -> AnyPublisher<Void, Error>
    func search(_ word: String) -> AnyPublisher<Word, Error>
    func wordList(tag: String) -> AnyPublisher<[Word], Error>
}

private let bundleIdentifier = "com.z1joey.Wordy"
private let resourceName = "db_ecdict"
private let tableName = "ecdict"
private let key = "word"

public class ECDcitRepo: EC_DICT_REPO {
    private let bgQueue = DispatchQueue(label: "com.z1joey.wordy.Repo")
    private var db: Connection? = nil

    public func connect() -> AnyPublisher<Void, Error> {
        let future = Future<Void, Error> { [weak self, weak bgQueue] promise in
            bgQueue?.sync {
                guard let path = Bundle(identifier: bundleIdentifier)?.url(forResource: resourceName, withExtension: "sqlite3")?.absoluteString else {
                    promise(.failure(RepoError.invalidFilePath))
                    return
                }

                do {
                    self?.db = try Connection(path, readonly: true)
                    promise(.success(()))
                } catch let error {
                    promise(.failure(error))
                }
            }
        }

        return future.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    
    public func search(_ word: String) -> AnyPublisher<Word, Error> {
        let future = Future<Word, Error> { [weak db, weak bgQueue] promise in
            bgQueue?.async {
                guard let db = db else {
                    promise(.failure(RepoError.invalidDatabase))
                    return
                }

                let table = Table(tableName)
                let expression = Expression<String>(key)
                let result = table.filter(expression == word)

                do {
                    if let row = try db.pluck(result) {
                        promise(.success(try row.decode()))
                    } else {
                        promise(.failure(RepoError.notFound(word: word)))
                    }
                } catch {
                    promise(.failure(error))
                }
            }
        }

        return future.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    
    public func wordList(tag: String) -> AnyPublisher<[Word], Error> {
        guard let tag = WordTag(rawValue: tag) else {
            return Fail(error: RepoError.invalidWordTag).eraseToAnyPublisher()
        }

        switch tag {
        case .collins(let stars):
            let oxfordExpression = Expression<String?>("collins")
            let table = Table(tableName).filter(oxfordExpression == "\(stars)")
            return pareTableIntoArray(table)
        case .oxford:
            let collinsExpression = Expression<String?>("oxford")
            let table = Table(tableName).filter(collinsExpression == "1")
            return pareTableIntoArray(table)
        default:
            let tagExpression = Expression<String?>("tag")
            let table = Table(tableName).filter(tagExpression.like("%\(tag.code)%"))
            return pareTableIntoArray(table)
        }
    }
}

private extension ECDcitRepo {
    func pareTableIntoArray(_ table: Table) -> AnyPublisher<[Word], Error> {
        let future = Future<[Word], Error> { [weak db, weak bgQueue] promise in
            bgQueue?.async {
                guard let db = db else {
                    promise(.failure(RepoError.invalidDatabase))
                    return
                }

                do {
                    let rows = try db.prepare(table)
                    let words: [Word] = try rows.map { try $0.decode() }
                    promise(.success(words))
                } catch let error {
                    promise(.failure(error))
                }
            }
        }

        return future.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
}

public enum RepoError: Error {
    case invalidDatabase
    case invalidFilePath
    case invalidWordTag
    case notFound(word: String)
}
