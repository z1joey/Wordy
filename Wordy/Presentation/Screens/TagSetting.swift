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
    @State private var target: Double = 50
    @State private var error: Error?

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
                    Text("\(Int(target)) Words")
                    Slider(value: $target, in: 10...100, step: 10)
                        .onChange(of: target, perform: updateTarget)
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
        .onReceive(tagUpdate) { self.selection = $0 }
        .onReceive(routingUpdate) { self.routingState = $0 }
        .onAppear {
            let target = injected.appState.value[keyPath: \.userData?.target]
            self.target = Double(target ?? 50)
        }
        .sheet(isPresented: routingBinding.tagsSheet) { TagSelection() }
    }
}

private extension TagSetting {
    var tagUpdate: AnyPublisher<WordTag, Never> {
        injected
            .appState
            .compactMap(\.userData?.wordTag)
            .compactMap { WordTag(rawValue: $0) }
            .eraseToAnyPublisher()
    }

    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.map(\.routing.tagSetting).removeDuplicates().eraseToAnyPublisher()
    }

    func showTagsSheet() {
        injected.appState.value[keyPath: \.routing.tagSetting.tagsSheet] = true
    }

    func updateTarget(_ target: Double) {
        injected.interactors.userData.save(onError: $error) { context in
            injected.appState.value[keyPath: \.userData!.target] = Int16(target)
        }
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
