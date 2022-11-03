//
//  Keychain+Storage.swift
//  Strike
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
    static private let rootSeedService = "com.strikeprotocols.root-seed-biometry"
    static private let publicKeyService = "com.strikeprotocols.public-key"

    enum KeyError: Error {
        case noPrivateKeys
    }

    static func privateKeys(email: String) throws -> PrivateKeys {
        guard let rootSeed = try load(account: email, service: rootSeedService)?.bytes else {
            throw KeyError.noPrivateKeys
        }

        return try PrivateKeys(rootSeed: rootSeed)
    }

    static func publicKeys(email: String) throws -> PublicKeys? {
        let email = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // MIGRATION FOR OLD USERS
        let oldPrivateKeyService = "com.strikeprotocols.private-key"
        let oldRootSeedService = "com.strikeprotocols.root-seed"
        let oldPrivateKeyBiometryService = "com.strikeprotocols.private-key-biometry"

        if let oldRootSeed = try load(account: email, service: oldRootSeedService) {
            try saveRootSeed(oldRootSeed.bytes, email: email)
        }

        // CLEAR OLD ENTRIES
        clear(account: email, service: oldPrivateKeyService)
        clear(account: email, service: oldRootSeedService)
        clear(account: email, service: oldPrivateKeyBiometryService)

        // IF ALL KEYS ARE PRESENT
        if let publicKeysData = try load(account: email, service: publicKeyService),
           let publicKeys = try? JSONDecoder.keyChainDecoder.decode(PublicKeys.self, from: publicKeysData),
           hasRootSeed(email: email) {
            return publicKeys
        }

        guard let rootSeed = try load(account: email, service: rootSeedService)?.bytes else {
            return nil
        }

        let privateKeys = try PrivateKeys(rootSeed: rootSeed)

        if let publicKeysData = try? JSONEncoder.keyChainEncoder.encode(privateKeys.publicKeys) {
            try save(account: email, service: publicKeyService, data: publicKeysData)
        }

        return privateKeys.publicKeys
    }

    static func saveRootSeed(_ rootSeed: [UInt8], email: String) throws {
        let email = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        try save(account: email, service: rootSeedService, data: Data(rootSeed), biometryProtected: true)

        let privateKeys = try PrivateKeys(rootSeed: rootSeed)
        let publicKeys = privateKeys.publicKeys

        if let publicKeysData = try? JSONEncoder.keyChainEncoder.encode(publicKeys) {
            try save(account: email, service: publicKeyService, data: publicKeysData)
        }
    }

    static func hasRootSeed(email: String) -> Bool {
        contains(account: email, service: rootSeedService)
    }
}
