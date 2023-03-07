//
//  AppState.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/2/27.
//

import Foundation

struct AppState {
    var routing = ViewRouting()
    var permissions = Permissions()
}

// MARK: Routing
extension AppState {
    struct ViewRouting {
        var wordList = WordList.Routing()
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
        return AppState()
    }
}
