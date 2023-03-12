//
//  DataController.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/3/10.
//

import Foundation
import CoreData
import Combine

protocol PERSISTENT_STORE {
    func count() -> AnyPublisher<Int, Error>
    func fetch() -> AnyPublisher<[Vocabulary], Error>
    func save() -> AnyPublisher<Void, Error>
    func save(word: String) -> AnyPublisher<Void, Error>
}

struct DataController: PERSISTENT_STORE {
    private let bgQueue = DispatchQueue(label: "coredata")
    private let container: NSPersistentContainer = .init(name: "FlyingWords")
    private let isStoreLoaded = CurrentValueSubject<Bool, Error>(false)
    private let entityName = "Vocabulary"

    private var onStoreIsReady: AnyPublisher<Void, Error> {
        return isStoreLoaded.filter { $0 }.map { _ in }.eraseToAnyPublisher()
    }

    init(directory: FileManager.SearchPathDirectory = .documentDirectory,
         domainMask: FileManager.SearchPathDomainMask = .userDomainMask) {

        bgQueue.sync { [weak isStoreLoaded, weak container] in
            if let url = DataController.dbFileURL(directory, domainMask) {
                let store = NSPersistentStoreDescription(url: url)
                container?.persistentStoreDescriptions = [store]
            }

            container?.loadPersistentStores(completionHandler: { _, error in
                DispatchQueue.main.async {
                    if let error = error {
                        isStoreLoaded?.send(completion: .failure(error))
                    } else {
                        isStoreLoaded?.send(true)
                    }
                }
            })
        }
    }

    func count() -> AnyPublisher<Int, Error> {
        let request: NSFetchRequest<Vocabulary> = .init(entityName: entityName)

        return onStoreIsReady
            .flatMap { [weak bgQueue, weak container] in
                Future<Int, Error> { promise in
                    bgQueue?.async {
                        do {
                            let count = try container?.viewContext.count(for: request) ?? 0
                            promise(.success(count))
                        } catch {
                            promise(.failure(error))
                        }
                    }
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func fetch() -> AnyPublisher<[Vocabulary], Error> {
        let request: NSFetchRequest<Vocabulary> = .init(entityName: entityName)

        let fetch = Future<[Vocabulary], Error> { [weak bgQueue, weak container] promise in
            bgQueue?.async {
                do {
                    let res = try container?.viewContext.fetch(request) ?? []
                    promise(.success(res))
                } catch {
                    promise(.failure(error))
                }
            }
        }

        return onStoreIsReady
            .flatMap { fetch }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func save() -> AnyPublisher<Void, Error> {
        let future = Future<Void, Error> { [weak bgQueue, weak container] promise in
            bgQueue?.sync {
                do {
                    try container?.viewContext.save()
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }

        return future.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }

    func save(word: String) -> AnyPublisher<Void, Error> {
        let create = Future<Void, Error> { [weak bgQueue, weak container] promise in
            bgQueue?.sync {
                if let context = container?.viewContext {
                    let vocabulary = Vocabulary(context: context)
                    vocabulary.word = word

                    do {
                        try context.save()
                        promise(.success(()))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }

        return onStoreIsReady
            .flatMap { create }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func delete(_ vocabulary: Vocabulary) -> AnyPublisher<Void, Error> {
        let delete = Future<Void, Error> { [weak bgQueue, weak container] promise in
            bgQueue?.sync {
                do {
                    container?.viewContext.delete(vocabulary)
                    try container?.viewContext.save()
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }

        return onStoreIsReady
            .flatMap { delete }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

extension DataController {
    static func dbFileURL(_ directory: FileManager.SearchPathDirectory,
                          _ domainMask: FileManager.SearchPathDomainMask) -> URL? {
        return FileManager.default
            .urls(for: directory, in: domainMask).first?
            .appendingPathComponent("db.sql")
    }
}
