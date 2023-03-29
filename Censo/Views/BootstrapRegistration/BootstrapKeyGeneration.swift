//
//  BootstrapRegistration.swift
//  Censo
//
//  Created by Ata Namvari on 2023-03-28.
//

import SwiftUI

struct BootstrapKeyGeneration<Loading, Success>: View where Loading : View, Success : View  {
    enum Storage {
        case failedToCreate(Error)
        case success(BootstrapKey?)
        case notLoaded
    }

    @State private var storage: Storage = .notLoaded

    var email: String
    @ViewBuilder var loading: () -> Loading
    @ViewBuilder var content: (BootstrapKey) -> Success

    var body: some View {
        switch storage {
        case .notLoaded:
            loading()
                .onAppear {
                    self.storage = .success(SecureEnclaveWrapper.bootstrapKey(email: email))
                }
        case .success(.none):
            loading()
                .onAppear {
                    generateBootstrapKey()
                }
        case .success(.some(let key)):
            content(key)
        case .failedToCreate(let error):
            RetryView(error: error) {
                generateBootstrapKey()
            }
        }
    }

    private func generateBootstrapKey() {
        do {
            self.storage = .success(try SecureEnclaveWrapper.generateBootstrapKey(email: email))
        } catch {
            self.storage = .failedToCreate(error)
        }
    }
}
