//
//  Loadable.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/2/23.
//

import Foundation
import Combine

enum Loadable<T> {
    case notRequested
    case isLoading(last: T?, cancelBag: CancelBag)
    case loaded(T)
    case failed(Error)
    
    var value: T? {
        switch self {
        case let .loaded(val):
            return val
        case let .isLoading(last, _):
            return last
        default:
            return nil
        }
    }
    
    var error: Error? {
        switch self {
        case let .failed(error):
            return error
        default:
            return nil
        }
    }
}

extension Loadable {
    mutating func setIsLoading(cancelBag: CancelBag) {
        self = .isLoading(last: value, cancelBag: cancelBag)
    }

    mutating func cancelLoading() {
        switch self {
        case let .isLoading(last, cancelBag):
            cancelBag.cancel()
            if let last = last {
                self = .loaded(last)
            } else {
                self = .failed(CancelledByUserError())
            }
        default:
            break
        }
    }
}

extension Loadable: Equatable where T: Equatable {
    static func == (lhs: Loadable<T>, rhs: Loadable<T>) -> Bool {
        switch (lhs, rhs) {
        case (.notRequested, .notRequested): return true
        case let (.isLoading(lhsV, _), .isLoading(rhsV, _)): return lhsV == rhsV
        case let (.loaded(lhsV), .loaded(rhsV)): return lhsV == rhsV
        case let (.failed(lhsE), .failed(rhsE)):
            return lhsE.localizedDescription == rhsE.localizedDescription
        default: return false
        }
    }
}

struct CancelledByUserError: Error {
    var localizedDescription: String {
        NSLocalizedString("Canceled by user", comment: "")
    }
}
