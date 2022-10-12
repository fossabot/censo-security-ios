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
    var keyToRegister: StrikeApi.WalletSigner
    var onSuccess: () -> Void

    var body: some View {
        Group {
            switch $signers {
            case .idle:
                StrikeProgressView(text: "Registering your \(keyToRegister.walletType) key with Strike...")
                    .onAppear(perform: reload)
            case .failure(let error):
                RetryView(error: error, action: reload)
            default:
                StrikeProgressView(text: "Registering your \(keyToRegister.walletType) key with Strike...")
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
            let privateKeys = Keychain.privateKeys(for: user.loginName)
            
            _signers.reload(
                using: strikeApi.provider.loader(
                    for: .addWalletSigners(
                        StrikeApi.Signers(
                            signers: [
                                StrikeApi.WalletSigner(
                                    publicKey: keyToRegister.publicKey,
                                    walletType: keyToRegister.walletType,
                                    signature: try privateKeys?.solana.signature(for: Base58.decode(keyToRegister.publicKey)).base64EncodedString()
                                )
                            ],
                            userImage: nil
                         )
                    )
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
            AdditionalKeyRegistration(user: .sample, keyToRegister: StrikeApi.WalletSigner(publicKey: "", walletType: WalletType.Bitcoin, signature: nil), onSuccess: {})
        }
    }
}
#endif
