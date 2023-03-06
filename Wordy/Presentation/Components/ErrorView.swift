//
//  ErrorView.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/3/1.
//

import SwiftUI

struct ErrorView: View {
    private let error: Error
    private let retryAction: () -> Void

    init(error: Error, retryAction: @escaping () -> Void) {
        self.error = error
        self.retryAction = retryAction
    }

    var body: some View {
        VStack {
            Text("An Error Occured").font(.title)
            Text(error.localizedDescription)
                .font(.callout)
                .multilineTextAlignment(.center)
                .padding([.top, .bottom])
            Button(action: retryAction) {
                Text("Retry").bold()
            }
        }
        .padding()
    }
}

let testError = NSError(domain: "domain", code: 0, userInfo: [NSLocalizedDescriptionKey: "This is a very long error description This is a very long error description This is a very long error description"])

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(error: testError, retryAction: {})
        ErrorView(error: testError, retryAction: {}).preferredColorScheme(.dark)
    }
}
