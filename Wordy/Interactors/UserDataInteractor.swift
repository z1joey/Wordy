//
//  UserDataInteractor.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/3/12.
//

import Foundation
import SwiftUI
import Combine

protocol USER_DATA_INTERACTOR {
    func loadData(onError: Binding<Error?>)
    func save(onError: Binding<Error?>)
    func save(word: String, onError: Binding<Error?>)
    func delete(vocabulary: Vocabulary, onError: Binding<Error?>)
}

struct UserDataInteractor: USER_DATA_INTERACTOR {
    private let store: PERSISTENT_STORE
    private let appState: CurrentValueSubject<AppState, Never>
    private let cancelBag = CancelBag()

    init(appState: CurrentValueSubject<AppState, Never>) {
        self.appState = appState
        self.store = DataController()
    }

    func loadData(onError: Binding<Error?>) {
        Just<Void>(())
            .setFailureType(to: Error.self)
            .flatMap { store.fetch() }
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    onError.wrappedValue = error
                }
            } receiveValue: { val in
                appState.value[keyPath: \.userData.vocabularies] = val
                onError.wrappedValue = nil
            }
            .store(in: cancelBag)
    }

    func save(onError: Binding<Error?>) {
        store.save()
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    onError.wrappedValue = error
                }
            } receiveValue: { _ in
                onError.wrappedValue = nil
            }
            .store(in: cancelBag)
    }

    func save(word: String, onError: Binding<Error?>) {
        store.save(word: word)
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    onError.wrappedValue = error
                }
            } receiveValue: { _ in
                onError.wrappedValue = nil
            }
            .store(in: cancelBag)
    }

    func delete(vocabulary: Vocabulary, onError: Binding<Error?>) {
        store.delete(vocabulary)
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    onError.wrappedValue = error
                }
            } receiveValue: { _ in
                onError.wrappedValue = nil
            }
            .store(in: cancelBag)
    }
}

struct StubUserDataInteractor: USER_DATA_INTERACTOR {
    func loadData(onError: Binding<Error?>) {}
    func save(onError: Binding<Error?>) {}
    func save(word: String, onError: Binding<Error?>) {}
    func delete(vocabulary: Vocabulary, onError: Binding<Error?>) {}
}
