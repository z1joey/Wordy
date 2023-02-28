//
//  AppState.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/2/27.
//

import Foundation

struct AppState {
    var routing = ViewRouting()
    var system = System()
}

extension AppState {
    struct ViewRouting {
        var wordList = WordList()
    }

    struct System {
        var isActive: Bool = false
    }
}

extension AppState {
    static var preview: AppState {
        var state = AppState()
        state.system.isActive = true
        return state
    }
}
