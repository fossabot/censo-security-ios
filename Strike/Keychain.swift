//
//  Keychain.swift
//  Strike
//
//  Created by Ata Namvari on 2022-03-01.
//

import Foundation
import Security
import LocalAuthentication
import CryptoKit
import BIP39

public class Keychain {
    private class func queryDictionary(account: String, service: String) -> [String : Any] {
        return [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrAccount as String : account,
            kSecAttrService as String : service
        ]
    }

    @discardableResult
    public class func save(account: String, service: String, data: Data, synced: Bool = false, biometryProtected: Bool = false) -> Bool {
        var query = queryDictionary(account: account, service: service)
        query[kSecValueData as String] = data

        if synced {
            query[kSecAttrSynchronizable as String] = true
        }

        SecItemDelete(query as CFDictionary)

        if biometryProtected {
            query[kSecAttrAccessControl as String] = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, [.biometryCurrentSet], nil)
        }

        let result = SecItemAdd(query as CFDictionary, nil)
        return result == noErr
    }

    public class func load(account: String, service: String, synced: Bool = false, biometryPrompt: String? = nil) -> Data? {
        var query = queryDictionary(account: account, service: service)
        query[kSecReturnData as String] = kCFBooleanTrue!
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecAttrSynchronizable as String] = synced

        if let prompt = biometryPrompt {
            let context = LAContext()
            context.localizedReason = prompt

            query[kSecUseAuthenticationContext as String] = context
            query[kSecAttrAccessControl as String] = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenUnlockedThisDeviceOnly, [.biometryCurrentSet], nil)
        }

        var foundData: AnyObject? = nil
        let status = SecItemCopyMatching(query as CFDictionary, &foundData)

        if status == noErr {
            return foundData as! Data?
        }
        else {
            return nil
        }
    }

    @discardableResult
    public class func clear(account: String, service: String, synced: Bool = false) -> Bool {
        var query = queryDictionary(account: account, service: service)

        if synced {
            query[kSecAttrSynchronizable as String] = true
        }

        let result = SecItemDelete(query as CFDictionary)
        return result == noErr
    }

    public class func contains(account: String, service: String) -> Bool {
        var query = queryDictionary(account: account, service: service)

        let context = LAContext()
        context.interactionNotAllowed = true

        query[kSecUseAuthenticationContext as String] = context

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        return status == errSecInteractionNotAllowed
    }
}

extension Keychain {
    enum KeyError: Error {
        case couldNotDecode
        case couldNotSavePrivateKey
        case noPrivateKey
    }

    static private let privateKeyService = "com.strikeprotocols.private-key-biometry"
    static private let rootSeedService = "com.strikeprotocols.root-seed-biometry"
    static private let publicKeyService = "com.strikeprotocols.public-key"
    static private let bitcoinPrivateKeyService = "com.strikeprotocols.bitcoin-private-key-biometry"

    struct KeyPair {
        let encryptedPrivateKey: String
        let publicKey: String
    }

    static func publicKey(email: String) -> String? {
        let email = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // RETIRE THIS BLOCK AND REMOVE PRODUCTION FLAG
        #if !PRODUCTION
        let passphraseService = "com.strikeprotocols.private-pass"

        if load(account: email, service: passphraseService, synced: true) != nil {
            clear(account: email, service: passphraseService, synced: true)
            clear(account: email, service: privateKeyService)
        }
        #endif

        // MIGRATION FOR OLD USERS
        let oldPrivateKeyService = "com.strikeprotocols.private-key"
        let oldRootSeedService = "com.strikeprotocols.root-seed"

        if let oldPrivateKeyData = load(account: email, service: oldPrivateKeyService) {
            if let oldPrivateKey = try? Curve25519.Signing.PrivateKey(rawRepresentation: oldPrivateKeyData),
               let oldRootSeed = load(account: email, service: oldRootSeedService)  {
                do {
                    try savePrivateKey(oldPrivateKey, rootSeed: oldRootSeed.bytes, email: email)
                } catch {
                    RaygunClient.sharedInstance().send(error: error, tags: ["key-migration"], customData: nil)
                    return Base58.encode(oldPrivateKey.publicKey.rawRepresentation.bytes)
                }
            }
        }

        if let publicKeyData = load(account: email, service: publicKeyService), hasPrivateKey(email: email) {
            return Base58.encode(publicKeyData.bytes)
        }

        guard let privateKey = privateKey(for: email) else {
            return nil
        }

        let publicKeyData = privateKey.publicKey.rawRepresentation

        save(account: email, service: publicKeyService, data: publicKeyData)

        return Base58.encode(publicKeyData.bytes)
    }

