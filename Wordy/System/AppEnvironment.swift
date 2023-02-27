//
//  AppEnvironment.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/2/27.
//

import Foundation

struct AppEnvironment {
    let container: DIContainer
}

extension AppEnvironment {
    static func bootstrap() -> AppEnvironment {
        let appState = Store(AppState())
        let dictRepo = ECDcitRepo()
        let dictInteractor = ECDictInteractor(dictRepo: dictRepo)
        let interactors = DIContainer.Interactors(dictInteractor: dictInteractor)

        return .init(container: DIContainer(appState: appState, interactors: interactors))
    }
}
