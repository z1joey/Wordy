//
//  InteractorsContainer.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/2/23.
//

import Foundation

extension DIContainer {
    struct Interactors {
        let dictInteractor: EC_DICT_INTERACTOR

        static var stub: Self {
            .init(dictInteractor: StubECDictInteractor())
        }
    }
}
