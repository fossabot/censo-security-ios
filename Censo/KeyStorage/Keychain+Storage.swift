//
//  Keychain+Storage.swift
//  Censo
//
//  Created by Ata Namvari on 2022-10-31.
//

import Foundation

extension Keychain {
    static private let rootSeedService = "com.censocustody.root-seed-encrypted"
    static private let oldDevicePublicKeyService = "com.censocustody.old-device-public-key"

    static func encryptedRootSeed(email: String) throws -> Data? {
        try load(account: email, service: rootSeedService)
    }

    static func oldDevicePublicKey(identifier: String) throws -> Data? {
        try load(account: identifier, service: oldDevicePublicKeyService)
    }

    static func saveEncryptedRootSeed(_ encryptedRootSeed: Data, email: String) throws {
        let email = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        try save(account: email, service: rootSeedService, data: encryptedRootSeed, biometryProtected: false)
    }

    static func saveOldDevicePublicKey(_ key: Data, identifier: String) throws {
        try save(account: identifier, service: oldDevicePublicKeyService, data: key)
    }

    static func removeOldDevicePublicKey(identifier: String) {
        clear(account: identifier, service: oldDevicePublicKeyService)
    }
}
