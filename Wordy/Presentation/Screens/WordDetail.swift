//
//  WordDetail.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/3/1.
//

import SwiftUI

struct WordDetail: View {
    @Environment(\.dismiss) var dismiss

    private let word: Word

    init(word: Word) {
        self.word = word
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(word.word)
            Button("Press to dismiss") {
                dismiss()
            }
        }
    }
}

struct WordDetail_Previews: PreviewProvider {
    static var previews: some View {
        WordDetail(word: .mockedWord)
        WordDetail(word: .mockedWord).preferredColorScheme(.dark)
    }
}
