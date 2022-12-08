//
//  PublicKeysStorage.swift
//  Censo
//
//  Created by Ata Namvari on 2022-11-02.
//

import SwiftUI

struct PublicKeysStorage<Loading, Success>: View where Loading : View, Success : View {
    enum Storage {
        case idle
        case loading
        case failure(Error)
        case success(PublicKeys?)
    }

    @State private var storage: Storage = .idle

    var email: String

    @ViewBuilder var loading: () -> Loading
    @ViewBuilder var success: (PublicKeys?, @escaping () -> Void) -> Success

    var body: some View {
        switch storage {
        case .idle:
            loading()
                .onAppear(perform: reload)
        case .loading:
            loading()
        case .failure(let error):
            RetryView(error: error, action: reload)
        case .success(let publicKeys):
            success(publicKeys, reload)
        }
    }

    private func reload() {
        storage = .loading

        do {
            let publicKeys = try Keychain.publicKeys(email: email)
            storage = .success(publicKeys)
        } catch {
            storage = .failure(error)
        }
    }
}
