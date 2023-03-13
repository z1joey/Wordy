//
//  AppEnvironment.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/2/27.
//

import Foundation
import Combine
import UIKit

struct AppEnvironment {
    let container: DIContainer
}

extension AppEnvironment {
    static func bootstrap() -> AppEnvironment {
        let appState = CurrentValueSubject<AppState, Never>(AppState())
        let dictRepo = ECDcitRepo()
        let dictInteractor = ECDictInteractor(dictRepo: dictRepo)
        let speechInteractor = SpeechInteractor()
        let permissionInteractor = UserPermissionInteractor(appState: appState, openAppSettings: {
            URL(string: UIApplication.openSettingsURLString).flatMap {
                UIApplication.shared.open($0, options: [:], completionHandler: nil)
            }
        })
        let userDataInteractor = UserDataInteractor(appState: appState)

        let interactors = DIContainer.Interactors(
            dict: dictInteractor,
            speech: speechInteractor,
            permission: permissionInteractor,
            userData: userDataInteractor
        )

        return .init(container: DIContainer(appState: appState, interactors: interactors))
    }
}
