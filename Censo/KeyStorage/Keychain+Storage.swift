//
//  Keychain+Storage.swift
//  Censo
//
//  Created by Ata Namvari on 2022-10-31.
//

import Foundation

extension JSONDecoder {
    fileprivate static let keyChainDecoder = JSONDecoder()
}

extension JSONEncoder {
    fileprivate static let keyChainEncoder = JSONEncoder()
}

extension Keychain {
    static private let rootSeedService = "com.censocustody.root-seed-encrypted"
    static private let publicKeyService = "com.censocustody.public-key"

    enum KeyError: Error {
        case noPrivateKeys
    }

    static func privateKeys(email: String, deviceKey: DeviceKey) throws -> PrivateKeys {
        guard let encryptedRootSeed = try load(account: email, service: rootSeedService) else {
            throw KeyError.noPrivateKeys
        }

        let rootSeed = try deviceKey.decrypt(data: encryptedRootSeed).bytes

        return try PrivateKeys(rootSeed: rootSeed)
    }

    static func encryptedRootSeed(email: String) throws -> Data? {
        try load(account: email, service: rootSeedService)
    }

    static func publicKeys(email: String, deviceKey: DeviceKey) throws -> PublicKeys? {
        let email = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // BEGIN MIGRATION

        let oldRootSeedService = "com.censocustody.root-seed-biometry"
        if contains(account: email, service: oldRootSeedService) {
            if let rootSeed = try load(account: email, service: oldRootSeedService) {
                try saveRootSeed(rootSeed.bytes, email: email, deviceKey: deviceKey)
                clear(account: email, service: oldRootSeedService)
            }
        }

        // END MIGRATION

        // IF ALL KEYS ARE PRESENT
        if let publicKeysData = try load(account: email, service: publicKeyService),
           let publicKeys = try? JSONDecoder.keyChainDecoder.decode(PublicKeys.self, from: publicKeysData) {
            return publicKeys
        }

        guard let encryptedRootSeed = try load(account: email, service: rootSeedService) else {
            return nil
        }

        let rootSeed = try deviceKey.decrypt(data: encryptedRootSeed).bytes
        let privateKeys = try PrivateKeys(rootSeed: rootSeed)

        if let publicKeysData = try? JSONEncoder.keyChainEncoder.encode(privateKeys.publicKeys) {
            try save(account: email, service: publicKeyService, data: publicKeysData)
        }

        return privateKeys.publicKeys
    }

    static func saveRootSeed(_ rootSeed: [UInt8], email: String, deviceKey: DeviceKey) throws {
        let email = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let encryptedData = try deviceKey.encrypt(data: Data(rootSeed))

        try save(account: email, service: rootSeedService, data: encryptedData, biometryProtected: false)

        let privateKeys = try PrivateKeys(rootSeed: rootSeed)
        let publicKeys = privateKeys.publicKeys

        if let publicKeysData = try? JSONEncoder.keyChainEncoder.encode(publicKeys) {
            try save(account: email, service: publicKeyService, data: publicKeysData)
        }
    }
}

struct StoredKeys: Codable {
    var encryptedRootSeed: Data
    var publicKeys: PublicKeys
}
