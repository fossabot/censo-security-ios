//
//  DeviceKeyRegistration.swift
//  Censo
//
//  Created by Ata Namvari on 2023-02-02.
//

import SwiftUI

struct DeviceKeyRegistration<Content>: View where Content : View {
    enum Storage {
        case publicKeyNotLoaded
        case failedToLoadPublicKey(Error)
        case success(Data)
    }

    @Environment(\.censoApi) var censoApi

    @State private var storage: Storage = .publicKeyNotLoaded

    var user: CensoApi.User
    var deviceKey: DeviceKey
    var onSuccess: () -> Void
    @ViewBuilder var content: () -> Content

    var body: some View {
        switch storage {
        case .publicKeyNotLoaded:
            ProgressView()
                .onAppear {
                    loadPublicKey()
                }
        case .success(let data) where data.base58String != user.deviceKey:
            PhotoCapture(deviceKey: deviceKey) {
                onSuccess()
            }
        case .success:
            content()
        case .failedToLoadPublicKey(let error):
            RetryView(error: error) {
                loadPublicKey()
            }
        }
    }

    func loadPublicKey() {
        do {
            self.storage = .success(try deviceKey.publicExternalRepresentation())
        } catch {
            self.storage = .failedToLoadPublicKey(error)
        }
    }
}
