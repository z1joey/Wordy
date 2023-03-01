//
//  ContentView.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/2/22.
//

import SwiftUI

struct ContentView: View {
    private let environment: AppEnvironment
    private let container: DIContainer

    @State private(set) var connection: Loadable<Void>

    init() {
        environment = AppEnvironment.bootstrap()
        container = environment.container
        _connection = .init(initialValue: .notRequested)
    }

    var body: some View {
        content.onAppear(perform: connect)
    }
}

private extension ContentView {
    @ViewBuilder var content: some View {
        switch connection {
        case .loaded:
            TagList().environment(\.injected, container)
        default:
            Text(connection.desc)
        }
    }

    func connect() {
        container.interactors.dictInteractor.connect($connection)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
