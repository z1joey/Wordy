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
    @State private var error: Error?

    private let environment: AppEnvironment
    private let container: DIContainer

    init() {
        environment = AppEnvironment.bootstrap()
        container = environment.container
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear(perform: loadUserData)
                .environment(\.injected, container)
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

    func loadUserData() {
        container
            .interactors
            .userData
            .loadData(onError: $error)
    }
}
