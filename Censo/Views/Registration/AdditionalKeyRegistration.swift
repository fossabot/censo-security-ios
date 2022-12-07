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

    @RemoteResult private var signers: CensoApi.AddSignersRequest?

    var user: CensoApi.User
    var publicKeys: PublicKeys
    var deviceKey: DeviceKey
    var onSuccess: () -> Void

    var body: some View {
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
        .navigationBarHidden(true)
        .background(CensoBackground())
    }

    private func reload() {
        do {
            let signers = try CensoApi.AddSignersRequest(publicKeys: publicKeys, deviceKey: deviceKey)

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
            AdditionalKeyRegistration(user: .sample, publicKeys: .init(bitcoin: "", ethereum: "", censo: ""), deviceKey: .sample,
                                      onSuccess: {}
            )
        }
    }
}
#endif
