//
//  Store.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/2/27.
//

import SwiftUI
import Combine

typealias Store<State> = CurrentValueSubject<State, Never>
