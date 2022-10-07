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


struct PrivateKeys: Codable {
    var solana: Curve25519.Signing.PrivateKey
    var bitcoin: Secp256k1HierarchicalKey?
    
    init(solana: Curve25519.Signing.PrivateKey, bitcoin: Secp256k1HierarchicalKey?) {
        self.solana = solana
        self.bitcoin = bitcoin
    }
    
    enum CodingKeys: String, CodingKey {
        case solana
        case bitcoin
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let solanaKey = try container.decode(String.self, forKey: .solana)
        let bitcoinExtendedKey = try container.decode(String?.self, forKey: .bitcoin)
        self = PrivateKeys(
            solana: try Curve25519.Signing.PrivateKey.init(rawRepresentation: Base58.decode(solanaKey)),
            bitcoin: bitcoinExtendedKey != nil ? try Secp256k1HierarchicalKey.fromBase58ExtendedKey(extendedKey: bitcoinExtendedKey!) : nil
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode( Base58.encode([UInt8](solana.rawRepresentation)), forKey: .solana)
        try container.encode( bitcoin?.getBase58ExtendedPrivateKey(), forKey: .bitcoin)
    }
}

extension PrivateKeys {
    var bytes: Data {
        get throws {
            return try JSONEncoder().encode(self)
        }
    }
}

extension PrivateKeys {
    var publicKeys: PublicKeys {
        get throws {
            PublicKeys(
                solana: Base58.encode([UInt8](solana.publicKey.rawRepresentation)),
                bitcoin: bitcoin?.getBase58ExtendedPublicKey()
            )
        }
    }
}

extension PrivateKeys {
    static func fromRootSeed(rootSeed: [UInt8]) throws -> PrivateKeys {
        return PrivateKeys(
            solana: try Ed25519HierachicalPrivateKey.fromRootSeed(rootSeed: rootSeed).privateKey,
            bitcoin: try Secp256k1HierarchicalKey.fromRootSeed(rootSeed: rootSeed, derivationPath: Secp256k1HierarchicalKey.bitcoinDerivationPath)
        )
    }
}

extension Curve25519.Signing.PrivateKey {
    var encodedPublicKey: String {
        return Base58.encode(self.publicKey.rawRepresentation.bytes)
    }
}

struct PublicKeys: Codable, Equatable {
    var solana: String
    var bitcoin: String?
}

extension PublicKeys {
    var bytes: Data {
        get throws {
            return try JSONEncoder().encode(self)
        }
    }
}

extension Data {
    var privateKeys: PrivateKeys {
        get throws {
            return try JSONDecoder().decode(PrivateKeys.self, from: self)
        }
    }
}

extension Data {
    var publicKeys: PublicKeys {
        get throws {
            return try JSONDecoder().decode(PublicKeys.self, from: self)
        }
    }
}



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

        return status == errSecInteractionNotAllowed || status == noErr
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

    struct KeyPair {
        let encryptedPrivateKey: String
        let publicKey: String
    }

    static func publicKeys(email: String) -> PublicKeys? {
        let email = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // RETIRE THIS BLOCK AND REMOVE PRODUCTION FLAG
        #if !PRODUCTION
        let passphraseService = "com.strikeprotocols.private-pass"

        if load(account: email, service: passphraseService, synced: true) != nil {
            clear(account: email, service: passphraseService, synced: true)
            clear(account: email, service: privateKeyService)
        }
        #endif

        if let publicKeyData = load(account: email, service: publicKeyService), hasPrivateKey(email: email) {
            return try? publicKeyData.publicKeys
        }

        guard let privateKeys = privateKeys(for: email) else {
            return nil
        }

        if let publicKeys = try? privateKeys.publicKeys {
            if let publicKeysBytes = try? publicKeys.bytes {
                save(account: email, service: publicKeyService, data: publicKeysBytes)
                return publicKeys
            }
        }

        return nil
    }

    static func saveRootSeed(_ rootSeed: [UInt8], email: String) throws {
        let email = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        if !save(account: email, service: rootSeedService, data: Data(rootSeed), biometryProtected: true) {
            throw KeyError.couldNotSavePrivateKey
        }
    }
    
