//
//  WordChange.swift
//
//  Created by Joey Zhang on 2023/2/21.
//

import Foundation

public struct WordChange {
    public let type: ChangeType
    public let change: String

    init?(raw: String) {
        guard raw.count > 2 else { return nil }

        let start = raw.index(raw.startIndex, offsetBy: 2)
        let end = raw.index(raw.endIndex, offsetBy: 0)
        let range = start..<end

        let prefix = String(raw.prefix(2))
        let change = String(raw[range])

        if let type = ChangeType(prefix: prefix) {
            self.type = type
            self.change = change
        } else {
            return nil
        }
    }

    public enum ChangeType {
        case did
        case done
        case doing
        case does
        case er
        case est
        case s
        //        case lemma0
        //        case lemma1

        private var prefix: String {
            switch self {
            case .did:
                return "p:"
            case .done:
                return "d:"
            case .doing:
                return "i:"
            case .does:
                return "3:"
            case .er:
                return "r:"
            case .est:
                return "t:"
            case .s:
                return "s:"
                //            case .lemma0:
                //                return "0:"
                //            case .lemma1:
                //                return "1:"
            }
        }

        public var displayName: String {
            switch self {
            case .did:
                return "过去式"
            case .done:
                return "过去分词"
            case .doing:
                return "现在分词"
            case .does:
                return "第三人称单数"
            case .er:
                return "形容词比较级"
            case .est:
                return "形容词最高级"
            case .s:
                return "名词复数形式"
                //            case .lemma0:
                //                return "Lemma"
                //            case .lemma1:
                //                return "Lemma"
            }
        }

        init?(prefix: String) {
            switch prefix {
            case "p:": self = .did
            case "d:": self = .done
            case "i:": self = .doing
            case "3:": self = .does
            case "r:": self = .er
            case "t:": self = .est
            case "s:": self = .s
                //            case "0:": self = .lemma0
                //            case "1:": self = .lemma1
            default:
                return nil
            }
        }
    }
}
