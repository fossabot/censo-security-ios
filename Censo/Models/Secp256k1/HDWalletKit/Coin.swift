//
//  Coin.swift
//  HDWalletKit
//
//  Created by Pavlo Boiko on 10/3/18.
//  Copyright © 2018 Essentia. All rights reserved.
//

import Foundation

public enum Coin {
    case bitcoin
    case ethereum
    
    //https://github.com/satoshilabs/slips/blob/master/slip-0132.md
    public var privateKeyVersion: UInt32 {
        switch self {
        case .bitcoin:
            return 0x0488ADE4
        default:
            fatalError("Not implemented")
        }
    }
    // P2PKH
    public var publicKeyHash: UInt8 {
        switch self {
        case .bitcoin:
            return 0x00
        default:
            fatalError("Not implemented")
        }
    }
    
    // P2SH
    public var scriptHash: UInt8 {
        switch self {
        case .bitcoin:
            return 0x05
        default:
            fatalError("Not implemented")
        }
    }
    
    
    public var addressPrefix:String {
        switch self {
        case .ethereum:
            return "0x"
        default:
            return ""
        }
    }
    
    public var uncompressedPkSuffix: UInt8 {
        return 0x01
    }
    
    
    public var coinType: UInt32 {
        switch self {
        case .bitcoin:
            return 0
        case .ethereum:
            return 60
        }
    }
    
    public var scheme: String {
        switch self {
        case .bitcoin:
            return "bitcoin"
        default: return ""
        }
    }
}
