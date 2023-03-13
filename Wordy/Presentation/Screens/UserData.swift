//
//  UserData.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/3/12.
//

import SwiftUI
import Combine

struct UserData: View {
    @Environment(\.injected) private var injected: DIContainer
    @State private(set) var vocabularies: [Vocabulary] = []
    @State private(set) var error: Error?

    var body: some View {
        VStack {
            List(vocabularies, id: \.word) { item in
                HStack {
                    Text(item.word ?? "Unknown")

                    Spacer()

                    Button("update") {
                        item.word = "BBB"
                        save()
                    }

//                    Button("delete") {
//                        delete(item)
//                    }
                }
            }

            Button("Add Test Data") {
                saveWord("AAA")
            }

            Button("Refresh Data") {
                loadVocabularies()
            }
        }
        .onAppear(perform: loadVocabularies)
        .onReceive(vocabularyUpdate) { self.vocabularies = $0 }
    }
}

private extension UserData {
    var vocabularyUpdate: AnyPublisher<[Vocabulary], Never> {
        injected
            .appState
            .map(\.userData.vocabularies)
            .eraseToAnyPublisher()
    }

    func loadVocabularies() {
        injected.interactors.userData.loadData(onError: $error)
    }

    func saveWord(_ word: String) {
        injected.interactors.userData.save(word: word, onError: $error)
    }

    func delete(_ vocabulary: Vocabulary) {
        injected.interactors.userData.delete(vocabulary: vocabulary, onError: $error)
    }

    func save() {
        injected.interactors.userData.save(onError: $error)
    }
}

struct UserData_Previews: PreviewProvider {
    static var previews: some View {
        UserData()
    }
}
