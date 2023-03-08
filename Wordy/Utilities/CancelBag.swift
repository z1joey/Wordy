//
//  CancelBag.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/2/23.
//

import Foundation
import Combine

final class CancelBag {
    fileprivate(set) var subscribers: Set<AnyCancellable> = []

    func cancel() {
        subscribers.removeAll()
    }

    deinit {
        print("CancelBag Destroyed")
    }
}

extension AnyCancellable {
    func store(in cancelBag: CancelBag) {
        cancelBag.subscribers.insert(self)
    }
}
