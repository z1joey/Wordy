//
//  Word.swift
//
//  Created by Joey Zhang on 2023/2/21.
//

import Foundation

public struct Word: Decodable {
    private let tag: String?
    private let definition: String?
    private let collins: String?
    private let oxford: String?
    private let translation: String?
    private let exchange: String?

    let word: String
    let phonetic: String?
    let pos: String?
    let bnc: Int?
    let frq: Int?
    let detail: String?
    let audio: String?

    var tags: [WordTag] {
        var results: [WordTag] = []

        if let tag = tag, !tag.isEmpty {
            let items = tag.components(separatedBy: " ")
            let tags = items.compactMap { WordTag(rawValue: $0) }
            results += tags
        }

        if let collins = collins, let star = Int(collins) {
            results.append(WordTag.collins(stars: star))
        }

        if isOxfordWord {
            results.append(WordTag.oxford)
        }

        return results
    }

    var changes: [WordChange] {
        guard let exchange = exchange, !exchange.isEmpty else {
            return []
        }

        var wordChanges: [WordChange] = []

        let raws = exchange.components(separatedBy: "/")
        raws.forEach { raw in
            if let change = WordChange(raw: raw) {
                wordChanges.append(change)
            }
        }

        return wordChanges
    }

    var definitions: [String] {
        if let definition = definition, !definition.isEmpty {
            return definition.components(separatedBy: "\\n")
        }
        return []
    }

    var translations: [String] {
        if let translation = translation, !translation.isEmpty {
            return translation.components(separatedBy: "\\n")
        }
        return []
    }

    /// Collins dictionary rated word
    var stars: Int? {
        if collins != nil, let int = Int(collins!) {
            return int
        }
        return nil
    }

    var isOxfordWord: Bool {
        return oxford == "1"
    }
}

extension Word {
    static var mockedWord: Word {
        return Word(
            tag: "cet6 ky ielts gre",
            definition: "n. a sharp strain on muscles or ligaments\\nn. a hand tool that is used to hold or twist a nut or bolt\\nv. twist or pull violently or suddenly, especially so as to remove (something) from that to which it is attached or from where it originates\\nv. make a sudden twisting motion",
            collins: "2",
            oxford: nil,
            translation: "n. 扳钳, 扳手, 扭伤, 歪曲, 痛苦\\nvt. 猛扭, 扭伤, 曲解, 折磨\\nvi. 猛扭, 猛绞",
            exchange: "p:wrenched/i:wrenching/d:wrenched/s:wrenches/3:wrenches",
            word: "wrench",
            phonetic: "\'rentʃ",
            pos: nil,
            bnc: 10564,
            frq: 10376,
            detail: nil,
            audio: nil
        )
    }

    static var mockedWordList: [Word] {
        return [mockedWord, mockedWord]
    }
}

extension Word: Identifiable, Equatable {
    public var id: String {
        return word
    }
}
