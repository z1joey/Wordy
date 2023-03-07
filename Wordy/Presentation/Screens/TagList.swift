//
//  TagList.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/2/27.
//

import SwiftUI

struct TagList: View {
    @Environment(\.injected) private var injected: DIContainer
    @State private(set) var connection: Loadable<Void>

    init(connection: Loadable<Void> = .idle) {
        _connection = .init(initialValue: connection)
    }

    var body: some View {
        switch connection {
        case .idle:
            IdleView(perform: connect)
        case .isLoading:
            LoadingView()
        case .loaded:
            content()
        case .failed(let error):
            ErrorView(error: error, retryAction: connect)
        }
    }
}

private extension TagList {
    func content() -> some View {
        NavigationView {
            List(WordTag.allCases) { tag in
                NavigationLink(tag.displayName) {
                    WordList(tag: tag).environment(\.injected, injected)
                }
            }
        }
    }

    func connect() {
        injected
            .interactors
            .dict
            .connect($connection)
    }
}

struct TagList_Previews: PreviewProvider {
    static var previews: some View {
        TagList()
        TagList(connection: .isLoading(last: nil, cancelBag: CancelBag()))
        TagList(connection: .loaded(()))
        TagList(connection: .failed(testError))
        TagList(connection: .failed(testError)).preferredColorScheme(.dark)
    }
}
