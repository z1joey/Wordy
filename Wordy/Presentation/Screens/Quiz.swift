//
//  Quiz.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/3/7.
//

import SwiftUI

struct Quiz: View {
    @Environment(\.injected) private var injected: DIContainer
    @State private(set) var result: SpeechResult = .init(segment: .init())

    private let cancelBag = CancelBag()

    var body: some View {
        Text(result.word)
            .onAppear(perform: loadSpeechResults)
            .onDisappear(perform: stopSpeechRecoginizer)
    }
}

private extension Quiz {
    func loadSpeechResults() {
        injected
            .interactors
            .speech
            .load($result, cancelBag: cancelBag)
    }

    func stopSpeechRecoginizer() {
        injected
            .interactors
            .speech
            .stop()
    }
}

struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        Quiz()
    }
}
