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
        }
        .onReceive(canRequestSpeechPermissionUpdate, perform: { canRequest in
            if canRequest { requestSpeechPermission() }
        })
    }
}

private extension ContentView {
    var canRequestSpeechPermissionUpdate: AnyPublisher<Bool, Never> {
        injected
            .appState
            .map(\.permissions.speech)
            .map { $0 == .notRequested || $0 == .denied }
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
