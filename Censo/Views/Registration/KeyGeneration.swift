//
//  KeyGeneration.swift
//  Censo
//
//  Created by Ata Namvari on 2022-03-02.
//

import Foundation
import SwiftUI
import BIP39

struct KeyGeneration: View {
    @State private var phrase = Mnemonic(strength: 256).phrase

    var user: CensoApi.User
    var onSuccess: () -> Void
    var onProfile: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            ProfileButton(action: onProfile)

            KeyConfirmationSuccess(user: user, phrase: phrase, onSuccess: onSuccess)
        }
        .navigationBarHidden(true)
    }
}

#if DEBUG
struct KeyGeneration_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            KeyGeneration(user: .sample, onSuccess: {}, onProfile: {})
        }
    }
}
#endif
