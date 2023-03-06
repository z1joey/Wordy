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

    init(connection: Loadable<Void> = .idle) {
        environment = AppEnvironment.bootstrap()
        container = environment.container
        _connection = .init(initialValue: connection)
    }

    var body: some View {
        content
    }
}

private extension ContentView {
    @ViewBuilder var content: some View {
        switch connection {
        case .idle:
            IdleView(perform: connect)
        case .isLoading:
            LoadingView()
        case .loaded:
            TagList().environment(\.injected, container)
        case .failed(let error):
            ErrorView(error: error, retryAction: connect)
        }
    }

    func connect() {
        container.interactors.dictInteractor.connect($connection)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(connection: .idle)
        ContentView(connection: .isLoading(last: nil, cancelBag: CancelBag()))
        ContentView(connection: .loaded(()))
        ContentView(connection: .failed(testError))
    }
}
