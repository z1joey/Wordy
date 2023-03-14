//
//  TagSelection.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/3/14.
//

import SwiftUI
import Combine

struct TagSelection: View {
    @Environment(\.injected) private var injected: DIContainer

    @State private var selection: WordTag?
    @State private var error: Error?

    var body: some View {
        List(WordTag.allCases) { tag in
            Button {
                select(tag: tag)
            } label: {
                Text(tag.displayName)
                    .background(tag == selection ? .green : .clear)
            }
        }
        .onReceive(tagUpdate) { selection = $0 }
    }
}

private extension TagSelection {
    var tagUpdate: AnyPublisher<WordTag, Never> {
        injected
            .appState
            .compactMap(\.userData?.wordTag)
            .compactMap { WordTag(rawValue: $0) }
            .eraseToAnyPublisher()
    }

    func select(tag: WordTag) {
        injected
            .interactors
            .userData
            .save(onError: $error) { context in
                injected.appState.value[keyPath: \.userData!.wordTag] = tag.code
            }

        injected
            .appState
            .value[keyPath: \.routing.tagSetting.tagsSheet] = false
    }
}

struct TagSelection_Previews: PreviewProvider {
    static var previews: some View {
        TagSelection()
    }
}
