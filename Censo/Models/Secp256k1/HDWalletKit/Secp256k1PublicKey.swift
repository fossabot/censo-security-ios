//
//  PublicKey.swift
//  HDWalletKit
//
//  Created by Pavlo Boiko on 10/4/18.
//  Copyright © 2018 Essentia. All rights reserved.
//

import Foundation
import CryptoSwift

public struct Secp256k1PublicKey {
    public let compressedPublicKey: Data
    public let uncompressedPublicKey: Data

    
    public init(privateKey: Data) {
        self.compressedPublicKey = Crypto.generatePublicKey(data: privateKey, compressed: true)
        self.uncompressedPublicKey = Crypto.generatePublicKey(data: privateKey, compressed: false)
    }
    
    public init(base58: Data) {
        let publicKey = Base58.encode([UInt8](base58))
        self.compressedPublicKey = Data(hex: publicKey)
        self.uncompressedPublicKey = Data(hex: publicKey)
    }

    
    public func get() -> String {
        return compressedPublicKey.toHexString()
    }
    
    public var data: Data {
        return Data(hex: get())
    }
}