    static func savePrivateKey(_ privateKey: Curve25519.Signing.PrivateKey, rootSeed: [UInt8], email: String) throws {
        let email = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        if !save(account: email, service: rootSeedService, data: Data(rootSeed), biometryProtected: true) {
            throw KeyError.couldNotSavePrivateKey
        }

        if !save(account: email, service: privateKeyService, data: privateKey.rawRepresentation, biometryProtected: true) {
            throw KeyError.couldNotSavePrivateKey
        }

        save(account: email, service: publicKeyService, data: privateKey.publicKey.rawRepresentation)
    }

    static func privateKey(for account: String) -> Curve25519.Signing.PrivateKey? {
        if let privateKeyData = load(account: account, service: privateKeyService) {
            return try? Curve25519.Signing.PrivateKey(rawRepresentation: privateKeyData)
        } else if let rootSeedData = load(account: account, service: rootSeedService) {
            return try? Ed25519HierachicalPrivateKey.fromRootSeed(rootSeed: rootSeedData.bytes).privateKey
        } else {
            return nil
        }
    }
    
    static func bitcoinPrivateKey(for account: String, childKeyIndex: UInt32) -> Secp256k1HierarchicalKey? {
        if let privateKeyData = load(account: account, service: bitcoinPrivateKeyService) {
            return try? Secp256k1HierarchicalKey
                .fromBase58ExtendedKey(extendedKey: privateKeyData.base58String)
                .derived(at: DerivationNode.notHardened(childKeyIndex))
        } else {
            return nil
        }
    }

    static func hasPrivateKey(email: String) -> Bool {
        contains(account: email, service: privateKeyService)
    }

    static private let schemaService = "com.strikeprotocols.schema"
    static private let latestSchemaVersion = "20221004"

    static func migrateIfNeeded(for account: String) {
        let schemaVersionData = load(account: account, service: schemaService)
        let schemeVersion = schemaVersionData.flatMap { String(data: $0, encoding: .utf8) }

        if schemeVersion != latestSchemaVersion {
            if let privateKeyData = load(account: account, service: privateKeyService) {
                save(account: account, service: privateKeyService, data: privateKeyData, synced: false, biometryProtected: true)
            }

            if let rootSeedData = load(account: account, service: rootSeedService) {
                save(account: account, service: rootSeedService, data: rootSeedData, synced: false, biometryProtected: true)
            }

            save(account: account, service: schemaService, data: latestSchemaVersion.data(using: .utf8)!)
        }
    }
    
    static func hasBitcoinPrivateKey(email: String) -> Bool {
        contains(account: email, service: bitcoinPrivateKeyService)
    }
}

extension Keychain {
    static func keyInfoForEmail(email: String) throws -> (privateKey: Curve25519.Signing.PrivateKey, encodedPublicKey: String) {
        guard let privateKey = privateKey(for: email) else {
            throw KeyError.noPrivateKey
        }

        let publicKeyData = privateKey.publicKey.rawRepresentation
        let encodedPublicKey = Base58.encode(publicKeyData.bytes)
        return (privateKey, encodedPublicKey)
    }
}