    static func savePrivateKeys(_ privateKeys: PrivateKeys, email: String) throws {
        let email = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        if !save(account: email, service: privateKeyService, data: try privateKeys.bytes, biometryProtected: true) {
            throw KeyError.couldNotSavePrivateKey
        }

        save(account: email, service: publicKeyService, data: try privateKeys.publicKeys.bytes)
    }

    static func privateKeys(for account: String) -> PrivateKeys? {
        if let privateKeyData = load(account: account, service: privateKeyService) {
            return try? privateKeyData.privateKeys
        } else if let rootSeedData = load(account: account, service: rootSeedService) {
            if let solanaKey = try? Ed25519HierachicalPrivateKey.fromRootSeed(rootSeed: rootSeedData.bytes).privateKey {
                return PrivateKeys(
                    solana: solanaKey,
                    bitcoin: try? .fromRootSeed(rootSeed: rootSeedData.bytes, derivationPath: Secp256k1HierarchicalKey.bitcoinDerivationPath)
                )
            }
        }
        return nil
    }
    
    static func rootSeed(for account: String) -> Data? {
        return load(account: account, service: rootSeedService)
    }

    static func hasPrivateKey(email: String) -> Bool {
        contains(account: email, service: privateKeyService)
    }

    static private let schemaService = "com.strikeprotocols.schema"
    static private let schemaVersion1 = "20221004"
    static private let schemaVersion2 = "20221008"

    static func migrateIfNeeded(for account: String) {
        let schemaVersionData = load(account: account, service: schemaService)
        let schemaVersion = schemaVersionData.flatMap { String(data: $0, encoding: .utf8) }

        switch(schemaVersion) {
        case nil:
            
            // handle really old users whose keys were not behind biometry
            let oldPrivateKeyService = "com.strikeprotocols.private-key"
            let oldRootSeedService = "com.strikeprotocols.root-seed"
            
            if let oldPrivateKeyData = load(account: account, service: oldPrivateKeyService) {
                if let oldPrivateKey = try? Curve25519.Signing.PrivateKey(rawRepresentation: oldPrivateKeyData),
                   let oldRootSeed = load(account: account, service: oldRootSeedService)  {
                    do {
                        try saveRootSeed(oldRootSeed.bytes, email: account)
                        save(account: account, service: privateKeyService, data: oldPrivateKey.rawRepresentation, biometryProtected: false)
                        clear(account: account, service: oldRootSeedService)
                        clear(account: account, service: oldPrivateKeyService)
                    } catch {
                        RaygunClient.sharedInstance().send(error: error, tags: ["key-migration"], customData: nil)
                    }
                }
            }
            save(account: account, service: schemaService, data: schemaVersion1.data(using: .utf8)!)
            fallthrough
            
        case schemaVersion1:
            if let rootSeedData = load(account: account, service: rootSeedService) {
                save(account: account, service: rootSeedService, data: rootSeedData, synced: false, biometryProtected: true)
                
                // we are migrating from just storing a solana private key to storing a json structure with all the keys.
                // as part of this we will also create their bitcoin key and store it. This will cause the Registration View
                // to see a delta between what is stored and what backend has, so it triggers registration of the
                // bitcoin key
                //
                // also in order to save a face id - instead of reading the existing private key, we will regenerate all the keys
                // from the root seed and store them in the new structure if they previously stored a private key
                if contains(account: account, service: privateKeyService) {
                    do {
                        try Keychain.savePrivateKeys(
                            try PrivateKeys(
                               solana: Ed25519HierachicalPrivateKey.fromRootSeed(rootSeed: rootSeedData.bytes).privateKey,
                               bitcoin: try Secp256k1HierarchicalKey.fromRootSeed(rootSeed: rootSeedData.bytes, derivationPath: Secp256k1HierarchicalKey.bitcoinDerivationPath)
                            ),
                            email: account
                        )
                    } catch {
                        RaygunClient.sharedInstance().send(error: error, tags: ["key-migration"], customData: nil)
                    }
                }
            }
            save(account: account, service: schemaService, data: schemaVersion2.data(using: .utf8)!)
            fallthrough
            
        default:
            break
        }
    }
}

extension Keychain {
    static func keyInfoForEmail(email: String) throws -> PrivateKeys {
        guard let privateKeys = privateKeys(for: email) else {
            throw KeyError.noPrivateKey
        }

        return privateKeys
    }
}
