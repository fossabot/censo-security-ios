//
//  PrivateKeys.swift
//  Censo
//
//  Created by Ata Namvari on 2022-10-31.
//

import Foundation
import CryptoKit

struct PrivateKeys {
    fileprivate let solanaPublicKey: String
    fileprivate let bitcoinPublicKey: String
    fileprivate let ethereumPublicKey: String

    fileprivate let solanaSignature: (Data) throws -> String
    fileprivate let bitcoinSignature: (Data, DerivationNode?) throws -> String
    fileprivate let ethereumSignature: (Data) throws -> String
}

extension PrivateKeys {
    var publicKeys: PublicKeys {
        PublicKeys(
            solana: solanaPublicKey,
            bitcoin: bitcoinPublicKey,
            ethereum: ethereumPublicKey
        )
    }
}

extension PrivateKeys {
    init(rootSeed: [UInt8]) throws {
        let solanaPrivateKey = try Ed25519HierachicalPrivateKey.fromRootSeed(rootSeed: rootSeed).privateKey
        let bitcoinPrivateKey = try Secp256k1HierarchicalKey.fromRootSeed(rootSeed: rootSeed, derivationPath: Secp256k1HierarchicalKey.bitcoinDerivationPath)
        let ethereumPrivateKey = try Secp256k1HierarchicalKey.fromRootSeed(rootSeed: rootSeed, derivationPath: Secp256k1HierarchicalKey.ethereumDerivationPath)

        try solanaPrivateKey.verify()
        try bitcoinPrivateKey.verify()
        try ethereumPrivateKey.verify()

        self.solanaPublicKey = solanaPrivateKey.base58EncodedPublicKey
        self.bitcoinPublicKey = bitcoinPrivateKey.getBase58ExtendedPublicKey()
        self.ethereumPublicKey = ethereumPrivateKey.getBase58UncompressedPublicKey()

        self.solanaSignature = {
            let signature = try solanaPrivateKey.signature(for: $0)

            if solanaPrivateKey.publicKey.isValidSignature(signature, for: $0) {
                return signature.base64EncodedString()
            } else {
                throw PrivateKeyError.badKey
            }
        }

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
    }

    func publicKey(for chain: Chain) -> String {
        switch chain {
        case .solana:
            return solanaPublicKey
        case .bitcoin:
            return bitcoinPublicKey
        case .ethereum:
            return ethereumPublicKey
        }
    }

    func signature(for data: Data, chain: Chain, derivationPath: DerivationNode? = nil) throws -> String {
        switch chain {
        case .solana:
            return try solanaSignature(data)
        case .bitcoin:
            return try bitcoinSignature(data, derivationPath)
        case .ethereum:
            return try ethereumSignature(data)
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
