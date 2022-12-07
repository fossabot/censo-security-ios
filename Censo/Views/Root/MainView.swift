//
//  MainView.swift
//  Censo
//
//  Created by Ata Namvari on 2021-03-10.
//

import Foundation
import SwiftUI

struct MainView: View {
    var email: String
    var onSignOut: () -> Void

    var body: some View {
        DeviceRegistration(email: email) {
            ProgressView()
        } content: { deviceKey in
            UserVerification(deviceKey: deviceKey, onSignOut: onSignOut)
        }
    }
}

struct UserVerification: View {
    @Environment(\.censoApi) var censoApi

    @RemoteResult private var user: CensoApi.User?

    var deviceKey: DeviceKey
    var onSignOut: () -> Void

    var body: some View {
        switch $user {
        case .idle:
            SignedInNavigationView(onSignOut: onSignOut) { _ in
                ProgressView()
                    .onAppear(perform: reload)
            }
        case .loading:
            SignedInNavigationView(onSignOut: onSignOut) { _ in
                ProgressView()
            }
        case .failure(let error):
            SignedInNavigationView(onSignOut: onSignOut) { _ in
                RetryView(error: error, action: reload)
            }
        case .success(let user):
            // TODO: Do we really need this onProfile stuff?
            SignedInNavigationView(user: user, onSignOut: onSignOut) { onProfile in
                DeviceKeyRegistration(user: user, deviceKey: deviceKey) {
                    reload()
                } content: {
                    PublicKeysStorage(email: user.loginName, deviceKey: deviceKey) {
                        ProgressView()
                    } success: { keyStore, reloadPublicKeys in
                        RegistrationView(
                            user: user,
                            deviceKey: deviceKey,
                            keyStore: keyStore,
                            onReloadUser: reload,
                            onProfile: onProfile,
                            onReloadPublicKeys: reloadPublicKeys
                        )
                    }
                }
            }
        }
    }

    func reload() {
        _user.reload(using: censoApi.provider.loader(for: .verifyUser(devicePublicKey: try? deviceKey.publicExternalRepresentation().base58String)))
    }
}
