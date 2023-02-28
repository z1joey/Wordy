//
//  DependencyInjector.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/2/23.
//

import Foundation
import SwiftUI

struct DIContainer: EnvironmentKey {
    let appState: Store<AppState>
    let interactors: Interactors

    init(appState: Store<AppState>, interactors: Interactors) {
        self.appState = appState
        self.interactors = interactors
    }

    init(appState: AppState, interactors: Interactors) {
        self.init(appState: Store<AppState>(appState), interactors: interactors)
    }

    static var defaultValue: Self { Self.default }
    private static let `default` = Self(appState: AppState(), interactors: .stub)
}

extension DIContainer {
    static var preview: Self {
        .init(appState: .init(AppState.preview), interactors: .stub)
    }
}

extension EnvironmentValues {
    var injected: DIContainer {
        get { self[DIContainer.self] }
        set { self[DIContainer.self] = newValue }
    }
}
