//
//  TagList.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/2/27.
//

import SwiftUI

struct TagList: View {
    @Environment(\.injected) private var injected: DIContainer

    var body: some View {
        NavigationView {
            List(WordTag.allCases) { tag in
                NavigationLink(tag.displayName) {
                    WordList(tag: tag).environment(\.injected, injected)
                }
            }
        }
    }
}

struct TagList_Previews: PreviewProvider {
    static var previews: some View {
        TagList()
        TagList().preferredColorScheme(.dark)
    }
}
