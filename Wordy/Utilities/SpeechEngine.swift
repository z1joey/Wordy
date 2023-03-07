//
//  SpeechEngine.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/3/6.
//

import UIKit
import Speech
import AVFoundation

final class SpeechEngine {
    private var audioEngine: AVAudioEngine
    private var speechRecognizer: SFSpeechRecognizer
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var inputNode: AVAudioInputNode

    let localeId: String

    init(locale: Locale = .US) {
        audioEngine = AVAudioEngine()
        inputNode = audioEngine.inputNode
        localeId = locale.identifier
        speechRecognizer = SFSpeechRecognizer(locale: locale)!
    }

    func startListening(_ completion: @escaping (Swift.Result<SpeechResult, SpeechError>) -> Void) {
        start { result in
            switch result {
            case .success(let result):
                if let segment = result.bestTranscription.segments.last {
                    completion(.success(SpeechResult(segment: segment)))
                } else {
                    completion(.failure(.notRecognized))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func start(_ completion: @escaping (Swift.Result<SFSpeechRecognitionResult, SpeechError>) -> Void) {
        // Cancel the previous task if it's running.
        recognitionTask?.cancel()
        self.recognitionTask = nil

        // Configure the audio session for the app.
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            completion(.failure(.audioSession(desc: error.localizedDescription)))
        }

        // Create and configure the speech recognition request.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            completion(.failure(.recognitionRequest))
            return
        }
        recognitionRequest.shouldReportPartialResults = true

        // Keep speech recognition data on device
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = false
        }

        guard let myRecognizer = SFSpeechRecognizer() else {
            completion(.failure(.notSupported))
            return
        }

        if !myRecognizer.isAvailable {
            completion(.failure(.unavailable))
            return
        }
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { [weak self] result, error in
            var isFinal = false

            if let result = result {
                isFinal = result.isFinal
                completion(.success(result))
            }

            if let e = error, isFinal {
                // Stop recognizing speech if there is a problem.
                self?.stopListening()
                completion(.failure(.recognitionTask(desc: e.localizedDescription)))
            }
        })

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()

        do {
            try audioEngine.start()
        } catch {
            completion(.failure(.audioEngine(desc: error.localizedDescription)))
        }
    }

    func stopListening() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            inputNode.removeTap(onBus: 0)

            recognitionRequest = nil
            recognitionTask = nil
        }
    }

    func audio(for text: String, locale: Locale, rate: Float = 0.5) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: locale.identifier)
        utterance.rate = rate

        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
}

struct SpeechResult {
    public var word: String
    public var confidence: Float

    init(segment: SFTranscriptionSegment) {
        word = segment.substring
        confidence = segment.confidence
    }
}

public enum SpeechError: Error {
    case permissionDennied
    case audioSession(desc: String)
    case recognitionRequest
    case notSupported
    case unavailable
    case recognitionTask(desc: String)
    case audioEngine(desc: String)
    case notRecognized
}

extension SpeechError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .audioSession(let desc), .audioEngine(desc: let desc), .recognitionTask(let desc):
            return desc
        case .permissionDennied:
            return "Speech recognition permission has not been granted"
        case .recognitionRequest:
            return "Unable to create a SFSpeechAudioBufferRecognitionRequest object"
        case .notSupported:
            return "Speech recognition is not supported for your current locale."
        case .unavailable:
            return "Speech recognition is not currently available. Check back at a later time."
        case .notRecognized:
            return "The speech is not recognized"
        }
    }
}

extension Locale {
    static var UK: Locale {
        Locale.init(identifier: "en-UK")
    }

    static var US: Locale {
        Locale.init(identifier: "en-US")
    }
}

