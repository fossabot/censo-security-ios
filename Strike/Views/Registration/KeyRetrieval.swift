//
//  KeyRetrieval.swift
//  Strike
//
//  Created by Ata Namvari on 2022-03-02.
//

import Foundation
import SwiftUI

struct KeyRetrieval: View {
    @Environment(\.strikeApi) var strikeApi

    @RemoteResult private var walletSigners: [StrikeApi.WalletSigner]?

    var user: StrikeApi.User
    var onReloadUser: () -> Void

    var body: some View {
        switch $walletSigners {
        case .idle:
            ProgressView()
                .onAppear(perform: reload)
        case .loading:
            ProgressView()
        case .failure(let error):
            RetryView(error: error, action: reload)
        case .success(let walletSigners) where !walletSigners.isEmpty:
            ProgressView()
                .onAppear {
                    do {
                        try Keychain.savePrivateKey(walletSigners.first!.encryptedKey, email: user.loginName)
                        onReloadUser()
                    } catch {
                        _walletSigners.content = .failure(error)
                    }
                }
        case .success:
            ProgressView()
                .onAppear {
                    onReloadUser()
                }
        }
    }

    private func reload() {
        _walletSigners.reload(
            using: strikeApi.provider.loader(
                for: .walletSigners
            )
        )
    }
}
