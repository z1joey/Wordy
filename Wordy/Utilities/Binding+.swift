//
//  Binding+.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/3/7.
//

import SwiftUI
import Combine

extension Binding where Value: Equatable {
    func dispatched<State>(to state: CurrentValueSubject<State, Never>, _ keyPath: WritableKeyPath<State, Value>) -> Self {
        return onSet { state.value[keyPath: keyPath] = $0 }
    }

    private func onSet(_ perform: @escaping (Value) -> Void) -> Self {
        return .init {
            wrappedValue
        } set: { val in
            if self.wrappedValue != val {
                self.wrappedValue = val
            }
            perform(val)
        }
    }
}
