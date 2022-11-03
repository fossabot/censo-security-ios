//
//  AdditionalKeyRegistration.swift
//  Strike
//
//  Created by Brendan Flood on 10/6/22.
//

import Foundation
import SwiftUI

struct AdditionalKeyRegistration: View {
    @Environment(\.strikeApi) var strikeApi

    @RemoteResult private var signers: StrikeApi.Signers?

    var user: StrikeApi.User
    var onSuccess: () -> Void

    var body: some View {
        Group {
            switch $signers {
            case .idle:
                StrikeProgressView(text: "Registering your additional keys with Strike...")
                    .onAppear(perform: reload)
            case .failure(let error):
                RetryView(error: error, action: reload)
            default:
                StrikeProgressView(text: "Registering your additional keys with Strike...")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .multilineTextAlignment(.center)
        .buttonStyle(FilledButtonStyle())
        .navigationBarHidden(true)
        .background(StrikeBackground())
    }

    private func reload() {
        do {
            let privateKeys = try Keychain.privateKeys(email: user.loginName)
            let signers = try StrikeApi.Signers(privateKeys: privateKeys)

            _signers.reload(
                using: strikeApi.provider.loader(
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
