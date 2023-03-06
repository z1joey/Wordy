//
//  IdleView.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/3/1.
//

import SwiftUI

struct IdleView: View {
    private var perform: () -> Void

    init(perform: @escaping () -> Void) {
        self.perform = perform
    }

    var body: some View {
        Text("").onAppear(perform: perform)
    }
}

struct NotRequestedView_Previews: PreviewProvider {
    static var previews: some View {
        IdleView(perform: {})
    }
}
