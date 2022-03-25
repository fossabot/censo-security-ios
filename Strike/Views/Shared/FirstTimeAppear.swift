//
//  FirstTimeAppear.swift
//  Strike
//
//  Created by Ata Namvari on 2021-04-21.
//

import SwiftUI

struct FirstTimeAppearModifier: ViewModifier {
    @State private var didExecute = false

    var action: () -> Void

    func body(content: Content) -> some View {
        content.onAppear {
            guard !didExecute else { return }

            action()
            didExecute = true
        }
    }
}

extension View {
    func onFirstTimeAppear(perform action: @escaping () -> Void) -> some View {
        modifier(FirstTimeAppearModifier(action: action))
    }
}
