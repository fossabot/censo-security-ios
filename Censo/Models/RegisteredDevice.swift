//
//  RegisteredDevice.swift
//  Censo
//
//  Created by Ata Namvari on 2023-04-06.
//

import Foundation

struct RegisteredDevice {
    private(set) var deviceKey: DeviceKey
    private var encryptedRootSeed: Data

    var email: String

    init(email: String, deviceKey: DeviceKey, encryptedRootSeed: Data) {
        self.deviceKey = deviceKey
        self.encryptedRootSeed = encryptedRootSeed
        self.email = email
    }

    var bootstrapKey: BootstrapKey? {
        SecureEnclaveWrapper.bootstrapKey(email: email)
    }

    func deviceSignature(for data: Data) throws -> Data {
        try deviceKey.signature(for: data)
    }

    func privateKeys() throws -> PrivateKeys {
        let rootSeed = try deviceKey.decrypt(data: encryptedRootSeed)
        return try PrivateKeys(rootSeed: rootSeed.bytes)
    }

    func devicePublicKey() throws -> String {
        try deviceKey.publicExternalRepresentation().base58String
    }

    func decrypt(_ data: Data) throws -> Data {
        try deviceKey.decrypt(data: data)
    }

    func removeBootstrapKey() {
        SecureEnclaveWrapper.removeBootstrapKey(email: email)
    }
}
