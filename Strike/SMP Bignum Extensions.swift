//
//  SMP Bignum Extensions.swift
//  BigInteger
//
//    This module contains convenience extensions for SMP that are
//    largely compatible with the (OpenSSL-based) Bignum Swift module.
//

import Foundation

/// Bignum compatibility alias for BInt
public typealias Bignum = BInt


public extension Bignum
{
    /// Representation as Data
    public var data: Data {
        let n = limbs.count
        var data = Data(count: n * 8)
        data.withUnsafeMutableBytes { (ptr: UnsafeMutablePointer<UInt8>) -> Void in
            var p = ptr
            for i in (0..<n).reversed() {
                for j in (0..<8).reversed() {
                    p.pointee = UInt8((limbs[i] >> UInt64(j*8)) & 0xff)
                    p += 1
                }
            }
        }
        return data
    }

    /// Decimal string representation
    public var dec: String { return description }


    ///
    /// Initialise a BInt from a hexadecimal string
    ///
    /// - Parameter hex: the hexadecimal string to convert to a big integer
    public init(hex: String) {
        self.init(number: hex.lowercased(), withBase: 16)
    }

    /// Initialise from an unsigned, 64 bit integer
    ///
    /// - Parameter n: the 64 bit unsigned integer to convert to a BInt
    public init(_ n: UInt64) {
        self.init(limbs: [n])
    }

    /// Initialise from big-endian data
    ///
    /// - Parameter data: the data to convert to a Bignum
    public init(data: Data) {
        let n = data.count
        guard n > 0 else {
            self.init(0)
            return
        }
        let m = (n + 7) / 8
        var limbs = Limbs(repeating: 0, count: m)
        data.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) -> Void in
            var p = ptr
            let r = n % 8
            let k = r == 0 ? 8 : r
            for j in (0..<k).reversed() {
                limbs[m-1] += UInt64(p.pointee) << UInt64(j*8)
                p += 1
            }
            guard m > 1 else { return }
            for i in (0..<(m-1)).reversed() {
                for j in (0..<8).reversed() {
                    limbs[i] += UInt64(p.pointee) << UInt64(j*8)
                    p += 1
                }
            }
        }
        self.init(limbs: limbs)
    }
}

