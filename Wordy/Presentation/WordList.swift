//
//  WordList.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/2/27.
//

import SwiftUI

struct WordList: View {
    @State private(set) var words: Loadable<[Word]>

    @Environment(\.injected) private var injected: DIContainer

    init(words: Loadable<[Word]> = .notRequested) {
        self._words = .init(initialValue: words)
    }

    var body: some View {
        List(WordTag.allCases) { tag in
            Text(tag.displayName)
        }
    }
}

struct WordList_Previews: PreviewProvider {
    static var previews: some View {
        WordList(words: .loaded(Word.mockedWordList))
    }
}

extension WordTag: Identifiable {
    public var id: String {
        return displayName
    }
}
