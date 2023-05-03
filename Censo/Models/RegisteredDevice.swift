//
//  RegisteredDevice.swift
//  Censo
//
//  Created by Ata Namvari on 2023-04-06.
//

import Foundation
import LocalAuthentication

struct RegisteredDevice {
    private(set) var deviceKey: DeviceKey
    var encryptedRootSeed: Data

    private var authenticationContext: LAContext?

    var email: String
    var publicKeys: PublicKeys

    init(email: String, deviceKey: DeviceKey, encryptedRootSeed: Data, publicKeys: PublicKeys) {
        self.deviceKey = deviceKey
        self.encryptedRootSeed = encryptedRootSeed
        self.email = email
        self.publicKeys = publicKeys
    }

    func devicePublicKey() throws -> String {
        try deviceKey.publicExternalRepresentation().base58String
    }
}
