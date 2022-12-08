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

    @RemoteResult private var signers: CensoApi.Signers?

    var user: CensoApi.User
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
            let privateKeys = try Keychain.privateKeys(email: user.loginName)
            let signers = try CensoApi.Signers(privateKeys: privateKeys)

            _signers.reload(
                using: censoApi.provider.loader(
                    for: .addWalletSigners(signers)
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
            AdditionalKeyRegistration(user: .sample,
                                      onSuccess: {}
            )
        }
    }
}
#endif
