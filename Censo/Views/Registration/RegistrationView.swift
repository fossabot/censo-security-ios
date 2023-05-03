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
    var shardingPolicy: ShardingPolicy
    var registeredDevice: RegisteredDevice
    var registrationController: DeviceRegistrationController
    var onReloadUser: () -> Void
    var onReloadPublicKeys: () -> Void

    var body: some View {
//        switch user.registeredPublicKeys {
////        case (_, .none):
////            KeyGeneration(
////                user: user,
////                shardingPolicy: shardingPolicy,
////                deviceKey: registeredDevice.deviceKey,
////                registrationController: registrationController,
////                onConflict: onReloadUser,
////                onSuccess: onReloadUser
////            )
////        case (.none, .complete):
////            KeyRetrieval(user: user, registeredPublicKeys: user.publicKeys, deviceKey: registeredDevice.deviceKey, registrationController: registrationController) {
////                onReloadPublicKeys()
////            }
////        case (.none, .incomplete(let publicKeys)):
////            KeyRetrieval(user: user, registeredPublicKeys: publicKeys, deviceKey: registeredDevice.deviceKey, registrationController: registrationController) {
////                onReloadPublicKeys()
////            }
//        case .incomplete:
//            AdditionalKeyRegistration(user: user, registeredDevice: registeredDevice, shardingPolicy: shardingPolicy) {
//                onReloadUser()
//            }
//        case .complete(let remotePublicKeys) where registeredDevice.publicKeys == remotePublicKeys:
//            ApprovalRequestsView(
//                registeredDevice: registeredDevice,
//                user: user
//            )
//            .navigationTitle("Approvals")
//        case .complete:
            Text("Keys do not match, call support")
//        }
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
//struct RegistrationView_Previews: PreviewProvider {
//    static var previews: some View {
//        RegistrationView(user: .sample, shardingPolicy: .sample, deviceKey: .sample, keyStore: nil, onReloadUser: { }, onReloadPublicKeys: {})
//    }
//}
#endif
