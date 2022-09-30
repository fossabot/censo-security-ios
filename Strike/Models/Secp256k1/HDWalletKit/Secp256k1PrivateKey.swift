//
//  PrivateKey.swift
//  HDWalletKit
//
//  Created by Pavlo Boiko on 10/4/18.
//  Copyright © 2018 Essentia. All rights reserved.
//

import Foundation


public struct Secp256k1PrivateKey {
    public let raw: Data
    public let chainCode: Data
    public let index: UInt32
    public let fingerprint: UInt32
    public let depth: UInt8
    
    public init(seed: Data, chainPhrase: String) {
        let output = Crypto.HMACSHA512(key: chainPhrase.data(using: .ascii)!, data: seed)
        self.raw = output[0..<32]
        self.chainCode = output[32..<64]
        self.index = 0
        self.fingerprint = 0
        self.depth = 0
    }
    
    public init?(pk: String) {
        self.raw = Data(hex: pk)
        self.chainCode = Data(capacity: 32)
        self.index = 0
        self.fingerprint = 0
        self.depth = 0
    }
    
    public init(privateKey: Data, chainCode: Data, index: UInt32, fingerprint: UInt32, depth: UInt8) {
        self.raw = privateKey
        self.chainCode = chainCode
        self.index = index
        self.fingerprint = fingerprint
        self.depth = depth
    }
    
    public var publicKey: Secp256k1PublicKey {
        return Secp256k1PublicKey(privateKey: raw)
    }
    
    public func get() -> String {
        return self.raw.toHexString()
    }
    
    public func getPublicKeyBytes() -> Data {
        return Crypto.generatePublicKey(data: raw, compressed: true)
    }
    
    private func getFingerPrint() -> UInt32 {
        return Crypto.generatePublicKey(data: raw, compressed: true).sha256Hash160.prefix(4).uint32
    }
    
    public func derived(at node:DerivationNode) -> Secp256k1PrivateKey {
        let edge: UInt32 = 0x80000000
        guard (edge & node.index) == 0 else { fatalError("Invalid child index") }
        
        var data = Data()
        switch node {
        case .hardened:
            data += UInt8(0)
            data += raw
        case .notHardened:
            data += Crypto.generatePublicKey(data: raw, compressed: true)
        }
        
        let derivingIndex = CFSwapInt32BigToHost(node.hardens ? (edge | node.index) : node.index)
        data += derivingIndex
        
        let digest = Crypto.HMACSHA512(key: chainCode, data: data)
        let factor = BInt(data: digest[0..<32])
        
        let curveOrder = BInt(hex: "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141")
        let derivedPrivateKey = ((BInt(data: raw) + factor) % curveOrder).data
        let derivedChainCode = digest[32..<64]
        return Secp256k1PrivateKey(
            privateKey: derivedPrivateKey,
            chainCode: derivedChainCode,
            index: derivingIndex,
            fingerprint: getFingerPrint(),
            depth: self.depth + 1
        )
    }
    
    public func sign(hash: Data) throws -> Data {
        return try Crypto.sign(hash, privateKey: raw)
    }
    
}

