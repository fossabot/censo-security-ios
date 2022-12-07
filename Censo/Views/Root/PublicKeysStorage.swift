//
//  PublicKeysStorage.swift
//  Censo
//
//  Created by Ata Namvari on 2022-11-02.
//

import SwiftUI

typealias KeyStore = (publicKeys: PublicKeys, encryptedRootSeed: Data)

struct PublicKeysStorage<Loading, Success>: View where Loading : View, Success : View {
    enum Storage {
        case idle
        case loading
        case failure(Error)
        case success(KeyStore?)
    }

    @State private var storage: Storage = .idle

    var email: String
    var deviceKey: DeviceKey

    @ViewBuilder var loading: () -> Loading
    @ViewBuilder var success: (KeyStore?, @escaping () -> Void) -> Success

    var body: some View {
        switch storage {
        case .idle:
            loading()
                .onAppear(perform: reload)
        case .loading:
            loading()
        case .failure(let error):
            RetryView(error: error, action: reload)
        case .success(let keyStore):
            success(keyStore, reload)
        }
    }

    private func reload() {
        storage = .loading

        do {
            if let publicKeys = try Keychain.publicKeys(email: email, deviceKey: deviceKey),
               let encryptedRootSeed = try Keychain.encryptedRootSeed(email: email) {
                storage = .success((publicKeys, encryptedRootSeed))
            } else {
                storage = .success(nil)
            }
        } catch {
            storage = .failure(error)
        }
    }
}
