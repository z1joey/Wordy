//
//  InteractorsContainer.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/2/23.
//

import Foundation

extension DIContainer {
    struct Interactors {
        let dict: EC_DICT_INTERACTOR
        let speech: SPEECH_INTERACTOR
        let permission: USER_PERMISSION_INTERACTOR

        static var stub: Self {
            .init(
                dict: StubECDictInteractor(),
                speech: StubSpeechInteractor(),
                permission: StubUserPermissionInteractor()
            )
        }
    }
}
