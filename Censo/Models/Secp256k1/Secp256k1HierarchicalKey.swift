//
//  ExtendedSecp256k1PrivateKey.swift
//  Censo
//
//  Created by Brendan Flood on 9/30/22.
//

enum ExtendedKeyError: Error, Equatable {
    case invalidHeader
    case checksum
}

enum ExtendedKeyHeader: UInt32 {
    case bip32HeaderP2PKHpub      = 0x0488b21e
    case bip32HeaderP2PKHpriv     = 0x0488ade4
    case bip32HeaderP2PKHpubTest  = 0x043587cf
    case bip32HeaderP2PKHprivTest = 0x04358394
}


import Foundation

public struct Secp256k1HierarchicalKey {
    let privateKey: Secp256k1PrivateKey
    static let bitcoinDerivationPath = [DerivationNode.hardened(44),
                                        DerivationNode.hardened(0),
                                        DerivationNode.hardened(0),
                                        DerivationNode.notHardened(0)]
    
    static let ethereumDerivationPath = [DerivationNode.hardened(44),
                                         DerivationNode.hardened(60),
                                         DerivationNode.hardened(0),
                                         DerivationNode.notHardened(0)]
    
    static let censoDerivationPath = [DerivationNode.hardened(44),
                                      DerivationNode.hardened(16743510),
                                      DerivationNode.hardened(0),
                                      DerivationNode.notHardened(0)]
    
    
    public init(privateKey: Secp256k1PrivateKey) {
        self.privateKey = privateKey
    }
    
    public func derived(at node: DerivationNode) -> Secp256k1HierarchicalKey {
        return Secp256k1HierarchicalKey(privateKey: self.privateKey.derived(at: node))
    }
    
    public func getBase58ExtendedPublicKey() -> String {
        return getBase58ExtendedKey(isPrivate: false, isMainnet: true)
    }
    
    public func getBase58ExtendedPrivateKey() -> String {
        return getBase58ExtendedKey(isPrivate: true, isMainnet: true)
    }
    
    public func getBase58UncompressedPublicKey() -> String {
        return Base58.encode([UInt8](privateKey.getUncompressedPublicKeyBytes()))
    }
    
    private func getBase58ExtendedKey(isPrivate: Bool, isMainnet: Bool) -> String {
        var data = Data()
        let header = isPrivate
        ? (isMainnet ? ExtendedKeyHeader.bip32HeaderP2PKHpriv : ExtendedKeyHeader.bip32HeaderP2PKHprivTest)
        : (isMainnet ? ExtendedKeyHeader.bip32HeaderP2PKHpub : ExtendedKeyHeader.bip32HeaderP2PKHpubTest)
        data += CFSwapInt32BigToHost(header.rawValue)
        data += self.privateKey.depth
        data += CFSwapInt32BigToHost(self.privateKey.fingerprint)
        data += privateKey.index
        data += self.privateKey.chainCode
        if isPrivate {
            data += UInt8(0)
            data += self.privateKey.raw
        } else {
            data += Crypto.generatePublicKey(data: self.privateKey.raw, compressed: true)
        }
        data += data.checksum
        return Base58.encode([UInt8](data))
    }
    
    public static func fromRootSeed(rootSeed: [UInt8], derivationPath: [DerivationNode]) throws -> Secp256k1HierarchicalKey {
        var derivedKey = Secp256k1PrivateKey(seed: Data(rootSeed), chainPhrase: "Bitcoin seed")

        for index in derivationPath {
            derivedKey = derivedKey.derived(at: index)
        }
        return Secp256k1HierarchicalKey(privateKey: derivedKey)
    }
    
    public static func fromBase58ExtendedKey(extendedKey: String) throws -> Secp256k1HierarchicalKey {
        let data = Base58.decode(extendedKey)
        if data.count != 82 || Data(data[0..<78]).checksum != Data(data[78..<82]) {
            throw ExtendedKeyError.checksum
        }
        let header = Data(data[0..<4]).uint32
        if header != ExtendedKeyHeader.bip32HeaderP2PKHpriv.rawValue &&
            header != ExtendedKeyHeader.bip32HeaderP2PKHprivTest.rawValue {
            throw ExtendedKeyError.invalidHeader
        }
        let depth = data[4]
        let parentFingerPrint = Data(data[5..<9]).uint32
        let derivingIndex = Data(data[9..<13]).uint32
        let chainCode = Data(data[13..<45])
        let privateKey = Data(data[46..<78])
        let pk = Secp256k1PrivateKey(privateKey: privateKey,
                                     chainCode: chainCode,
                                     index: derivingIndex,
                                     fingerprint: parentFingerPrint,
                                     depth: depth)
        return Secp256k1HierarchicalKey(privateKey: pk)
    }
    
    public func signData(message: Data) throws -> Data {
        return try ECDSA.sign(message, privateKey: privateKey.raw)
    }
    
    public func verifySignature(_ sigData: Data, message: Data) throws -> Bool {
        return try ECDSA.secp256k1.verifySignature(sigData, message: message, publicKeyData: privateKey.getPublicKeyBytes())
    }
}
