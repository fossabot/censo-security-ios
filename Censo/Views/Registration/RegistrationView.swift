//
//  RegistrationView.swift
//  Censo
//
//  Created by Ata Namvari on 2021-04-01.
//

import Foundation
import SwiftUI

struct RegistrationView: View {
    @Environment(\.censoApi) var censoApi

    var user: CensoApi.User
    var deviceKey: DeviceKey
    var keyStore: KeyStore?
    var onReloadUser: () -> Void
    var onReloadPublicKeys: () -> Void

    var body: some View {
        switch (keyStore, user.registeredPublicKeys) {
        case (_, .none):
            KeyGeneration(user: user, deviceKey: deviceKey, onSuccess: onReloadUser)
        case (.none, .complete):
            KeyRetrieval(user: user, registeredPublicKeys: user.publicKeys, deviceKey: deviceKey) {
                onReloadPublicKeys()
            }
        case (.none, .incomplete(let publicKeys)):
            KeyRetrieval(user: user, registeredPublicKeys: publicKeys, deviceKey: deviceKey) {
                onReloadPublicKeys()
            }
        case (.some((let storedPublicKeys, _)), .incomplete):
            AdditionalKeyRegistration(user: user, publicKeys: storedPublicKeys, deviceKey: deviceKey) {
                onReloadUser()
            }
        case (.some((let storedPublicKeys, let encryptedRootSeed)), .complete(let remotePublicKeys)) where storedPublicKeys == remotePublicKeys:
            ApprovalRequestsView(
                deviceSigner: DeviceSigner(
                    deviceKey: deviceKey,
                    encryptedRootSeed: encryptedRootSeed
                ),
                user: user
            )
            .navigationTitle("Approvals")
        case (.some, .complete):
            Text("Keys do not match, call support")
        }
    }
}

extension CensoApi.User {
    enum RegisteredPublicKeys {
        case none
        case incomplete([CensoApi.PublicKey])
        case complete(PublicKeys)
    }

    var registeredPublicKeys: RegisteredPublicKeys {
        guard publicKeys.count > 0 else {
            return .none
        }

        guard let bitcoin = publicKeys.first(where: { $0.chain == .bitcoin })?.key,
              let ethereum = publicKeys.first(where: { $0.chain == .ethereum })?.key,
              let censo = publicKeys.first(where: { $0.chain == .offchain })?.key else {
            return .incomplete(publicKeys)
        }

        return .complete(
            PublicKeys(
                bitcoin: bitcoin,
                ethereum: ethereum,
                offchain: censo
            )
        )
    }
}

#if DEBUG
struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView(user: .sample, deviceKey: .sample, keyStore: nil, onReloadUser: { }, onReloadPublicKeys: {})
    }
}
#endif
