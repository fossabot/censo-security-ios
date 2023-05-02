//
//  EvmTransactionUtil.swift
//  Censo
//
//  Created by Brendan Flood on 1/31/23.
//

import Foundation

enum Operation {
    case delegatecall
    case call
    
    var value: UInt8 {
        switch self {
        case .delegatecall:
            return 1
        case .call:
            return 0
        }
    }
}

enum EvmConfigError: Error, Equatable {
    case invalidWhitelist(String)
    case invalidPolicy(String)
    case missingVault
    case missingChain
    case missingContractAddresses
}

public class EvmTransactionUtil {
    
    static let sentinelAddress = "0000000000000000000000000000000000000001"
    
    class func getEthereumAddressFromBase58(base58Key: String) -> String {
        return "0x" + Crypto.sha3keccak256(data: Data(Base58.decode(base58Key)).dropFirst(1)).suffix(20).toHexString()
    }
    
    class func getEthereumAddress(publicKey: Data) -> String {
        return "0x" + Crypto.sha3keccak256(data: publicKey).suffix(20).toHexString()
    }
    
    class func toChecksumAddress(_ address: String) -> String {
        let rawAddress = address.starts(with: "0x") ? String(address.dropFirst(2)) : address
        let hash = Crypto.sha3keccak256(data: rawAddress.data(using: .ascii)!).toHexString()
        
        return "0x" + zip(rawAddress, hash)
            .map { a, h -> String in
                switch (a, h) {
                case ("0", _), ("1", _), ("2", _), ("3", _), ("4", _), ("5", _), ("6", _), ("7", _), ("8", _), ("9", _):
                    return String(a)
                case (_, "8"), (_, "9"), (_, "a"), (_, "b"), (_, "c"), (_, "d"), (_, "e"), (_, "f"):
                    return String(a).uppercased()
                default:
                    return String(a).lowercased()
                }
            }
            .joined()
    }
    
    
    class func normalizeAddress(_ address: String) -> Data {
        var txData = Data(capacity: 20)
        appendPadded(destination: &txData, source: address.data(using: .hexadecimal)!.suffix(20), padTo: 20)
        return txData
    }
    
    class func uInt64ToBytes(from: UInt64) -> [UInt8] {
        var bigEndian = from.bigEndian
        let bytePtr = withUnsafePointer(to: &bigEndian) {
            $0.withMemoryRebound(to: UInt8.self, capacity: 8) {
                UnsafeBufferPointer(start: $0, count: 8)
            }
        }
        return [UInt8](bytePtr)
    }
    
    class func appendPadded(destination: inout Data, source: Data, padTo: Int = 32) {
        assert(source.count <= padTo)
        destination.append(Data.init(count: padTo - source.count))
        destination.append(source)
    }
    
    class func domainHash(chainId: UInt64, verifyingContract: String) -> Data {
        var domainData = Data(capacity: 32*3)
        // eip712 type hash
        domainData.append(contentsOf: Crypto.sha3keccak256(data: "EIP712Domain(uint256 chainId,address verifyingContract)".data(using: .utf8)!))

        // chain id
        appendPadded(destination: &domainData, source: Data(uInt64ToBytes(from: chainId)))

        // verifying contract
        appendPadded(destination: &domainData, source: verifyingContract.data(using: .hexadecimal)!)

        return Crypto.sha3keccak256(data: domainData)
    }
    
    class func computeSafeTransactionHash(
        chainId: UInt64, safeAddress: String, to: String, value: Bignum, data: Data, operation: Operation = .call, nonce: UInt64
    ) -> Data {
        
        var safeTransaction = Data()
        safeTransaction.append(contentsOf: [0x19, 0x1])
        safeTransaction.append(domainHash(chainId: chainId, verifyingContract: safeAddress))
        
        var messageData = Data(capacity: 32*11)
        messageData.append(contentsOf: Crypto.sha3keccak256(data: "SafeTx(address to,uint256 value,bytes data,uint8 operation,uint256 safeTxGas,uint256 baseGas,uint256 gasPrice,address gasToken,address refundReceiver,uint256 nonce)".data(using: .utf8)!))

        // destination address
        appendPadded(destination: &messageData, source: to.data(using: .hexadecimal)!)

        // value
        appendPadded(destination: &messageData, source: value.data)

        // data
        appendPadded(destination: &messageData, source: Crypto.sha3keccak256(data: data))

        // operation
        appendPadded(destination: &messageData, source: Data([operation.value]))
        
        // safeTxGas
        messageData.append(Data.init(count: 32))
        
        // baseGas
        messageData.append(Data.init(count: 32))

        // gasPrice
        messageData.append(Data.init(count: 32))

        // gasToken
        appendPadded(destination: &messageData, source: "0x0000000000000000000000000000000000000000".data(using: .hexadecimal)!)

        // refundReceiver
        appendPadded(destination: &messageData, source: "0x0000000000000000000000000000000000000000".data(using: .hexadecimal)!)

        // nonce
        appendPadded(destination: &messageData, source: Data(uInt64ToBytes(from: nonce)))

        safeTransaction.append(Crypto.sha3keccak256(data: messageData))
        
        return Crypto.sha3keccak256(data: safeTransaction)
    }
}
