//
//  WordList.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/3/1.
//

import SwiftUI

struct WordList: View {
    @Environment(\.injected) private var injected: DIContainer

    @State private(set) var words: Loadable<[Word]>
    @State private var selected: Word? = nil

    private var tag: WordTag

    init(tag: WordTag, words: Loadable<[Word]> = .idle) {
        self.tag = tag
        self._words = .init(initialValue: words)
    }

    var body: some View {
        content
            .onAppear(perform: loadWords)
            .navigationTitle(tag.displayName)
            .sheet(item: $selected) { itm in
                WordDetail(word: itm)
            }
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
                    selected = word
                }
            }
        case .failed(let error):
            ErrorView(error: error, retryAction: loadWords)
        }
    }

    func loadWords() {
        injected.interactors.dictInteractor.load($words, forTag: tag.code)
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
