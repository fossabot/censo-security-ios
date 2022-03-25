//
//  KeyGeneration.swift
//  Strike
//
//  Created by Ata Namvari on 2022-03-02.
//

import Foundation
import SwiftUI

struct KeyGeneration: View {
    @Environment(\.strikeApi) var strikeApi

    @RemoteResult private var walletSigner: StrikeApi.WalletSigner?

    var user: StrikeApi.User
    var onSuccess: () -> Void

    var body: some View {
        switch $walletSigner {
        case .idle:
            ProgressView()
                .onAppear(perform: reload)
        case .loading:
            ProgressView()
        case .failure(let error):
            RetryView(error: error, action: reload)
        case .success(let walletSigner):
            ProgressView()
                .onAppear {
                    try? Keychain.savePrivateKey(walletSigner.encryptedKey, email: user.loginName)
                    onSuccess()
                }
        }
    }

    private func reload() {
        do {
            let keyPair = try Keychain.keyPair(email: user.loginName)

            _walletSigner.reload(
                using: strikeApi.provider.loader(
                    for: .addWalletSigner(
                        StrikeApi.WalletSigner(
                            publicKey: keyPair.publicKey,
                            encryptedKey: keyPair.encryptedPrivateKey,
                            walletType: "Solana"
                        )
                    )
                )
            )
        } catch {
            _walletSigner.content = .failure(error)
        }
    }
}
