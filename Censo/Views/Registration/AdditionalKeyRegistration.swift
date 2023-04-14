//
//  AdditionalKeyRegistration.swift
//  Censo
//
//  Created by Brendan Flood on 10/6/22.
//

import Foundation
import SwiftUI

struct AdditionalKeyRegistration: View {
    @Environment(\.censoApi) var censoApi

    @RemoteResult private var signers: CensoApi.SignersInfo?

    var user: CensoApi.User
    var encryptedRootSeed: Data
    var deviceKey: DeviceKey
    var shardingPolicy: ShardingPolicy
    var onSuccess: () -> Void

    var body: some View {
        // Needs another screen for interaction here
        Group {
            switch $signers {
            case .idle:
                CensoProgressView(text: "Registering your additional keys with Censo...")
                    .onAppear(perform: reload)
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
        do {
            let rootSeed = try deviceKey.encrypt(data: encryptedRootSeed).bytes

            let signers = try CensoApi.SignersInfo(
                shardingPolicy: shardingPolicy,
                rootSeed: rootSeed,
                deviceKey: deviceKey
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

#if DEBUG
struct AdditionalKeyRegistration_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AdditionalKeyRegistration(user: .sample, encryptedRootSeed: Data(), deviceKey: .sample, shardingPolicy: .sample, onSuccess: {})
        }
    }
}
#endif
