//
//  ContentView.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/2/22.
//

import SwiftUI
import Combine

struct ContentView: View {
    @Environment(\.injected) private var injected: DIContainer
    @State private var canRequestSpeechPermission: Bool = false

    var body: some View {
        TabView {
            TagList()
                .environment(\.injected, injected)
                .tabItem {
                    Label("WordList", systemImage: "list.dash")
                }

            Quiz()
                .environment(\.injected, injected)
                .tabItem {
                    Label("Practice", systemImage: "square.and.pencil")
                }

            UserData()
                .environment(\.injected, injected)
                .tabItem {
                    Label("UserData", systemImage: "square")
                }

            TagSetting()
                .environment(\.injected, injected)
                .tabItem {
                    Label("TagSetting", systemImage: "circle")
                }
        }
        .onReceive(canRequestSpeechPermissionUpdate, perform: requestSpeechPermission)
    }
}

private extension ContentView {
    var canRequestSpeechPermissionUpdate: AnyPublisher<Void, Never> {
        injected
            .appState
            .map(\.permissions.speech)
            .map { $0 == .notRequested }
            .map { _ in }
            .eraseToAnyPublisher()
    }

    func requestSpeechPermission() {
        injected
            .interactors
            .permission
            .request(permission: .speechRecognizer)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
