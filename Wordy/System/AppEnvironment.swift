//
//  AppEnvironment.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/2/27.
//

import Foundation
import UIKit

struct AppEnvironment {
    let container: DIContainer
}

extension AppEnvironment {
    static func bootstrap() -> AppEnvironment {
        let appState = Store(AppState())
        let dictRepo = ECDcitRepo()
        let dictInteractor = ECDictInteractor(dictRepo: dictRepo)

        let speechInteractor = SpeechInteractor()
        let permissionInteractor = UserPermissionInteractor(appState: appState, openAppSettings: {
            URL(string: UIApplication.openSettingsURLString).flatMap {
                UIApplication.shared.open($0, options: [:], completionHandler: nil)
            }
        })

        let interactors = DIContainer.Interactors(
            dict: dictInteractor,
            speech: speechInteractor,
            permission: permissionInteractor
        )

        return .init(container: DIContainer(appState: appState, interactors: interactors))
    }
}
