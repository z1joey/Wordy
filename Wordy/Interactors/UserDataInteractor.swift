//
//  UserDataInteractor.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/3/12.
//

import Foundation
import SwiftUI
import Combine
import CoreData

protocol USER_DATA_INTERACTOR {
    func loadData(onError: Binding<Error?>)
    func save(onError: Binding<Error?>, operation: @escaping (NSManagedObjectContext) -> Void)
}

struct UserDataInteractor: USER_DATA_INTERACTOR {
    private let store: PERSISTENT_STORE
    private let appState: CurrentValueSubject<AppState, Never>
    private let cancelBag = CancelBag()

    init(appState: CurrentValueSubject<AppState, Never>) {
        self.appState = appState
        self.store = DataController(modelName: "FlyingWords")
    }

    func loadData(onError: Binding<Error?>) {
        store.fetch(UserDataEntity.request())
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    onError.wrappedValue = error
                }
            } receiveValue: { res in
                onError.wrappedValue = nil

                if let userData = res.first {
                    appState.value[keyPath: \.userData] = userData
                } else {
                    save(onError: onError) { context in
                        let userData = UserDataEntity(context: context)
                        userData.wordTag = WordTag.cet4.code
                        userData.target = 50
                        userData.words = []

                        appState.value[keyPath: \.userData] = userData
                    }
                }
            }
            .store(in: cancelBag)
    }

    func save(onError: Binding<Error?>, operation: @escaping (NSManagedObjectContext) -> Void) {
        store.save(operation: operation)
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
    func save(onError: Binding<Error?>, operation: @escaping (NSManagedObjectContext) -> Void) {}
}
