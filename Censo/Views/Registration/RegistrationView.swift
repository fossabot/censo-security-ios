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
    var storedPublicKeys: PublicKeys?
    var onReloadUser: () -> Void
    var onProfile: () -> Void
    var onReloadPublicKeys: () -> Void

    var body: some View {
        switch (storedPublicKeys, user.registeredPublicKeys) {
        case (_, .none):
            KeyGeneration(user: user, onSuccess: onReloadUser, onProfile: onProfile)
        case (.none, .complete(let remotePublicKeys)):
            KeyRetrieval(user: user, solanaPublicKey: remotePublicKeys.solana) {
                onReloadPublicKeys()
            } onProfile: {
                onProfile()
            }
        case (.none, .incomplete(let solanaPublicKey)):
            KeyRetrieval(user: user, solanaPublicKey: solanaPublicKey) {
                onReloadPublicKeys()
            } onProfile: {
                onProfile()
            }
        case (.some, .incomplete):
            AdditionalKeyRegistration(user: user) {
                onReloadUser()
            }
        case (.some(let storedPublicKeys), .complete(let remotePublicKeys)) where storedPublicKeys == remotePublicKeys:
            ApprovalRequestsView(user: user)
                .navigationTitle("Approvals")
        case (.some, .complete):
            Text("Keys do not match, call support")
        }
    }
}

extension CensoApi.User {
    enum RegisteredPublicKeys {
        case none
        case incomplete(solanaPublicKey: String)
        case complete(PublicKeys)
    }

    var registeredPublicKeys: RegisteredPublicKeys {
        guard let solana = publicKeys.first(where: { $0.chain == .solana })?.key else {
            return .none
        }

        guard let bitcoin = publicKeys.first(where: { $0.chain == .bitcoin })?.key,
              let ethereum = publicKeys.first(where: { $0.chain == .ethereum })?.key,
              let censo = publicKeys.first(where: { $0.chain == .censo })?.key else {
            return .incomplete(solanaPublicKey: solana)
        }

        return .complete(
            PublicKeys(
                solana: solana,
                bitcoin: bitcoin,
                ethereum: ethereum,
                censo: censo
            )
        )
    }
}

#if DEBUG
struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView(user: .sample, storedPublicKeys: nil, onReloadUser: { }, onProfile: {}, onReloadPublicKeys: {})
    }
}
#endif
