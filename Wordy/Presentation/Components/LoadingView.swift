//
//  LoadingView.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/3/1.
//

import SwiftUI

struct LoadingView: View {
    private let title: String?

    init(title: String? = nil) {
        self.title = title
    }

    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(2)
                .padding()
            if let title = title {
                Text(title)
            } 
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
        LoadingView(title: "Loading CET4")
        LoadingView(title: "Loading IELTS").preferredColorScheme(.dark)
    }
}
