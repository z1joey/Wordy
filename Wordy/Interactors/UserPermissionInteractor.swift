//
//  UserPermissionInteractor.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/3/7.
//

import Foundation
import UserNotifications
import Speech
import Combine

enum Permission {
    case pushNotifications
    case speechRecognizer
}

extension Permission {
    enum Status: Equatable {
        case unknown
        case notRequested
        case granted
        case denied
    }

    var keyPath: WritableKeyPath<AppState, Permission.Status> {
        let path = \AppState.permissions
        switch self {
        case .pushNotifications:
            return path.appending(path: \.push)
        case .speechRecognizer:
            return path.appending(path: \.speech)
        }
    }
}

protocol USER_PERMISSION_INTERACTOR {
    func resolveStatus(for permission: Permission)
    func request(permission: Permission)
}

final class UserPermissionInteractor: USER_PERMISSION_INTERACTOR {
    private let appState: CurrentValueSubject<AppState, Never>
    private let openAppSettings: () -> Void

    init(appState: CurrentValueSubject<AppState, Never>, openAppSettings: @escaping () -> Void) {
        self.appState = appState
        self.openAppSettings = openAppSettings
    }

    func resolveStatus(for permission: Permission) {
        let currentStatus = appState.value[keyPath: permission.keyPath]
        guard currentStatus != .denied else { return }

        let onResolve: (Permission.Status) -> Void = { [weak appState] status in
            appState?.value[keyPath: permission.keyPath] = status
        }

        switch permission {
        case .pushNotifications:
            pushNotificationsPermissionStatus(onResolve)
        case .speechRecognizer:
            speechRecognizerPermissionStatus(onResolve)
        }
    }

    func request(permission: Permission) {
        let currentStatus = appState.value[keyPath: permission.keyPath]
        guard currentStatus != .denied else {
            openAppSettings()
            return
        }

        switch permission {
        case .pushNotifications:
            requestPushNotificationsPermission()
        case .speechRecognizer:
            requestSpeechRecognizerPermission()
        }
    }
}

// MARK: Push
private extension UserPermissionInteractor {
    func pushNotificationsPermissionStatus(_ resolve: @escaping (Permission.Status) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                resolve(settings.authorizationStatus.map)
            }
        }
    }

    func requestPushNotificationsPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (isGranted, error) in
            DispatchQueue.main.async {
                self.appState.value[keyPath: \.permissions.push] = isGranted ? .granted : .denied
            }
        }
    }
}

// MARK: Speech
private extension UserPermissionInteractor {
    func speechRecognizerPermissionStatus(_ resolve: @escaping (Permission.Status) -> Void) {
        let status = SFSpeechRecognizer.authorizationStatus()
        resolve(status.map)
    }

    func requestSpeechRecognizerPermission() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                self.appState.value[keyPath: \.permissions.push] = authStatus.map
            }
        }
    }
}

// MARK: Mapping
extension UNAuthorizationStatus {
    var map: Permission.Status {
        switch self {
        case .denied: return .denied
        case .authorized: return .granted
        case .notDetermined, .provisional, .ephemeral: return .notRequested
        @unknown default: return .notRequested
        }
    }
}

extension SFSpeechRecognizerAuthorizationStatus {
    var map: Permission.Status {
        switch self {
        case .restricted, .denied: return .denied
        case .notDetermined: return .notRequested
        case .authorized: return .granted
        @unknown default: return .notRequested
        }
    }
}

struct StubUserPermissionInteractor: USER_PERMISSION_INTERACTOR {
    func resolveStatus(for permission: Permission) {}
    func request(permission: Permission) {}
}
