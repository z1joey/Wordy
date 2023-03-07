//
//  ECDictInteractor.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/2/23.
//

import Foundation
import SwiftUI
import Combine

protocol EC_DICT_INTERACTOR {
    func load(_ connection: Binding<Loadable<Void>>)
    func load(_ detail: Binding<Loadable<Word>>, forWord word: String)
    func load(_ wordList: Binding<Loadable<[Word]>>, forTag tag: String)
}

struct ECDictInteractor: EC_DICT_INTERACTOR {
    private let dict: EC_DICT_REPO

    init(dictRepo: EC_DICT_REPO) {
        self.dict = dictRepo
    }

    func load(_ connection: Binding<Loadable<Void>>) {
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

    func load(_ detail: Binding<Loadable<Word>>, forWord word: String) {
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

    func load(_ wordList: Binding<Loadable<[Word]>>, forTag tag: String) {
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
    func load(_ connection: Binding<Loadable<Void>>) {}
    func load(_ detail: Binding<Loadable<Word>>, forWord word: String) {}
    func load(_ wordList: Binding<Loadable<[Word]>>, forTag tag: String) {}
}
