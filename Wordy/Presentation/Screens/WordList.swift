//
//  WordList.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/3/1.
//

import SwiftUI
import Combine

struct WordList: View {
    @Environment(\.injected) private var injected: DIContainer

    @State private(set) var words: Loadable<[Word]>
    @State private var routingState: Routing = .init()
    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.wordList)
    }

    private var tag: WordTag

    init(tag: WordTag, words: Loadable<[Word]> = .idle) {
        self.tag = tag
        self._words = .init(initialValue: words)
    }

    var body: some View {
        content
    }
}

private extension WordList {
    @ViewBuilder var content: some View {
        switch words {
        case .idle:
            IdleView(perform: loadWords)
        case .isLoading:
            LoadingView(title: "Loading \(tag.displayName)")
        case .loaded(let words):
            List(words) { word in
                Button(word.word) {
                    showWordDetailSheet(word)
                }
            }
            .navigationTitle(tag.displayName)
            .onReceive(routingUpdate) { self.routingState = $0 }
            .sheet(item: routingBinding.word) { itm in
                WordDetail(word: routingBinding.word)
            }
        case .failed(let error):
            ErrorView(error: error, retryAction: loadWords)
        }
    }

    func loadWords() {
        injected
            .interactors
            .dict
            .load($words, forTag: tag.code)
    }

    func showWordDetailSheet(_ word: Word) {
        injected.appState.value[keyPath: \.routing.wordList.word] = word
    }
}

private extension WordList {
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.map(\.routing.wordList).removeDuplicates().eraseToAnyPublisher()
    }
}

extension WordList {
    struct Routing: Equatable {
        var word: Word?
    }
}

struct WordList_Previews: PreviewProvider {
    static var previews: some View {
        WordList(tag: WordTag.cet6, words: .idle)
        WordList(tag: WordTag.gre, words: .isLoading(last: nil, cancelBag: CancelBag()))
        WordList(tag: WordTag.gaoKao, words: .failed(testError))
        WordList(tag: WordTag.cet4, words: .loaded(Word.mockedWordList))
        WordList(tag: WordTag.ielts, words: .loaded(Word.mockedWordList))
            .preferredColorScheme(.dark)
    }
}
