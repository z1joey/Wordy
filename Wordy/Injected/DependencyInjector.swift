//
//  DependencyInjector.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/2/23.
//

import Foundation
import SwiftUI
import Combine

struct DIContainer: EnvironmentKey {
    let appState: CurrentValueSubject<AppState, Never>
    let interactors: Interactors

    init(appState: CurrentValueSubject<AppState, Never>, interactors: Interactors) {
        self.appState = appState
        self.interactors = interactors
    }

    init(appState: AppState, interactors: Interactors) {
        self.init(appState: CurrentValueSubject<AppState, Never>(appState), interactors: interactors)
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
