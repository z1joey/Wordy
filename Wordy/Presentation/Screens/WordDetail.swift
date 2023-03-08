//
//  WordDetail.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/3/1.
//

import SwiftUI

struct WordDetail: View {
    @Binding var word: Word?

    var body: some View {
        VStack(alignment: .leading) {
            if let text = word?.word {
                Text(text)
            }
            Button("Press to dismiss") {
                word = nil
            }
        }
    }
}

struct WordDetail_Previews: PreviewProvider {
    static var previews: some View {
        WordDetail(word: .constant(.mockedWord))
        WordDetail(word: .constant(.mockedWord)).preferredColorScheme(.dark)
    }
}
