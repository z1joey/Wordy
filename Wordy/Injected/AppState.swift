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
    var permissions = Permissions()
}

// MARK: Routing
extension AppState {
    struct ViewRouting {
        var wordList = WordList.Routing()
    }

    struct System {
        var isActive: Bool = false
    }
}

// MARK: Permission
extension AppState {
    struct Permissions: Equatable {
        var push: Permission.Status = .unknown
        var speech: Permission.Status = .unknown
    }
}

extension AppState {
    static var preview: AppState {
        var state = AppState()
        state.system.isActive = true
        return state
    }
}
