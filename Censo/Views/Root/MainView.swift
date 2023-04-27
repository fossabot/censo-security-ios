//
//  MainView.swift
//  Censo
//
//  Created by Ata Namvari on 2021-03-10.
//

import Foundation
import SwiftUI

struct MainView: View {
    @Environment(\.censoApi) var censoApi

    @RemoteResult private var user: CensoApi.User?

    @StateObject private var registrationController: DeviceRegistrationController

    init(registrationController: @autoclosure @escaping () -> DeviceRegistrationController) {
        _registrationController = StateObject(wrappedValue: registrationController())
    }

    var body: some View {
        switch $user {
        case .idle:
            ProgressView()
                .onAppear(perform: reloadUser)
        case .loading:
            ProgressView()
        case .failure(let error):
            RetryView(error: error, action: reloadUser)
        case .success(let user):
            switch (registrationController.state, user.shardingPolicy) {
            case (.needsToRegister(let deviceKey), .some(let shardingPolicy)):
                DeviceKeyRegistration(user: user, deviceKey: deviceKey, onSuccess: reloadUser) {
                    switch user.registeredPublicKeys {
                    case _ where !user.canAddSigners:
                        WaitingForDeviceApproval(onReload: reloadUser)
                    case .none:
                        KeyGeneration(
                            user: user,
                            shardingPolicy: shardingPolicy,
                            deviceKey: deviceKey,
                            registrationController: registrationController,
                            onConflict: reloadUser,
                            onSuccess: reloadUser
                        )
                    case .complete,
                         .incomplete:
                        KeyRetrieval(user: user, registeredPublicKeys: user.publicKeys, deviceKey: deviceKey, registrationController: registrationController) {
                            reloadUser()
                        }
                    }
                }
            case (.needsToRegister(let deviceKey), .none):
                BootstrapKeyGeneration(email: user.loginName) {
                    ProgressView()
                } content: { bootstrapKey in
                    PhotoCapture(deviceKey: deviceKey) { uiImage, retakeClosure in
                        BootstrapPhotoSubmission(
                            email: user.loginName,
                            uiImage: uiImage,
                            deviceKey: deviceKey,
                            bootstrapKey: bootstrapKey,
                            registrationController: registrationController,
                            onSuccess: reloadUser,
                            onRetake: retakeClosure
                        )
                    }
                }
            case (.registered(let registeredDevice), .some(let shardingPolicy)):
                switch user.registeredPublicKeys {
                case .incomplete:
                    AdditionalKeyRegistration(user: user, registeredDevice: registeredDevice, shardingPolicy: shardingPolicy) {
                        reloadUser()
                    }
                case .complete(let remotePublicKeys) where registeredDevice.publicKeys == remotePublicKeys:
                    ApprovalRequestsView(
                        registeredDevice: registeredDevice,
                        user: user
                    )
                    .navigationTitle("Approvals")
                case .complete:
                    Text("Keys do not match, call support")
                case .none:
                    Text("Should not have come here")
                }
            case (.registered, .none):
                Text("Expected a sharding policy. Please call support") // should never happen
            }
        }
    }

    private func reloadUser() {
        switch registrationController.state {
        case .needsToRegister(let deviceKey):
            _user.reload(using: censoApi.provider.loader(for: .verifyUser(devicePublicKey: try? deviceKey.publicExternalRepresentation().base58String)))
        case .registered(let registeredDevice):
            _user.reload(using: censoApi.provider.loader(for: .verifyUser(devicePublicKey: try? registeredDevice.deviceKey.publicExternalRepresentation().base58String)))
        }
    }
}
