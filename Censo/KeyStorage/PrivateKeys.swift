//
//  PrivateKeys.swift
//  Censo
//
//  Created by Ata Namvari on 2022-10-31.
//

import Foundation
import CryptoKit

struct PrivateKeys {
    fileprivate let bitcoinPublicKey: String
    fileprivate let ethereumPublicKey: String
    fileprivate let censoPublicKey: String

    fileprivate let bitcoinSignature: (Data, DerivationNode?) throws -> String
    fileprivate let ethereumSignature: (Data) throws -> String
    fileprivate let censoSignature: (Data) throws -> String
}

extension PrivateKeys {
    var publicKeys: PublicKeys {
        PublicKeys(
            bitcoin: bitcoinPublicKey,
            ethereum: ethereumPublicKey,
            offchain: censoPublicKey
        )
    }
}

extension PrivateKeys {
    init(rootSeed: [UInt8]) throws {
        let bitcoinPrivateKey = try Secp256k1HierarchicalKey.fromRootSeed(rootSeed: rootSeed, derivationPath: Secp256k1HierarchicalKey.bitcoinDerivationPath)
        let ethereumPrivateKey = try Secp256k1HierarchicalKey.fromRootSeed(rootSeed: rootSeed, derivationPath: Secp256k1HierarchicalKey.ethereumDerivationPath)
        let censoPrivateKey = try Secp256k1HierarchicalKey.fromRootSeed(rootSeed: rootSeed, derivationPath: Secp256k1HierarchicalKey.censoDerivationPath)

        try bitcoinPrivateKey.verify()
        try ethereumPrivateKey.verify()
        try censoPrivateKey.verify()

        self.bitcoinPublicKey = bitcoinPrivateKey.getBase58ExtendedPublicKey()
        self.ethereumPublicKey = ethereumPrivateKey.getBase58UncompressedPublicKey()
        self.censoPublicKey = censoPrivateKey.getBase58UncompressedPublicKey()

        self.bitcoinSignature = {
            if let derivationNode = $1 {
                let derivedKey = bitcoinPrivateKey.derived(at: derivationNode)
                let signature = try derivedKey.signData(message: $0)

                if try derivedKey.verifySignature(signature, message: $0) {
                    return signature.base64EncodedString()
                } else {
                    throw PrivateKeyError.badKey
                }
            } else {
                let signature = try bitcoinPrivateKey.signData(message: $0)

                if try bitcoinPrivateKey.verifySignature(signature, message: $0) {
                    return signature.base64EncodedString()
                } else {
                    throw PrivateKeyError.badKey
                }
            }
        }

        self.ethereumSignature = {
            let signature = try ethereumPrivateKey.signData(message: $0)

            if try ethereumPrivateKey.verifySignature(signature, message: $0) {
                return signature.base64EncodedString()
            } else {
                throw PrivateKeyError.badKey
            }
        }
        
        self.censoSignature = {
            let signature = try censoPrivateKey.signData(message: $0)

            if try censoPrivateKey.verifySignature(signature, message: $0) {
                return signature.base64EncodedString()
            } else {
                throw PrivateKeyError.badKey
            }
        }
    }

    func publicKey(for chain: Chain) -> String {
        switch chain {
        case .bitcoin:
            return bitcoinPublicKey
        case .ethereum, .polygon:
            return ethereumPublicKey
        case .offchain:
            return censoPublicKey
        }
    }

    func signature(for data: Data, chain: Chain, derivationPath: DerivationNode? = nil) throws -> String {
        switch chain {
        case .bitcoin:
            return try bitcoinSignature(data, derivationPath)
        case .ethereum, .polygon:
            return try ethereumSignature(data)
        case .offchain:
            return try censoSignature(data)
        }
    }
}

extension Curve25519.Signing.PrivateKey {
    var base58EncodedPublicKey: String {
        return Base58.encode(self.publicKey.rawRepresentation.bytes)
    }
}

enum PrivateKeyError: Error {
    case badKey
}

extension Curve25519.Signing.PrivateKey {
    fileprivate func verify() throws {
        let data = UUID().uuidString.data(using: .utf8)!
        let signature = try signature(for: data)

        if !publicKey.isValidSignature(signature, for: data) {
            throw PrivateKeyError.badKey
        }
    }
}

extension Secp256k1HierarchicalKey {
    fileprivate func verify() throws {
        let data = UUID().uuidString.data(using: .utf8)!
        let signature = try signData(message: data)

        if try !verifySignature(signature, message: data) {
            throw PrivateKeyError.badKey
        }
    }
}
