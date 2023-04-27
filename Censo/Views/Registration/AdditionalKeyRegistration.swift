//
//  AdditionalKeyRegistration.swift
//  Censo
//
//  Created by Brendan Flood on 10/6/22.
//

import Foundation
import SwiftUI
import LocalAuthentication

struct AdditionalKeyRegistration: View {
    @Environment(\.censoApi) var censoApi

    @RemoteResult private var signers: CensoApi.SignersInfo?

    var user: CensoApi.User
    var registeredDevice: RegisteredDevice
    var shardingPolicy: ShardingPolicy
    var onSuccess: () -> Void

    var body: some View {
        Group {
            switch $signers {
            case .idle:
                VStack {
                    Spacer()

                    Text("We need to register some additional keys to continue")
                        .font(.system(size: 26).bold())
                        .padding()

                    Spacer()

                    Button {
                        reload()
                    } label: {
                        Text("Continue")
                            .frame(maxWidth: .infinity)
                    }
                    .padding()

                    Spacer()
                        .frame(height: 20)
                }
            case .loading:
                CensoProgressView(text: "Registering your additional keys with Censo...")
            case .failure(let error):
                RetryView(error: error, action: reload)
            default:
                CensoProgressView(text: "Registering your additional keys with Censo...")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .multilineTextAlignment(.center)
        .buttonStyle(FilledButtonStyle())
        .background(CensoBackground())
    }

    private func reload() {
        let deviceKey = registeredDevice.deviceKey
        let encryptedRootSeed = registeredDevice.encryptedRootSeed

        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Verify your identity") { success, error in
            if let error = error {
                _signers.content = .failure(error)
            } else {
                do {
                    let preauthenticatedKey = try deviceKey.preauthenticatedKey(context: context)
                    let rootSeed = try preauthenticatedKey.encrypt(data: encryptedRootSeed).bytes

                    let signers = try CensoApi.SignersInfo(
                        shardingPolicy: shardingPolicy,
                        rootSeed: rootSeed,
                        deviceKey: preauthenticatedKey
                    )

                    _signers.reload(
                        using: censoApi.provider.loader(
                            for: .addWalletSigners(signers, devicePublicKey: try deviceKey.publicExternalRepresentation().base58String)
                        )
                    ) { error in
                        if error == nil {
                            onSuccess()
                        }
                    }
                } catch {
                    _signers.content = .failure(error)
                }
            }
        }

    }
}

#if DEBUG
//struct AdditionalKeyRegistration_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            AdditionalKeyRegistration(user: .sample, encryptedRootSeed: Data(), deviceKey: .sample, shardingPolicy: .sample, onSuccess: {})
//        }
//    }
//}
#endif
