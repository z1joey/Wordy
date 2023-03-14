//
//  TagSetting.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/3/13.
//

import SwiftUI
import Combine

struct TagSetting: View {
    @Environment(\.injected) private var injected: DIContainer

    @State private var selection: WordTag = .cet4
    @State private var count: Double = 50

    @State private var routingState: Routing = .init()
    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.tagSetting)
    }

    var body: some View {
        Form {
            Section() {
                Button(selection.displayName) {
                    showTagsSheet()
                }

                VStack {
                    Text("\(Int(count)) Words")
                    Slider(value: $count, in: 10...100, step: 10)
                }
                .padding()

                HStack {
                    Spacer()
                    Button("Start") {
                        
                    }
                    Spacer()
                }
            }
        }
        .onReceive(tagUpdate) { selection = $0 }
        .onReceive(routingUpdate) { self.routingState = $0 }
        .sheet(isPresented: routingBinding.tagsSheet) { TagSelection() }
    }
}

private extension TagSetting {
    var tagUpdate: AnyPublisher<WordTag, Never> {
        injected
            .appState
            .map(\.userData.selectedTag)
            .eraseToAnyPublisher()
    }

    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.map(\.routing.tagSetting).removeDuplicates().eraseToAnyPublisher()
    }

    func showTagsSheet() {
        injected.appState.value[keyPath: \.routing.tagSetting.tagsSheet] = true
    }
}

extension TagSetting {
    struct Routing: Equatable {
        var tagsSheet: Bool = false
    }
}

struct BookSelection_Previews: PreviewProvider {
    static var previews: some View {
        TagSetting()
        TagSetting().preferredColorScheme(.dark)
    }
}
