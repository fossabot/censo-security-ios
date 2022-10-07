//
//  RegistrationView.swift
//  Strike
//
//  Created by Ata Namvari on 2021-04-01.
//

import Foundation
import SwiftUI

struct RegistrationView: View {
    @Environment(\.strikeApi) var strikeApi

    @State private var storedPublicKeys: PublicKeys?

    var user: StrikeApi.User
    var onReloadUser: () -> Void
    var onProfile: () -> Void

    init(user: StrikeApi.User, onReloadUser: @escaping () -> Void, onProfile: @escaping () -> Void) {
        self.user = user
        self.onReloadUser = onReloadUser
        self.onProfile = onProfile
        Keychain.migrateIfNeeded(for: user.loginName)
        self._storedPublicKeys = State(initialValue: Keychain.publicKeys(email: user.loginName))
    }

    var body: some View {
        switch (storedPublicKeys, user.registeredPublicKeys) {
        case (_, .none):
            KeyGeneration(user: user, onSuccess: onReloadUser, onProfile: onProfile)
        case (.none, .some(let remotePublicKeys)):
            KeyRetrieval(user: user, publicKeys: remotePublicKeys) {
                storedPublicKeys = Keychain.publicKeys(email: user.loginName)
            } onProfile: {
                onProfile()
            }
        case (.some(let storedPublicKeys), .some(let remotePublicKeys)) where storedPublicKeys == remotePublicKeys:
            ApprovalRequestsView(user: user)
                .navigationTitle("Approvals")
        case (.some(let storedKeys), .some(let remoteKeys)):
            // check if we need to register the bitcoin key
            if storedKeys.bitcoin != nil && remoteKeys.bitcoin == nil {
                AdditionalKeyRegistration(
                    user: user,
                    keyToRegister: StrikeApi.WalletSigner(publicKey: storedKeys.bitcoin!, walletType: WalletType.Bitcoin, signature: nil)) {
                    onReloadUser()
                }
            } else {
                Text("Keys do not match, call support")
            }
        }
    }
}

#if DEBUG
struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView(user: .sample, onReloadUser: { }, onProfile: {})
    }
}
#endif
