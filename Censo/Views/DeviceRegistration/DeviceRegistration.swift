//
//  DeviceRegistration.swift
//  Censo
//
//  Created by Ata Namvari on 2023-02-02.
//

import SwiftUI

struct DeviceRegistration<Loading, Success>: View where Loading : View, Success : View {
    enum Storage {
        case failedToCreate(Error)
        case success(DeviceKey?)
        case notLoaded
    }

    @State private var storage: Storage = .notLoaded

    var email: String
    @ViewBuilder var loading: () -> Loading
    @ViewBuilder var content: (DeviceKey) -> Success

    var body: some View {
        switch storage {
        case .notLoaded:
            loading()
                .onAppear {
                    self.storage = .success(SecureEnclaveWrapper.deviceKey(email: email))
                }
        case .success(.none):
            loading()
                .onAppear {
                    generateDeviceKey()
                }
        case .success(.some(let key)):
            content(key)
        case .failedToCreate(let error):
            RetryView(error: error) {
                generateDeviceKey()
            }
        }
    }

    private func generateDeviceKey() {
        do {
            self.storage = .success(try SecureEnclaveWrapper.generateDeviceKey(email: email))
        } catch {
            self.storage = .failedToCreate(error)
        }
    }
}
