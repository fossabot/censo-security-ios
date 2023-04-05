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
        DeviceKeyGeneration(email: email) {
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
            ProgressView()
                .onAppear(perform: reload)
        case .loading:
            ProgressView()
        case .failure(let error):
            RetryView(error: error, action: reload)
        case .success(let user):
            if let shardingPolicy = user.shardingPolicy {
                DeviceKeyRegistration(
                    user: user,
                    deviceKey: deviceKey,
                    onSuccess: reload
                ) {
                    PublicKeysStorage(email: user.loginName, deviceKey: deviceKey) {
                        ProgressView()
                    } success: { keyStore, reloadPublicKeys in
                        RegistrationView(
                            user: user,
                            shardingPolicy: shardingPolicy,
                            deviceKey: deviceKey,
                            keyStore: keyStore,
                            onReloadUser: reload,
                            onReloadPublicKeys: reloadPublicKeys
                        )
                    }
                }
            } else {
                BootstrapKeyGeneration(email: user.loginName) {
                    ProgressView()
                } content: { bootstrapKey in
                    PhotoCapture(deviceKey: deviceKey) { uiImage, retakeClosure in
                        BootstrapPhotoSubmission(
                            email: user.loginName,
                            uiImage: uiImage,
                            deviceKey: deviceKey,
                            bootstrapKey: bootstrapKey,
                            onSuccess: reload,
                            onRetake: retakeClosure
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
