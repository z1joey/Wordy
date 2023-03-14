//
//  UserData.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/3/12.
//

import SwiftUI
import Combine
import CoreData

struct UserData: View {
    @Environment(\.injected) private var injected: DIContainer
    @State private(set) var entities: [WordEntity] = []
    @State private(set) var error: Error?
    @State private(set) var refreshID = UUID()

    var body: some View {
        VStack {
            List {
                ForEach(entities) { item in
                    HStack {
                        Text(item.word ?? "Unknown")

                        Spacer()

                        Button("update") {
                            save { _ in
                                item.word = fakeWord()
                                refreshID = UUID()
                            }
                        }
                    }
                }
                .onDelete(perform: delete)
            }
            .id(refreshID)

            Button("Add Test Data") {
                save { context in
                    let entity = WordEntity(context: context)
                    entity.word = fakeWord()
                    entity.visited = 1
                    entity.confidence = 0
                    entity.lastTime = Date()
                    entity.done = false
                    injected.appState.value[keyPath: \.userData]?.addToWords(entity)
                }
            }
        }
        .onReceive(wordUpdate) { self.entities = $0 }
    }
}

private extension UserData {
    var wordUpdate: AnyPublisher<[WordEntity], Never> {
        injected
            .appState
            .map(\.userData?.words)
            .compactMap { $0?.toArray(of: WordEntity.self) }
            .eraseToAnyPublisher()
    }

    func delete(offsets: IndexSet) {
        withAnimation {
            offsets
                .map { entities[$0] }
                .forEach { entity in
                    injected.interactors.userData.save(onError: $error) { context in
                        context.delete(entity)  
                    }
                }
        }
    }

    func save(operation: @escaping (NSManagedObjectContext) -> Void) {
        injected.interactors.userData.save(onError: $error, operation: operation)
    }

    func fakeWord() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyz"
        let char1 = String(letters.randomElement()!)
        let char2 = String(letters.randomElement()!)
        let char3 = String(letters.randomElement()!)
        let word = char1 + char2 + char3
        return word
    }
}

struct UserData_Previews: PreviewProvider {
    static var previews: some View {
        UserData()
    }
}
