//
//  SpeechInteractor.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/3/7.
//

import Foundation
import Combine
import SwiftUI

protocol SPEECH_INTERACTOR {
    func load(_ speechResult: Binding<SpeechResult>, cancelBag: CancelBag)
    func stop()
}

struct SpeechInteractor: SPEECH_INTERACTOR {
    private var engine: SpeechEngine? = SpeechEngine()

    func load(_ speechResult: Binding<SpeechResult>, cancelBag: CancelBag) {
        let subject = PassthroughSubject<SpeechResult, Error>()

        DispatchQueue.global().async {
            engine?.startListening({ completion in
                switch completion {
                case .success(let result):
                    subject.send(result)
                case .failure(let error):
                    subject.send(completion: .failure(error))
                }
            })
        }

        subject
            .receive(on: DispatchQueue.main)
            .sink { completion in
                // -TODO: complete here
            } receiveValue: { result in
                speechResult.wrappedValue = result
            }
            .store(in: cancelBag)
    }

    func stop() {
        engine?.stopListening()
    }
}

struct StubSpeechInteractor: SPEECH_INTERACTOR {
    func load(_ speechResult: Binding<SpeechResult>, cancelBag: CancelBag) {}
    func stop() {}
}
