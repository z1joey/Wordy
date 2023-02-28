//
//  ECDictInteractor.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/2/23.
//

import Foundation
import Combine

protocol EC_DICT_INTERACTOR {
    func connect(_ connection: LoadableSubject<Void>)
    func load(_ detail: LoadableSubject<Word>, forWord word: String)
    func load(_ wordList: LoadableSubject<[Word]>, forTag tag: String)
}

struct ECDictInteractor: EC_DICT_INTERACTOR {
    func connect(_ connection: LoadableSubject<Void>) {
        let cancelBag = CancelBag()
        connection.wrappedValue.setIsLoading(cancelBag: cancelBag)

        Just<Void>(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
            .flatMap {
                return dict.connect()
            }
            .sinkToLoadable {
                connection.wrappedValue = $0
            }
            .store(in: cancelBag)
    }

    private let dict: EC_DICT_REPO

    init(dictRepo: EC_DICT_REPO) {
        self.dict = dictRepo
    }

    func load(_ detail: LoadableSubject<Word>, forWord word: String) {
        let cancelBag = CancelBag()
        detail.wrappedValue.setIsLoading(cancelBag: cancelBag)

        Just<Void>(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
            .flatMap {
                return dict.search(word)
            }
            .sinkToLoadable { detail.wrappedValue = $0 }
            .store(in: cancelBag)
    }
    
    func load(_ wordList: LoadableSubject<[Word]>, forTag tag: String) {
        let cancelBag = CancelBag()
        wordList.wrappedValue.setIsLoading(cancelBag: cancelBag)

        Just<Void>(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
            .flatMap {
                return dict.wordList(tag: tag)
            }
            .sinkToLoadable { wordList.wrappedValue = $0 }
            .store(in: cancelBag)
    }
}

struct StubECDictInteractor: EC_DICT_INTERACTOR {
    func connect(_ connection: LoadableSubject<Void>) {}
    func load(_ detail: LoadableSubject<Word>, forWord word: String) {}
    func load(_ wordList: LoadableSubject<[Word]>, forTag tag: String) {}
}
