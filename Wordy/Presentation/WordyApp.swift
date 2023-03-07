//
//  WordyApp.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/2/22.
//

import SwiftUI

@main
struct WordyApp: App {
    @Environment(\.scenePhase) private var scenePhase

    private let environment: AppEnvironment
    private let container: DIContainer

    init() {
        environment = AppEnvironment.bootstrap()
        container = environment.container
    }

    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.injected, container)
        }
        .onChange(of: scenePhase) { newValue in
            switch newValue {
            case .active: resolvePermissionStatus()
            default: break
            }
        }
    }
}

private extension WordyApp {
    func resolvePermissionStatus() {
        container
            .interactors
            .permission
            .resolveStatus(for: .speechRecognizer)
    }
}
