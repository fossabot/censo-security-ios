//
//  HelperExtensions.swift
//  Censo
//
//  Created by Ata Namvari on 2023-01-30.
//

import Foundation
import CryptoKit

extension String {
    var base58Bytes: [UInt8] {
        Base58.decode(self)
    }
}

extension String {
    var sha256HashBytes: [UInt8] {
        Data(SHA256.hash(data: Data(utf8))).bytes
    }
}

extension Data {
    var sha256HashBytes: [UInt8] {
        Data(SHA256.hash(data: self)).bytes
    }
}

extension Data {
    var base58String: String {
        Base58.encode(self.bytes)
    }
}

extension UInt64 {
    var convertToSeconds: UInt64 {
        return self / 1000
    }

    var bytes: [UInt8] {
        var littleEndian = self.littleEndian
        return withUnsafeBytes(of: &littleEndian) { Array($0) }
    }
}

extension UInt32 {

    var bytes: [UInt8] {
        var littleEndian = self.littleEndian
        return withUnsafeBytes(of: &littleEndian) { Array($0) }
    }
}

extension UInt16 {

    var bytes: [UInt8] {
        var littleEndian = self.littleEndian
        return withUnsafeBytes(of: &littleEndian) { Array($0) }
    }
}
