//
//  EthereumSignable.swift
//  Censo
//
//  Created by Ata Namvari on 2023-01-19.
//

import Foundation

protocol EthereumSignable {
    var account: AccountInfo { get }
    var signingData: EthereumSigningData { get }

    func messageHash() throws -> Data
    func signableData() throws -> Data
}

extension EthereumSignable {
    func signableData() throws -> Data {
        var safeTransaction = Data()
        safeTransaction.append(contentsOf: [0x19, 0x1])
        safeTransaction.append(domainHash(chainId: signingData.transaction.chainId, verifyingContract: account.address))
        safeTransaction.append(try messageHash())
        return Crypto.sha3keccak256(data: safeTransaction)
    }

    private func uInt64ToBytes(from: UInt64) -> [UInt8] {
        var bigEndian = from.bigEndian
        let bytePtr = withUnsafePointer(to: &bigEndian) {
            $0.withMemoryRebound(to: UInt8.self, capacity: 8) {
                UnsafeBufferPointer(start: $0, count: 8)
            }
        }
        return [UInt8](bytePtr)
    }

    private func appendPadded(destination: inout Data, source: Data, padTo: Int = 32) {
        assert(source.count <= padTo)
        destination.append(Data.init(count: padTo - source.count))
        destination.append(source)
    }

    public func domainHash(chainId: UInt64, verifyingContract: String) -> Data {
        var domainData = Data(capacity: 32*3)
        // eip712 type hash
        domainData.append(contentsOf: Crypto.sha3keccak256(data: "EIP712Domain(uint256 chainId,address verifyingContract)".data(using: .utf8)!))

        // chain id
        appendPadded(destination: &domainData, source: Data(uInt64ToBytes(from: chainId)))

        // verifying contract
        appendPadded(destination: &domainData, source: verifyingContract.data(using: .hexadecimal)!)

        return Crypto.sha3keccak256(data: domainData)
    }

    public func erc20WithdrawalTx(destinationAddress: String, amount: Bignum) -> Data {
        var txData = Data(capacity: 4 + 32*2)
        // transfer(address,uint256)
        txData.append("a9059cbb".data(using: .hexadecimal)!)
        // to
        appendPadded(destination: &txData, source: destinationAddress.data(using: .hexadecimal)!)
        // amount
        appendPadded(destination: &txData, source: amount.data)

        return txData
    }

    public func erc721WithdrawalTx(walletAddress: String, destinationAddress: String, tokenId: Bignum) -> Data {
        var txData = Data(capacity: 4 + 32*3)
        // safeTransferFrom(address,address,uint256)
        txData.append("42842e0e".data(using: .hexadecimal)!)
        // from
        appendPadded(destination: &txData, source: walletAddress.data(using: .hexadecimal)!)
        // to
        appendPadded(destination: &txData, source: destinationAddress.data(using: .hexadecimal)!)
        // tokenId
        appendPadded(destination: &txData, source: tokenId.data)

        return txData
    }

    public func erc1155WithdrawalTx(walletAddress: String, destinationAddress: String, tokenId: Bignum, amount: Bignum) -> Data {
        var txData = Data(capacity: 4 + 32*6)
        // safeTransferFrom(address,address,uint256,uint256,bytes)
        txData.append("f242432a".data(using: .hexadecimal)!)
        // from
        appendPadded(destination: &txData, source: walletAddress.data(using: .hexadecimal)!)
        // to
        appendPadded(destination: &txData, source: destinationAddress.data(using: .hexadecimal)!)
        // tokenId
        appendPadded(destination: &txData, source: tokenId.data)
        // amount
        appendPadded(destination: &txData, source: amount.data)
        // dynamic data
        appendPadded(destination: &txData, source: Bignum(160).data)
        // length
        appendPadded(destination: &txData, source: Bignum(0).data)

        return txData
    }

    public func withdrawalMessageHash(destinationAddress: String, amount: Bignum, data: Data, nonce: UInt64) -> Data {
        var messageData = Data(capacity: 32*11)
        // eip712 type hash
        messageData.append(contentsOf: Crypto.sha3keccak256(data: "SafeTx(address to,uint256 value,bytes data,uint8 operation,uint256 safeTxGas,uint256 baseGas,uint256 gasPrice,address gasToken,address refundReceiver,uint256 nonce)".data(using: .utf8)!))

        // destination address
        appendPadded(destination: &messageData, source: destinationAddress.data(using: .hexadecimal)!)

        // value
        appendPadded(destination: &messageData, source: amount.data)

        // data
        appendPadded(destination: &messageData, source: Crypto.sha3keccak256(data: data))

        // operation
        let operation: UInt8 = 0
        appendPadded(destination: &messageData, source: Data([operation]))

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

        return Crypto.sha3keccak256(data: messageData)
    }
}

extension EthereumWithdrawalRequest: EthereumSignable {
    func messageHash() throws -> Data {
        if let tokenInfo = tokenInfo {
            return withdrawalMessageHash(
                destinationAddress: tokenInfo.tokenMintAddress,
                amount: Bignum(0),
                data: try {
                    switch tokenInfo.tokenType {
                    case .erc721(let tokenId):
                        return erc721WithdrawalTx(
                            walletAddress: account.address,
                            destinationAddress: destination.address,
                            tokenId: Bignum(number: tokenId, withBase: 10)
                        )
                    case .erc1155(let tokenId):
                        return erc1155WithdrawalTx(
                            walletAddress: account.address,
                            destinationAddress: destination.address,
                            tokenId: Bignum(number: tokenId, withBase: 10),
                            amount: try symbolAndAmountInfo.fundamentalAmountBignum
                        )
                    case .erc20:
                        return erc20WithdrawalTx(
                            destinationAddress: destination.address,
                            amount: try symbolAndAmountInfo.fundamentalAmountBignum
                        )
                    }
                }(),
                nonce: signingData.transaction.safeNonce
            )
        } else {
            return withdrawalMessageHash(
                destinationAddress: destination.address,
                amount: try symbolAndAmountInfo.fundamentalAmountBignum,
                data: Data(count: 0),
                nonce: signingData.transaction.safeNonce
            )
        }
    }
}

extension SymbolAndAmountInfo {
    enum AmountError: Error {
        case invalidDecimal
    }

    var fundamentalAmount: UInt64 {
        get throws {
            guard let decimal = Decimal(string: amount) else { throw AmountError.invalidDecimal }

            if symbolInfo.symbol == "SOL" {
                return NSDecimalNumber(decimal: decimal * 1_000_000_000).uint64Value
            } else {
                let precisionParts = amount.components(separatedBy: ".")
                let decimals = precisionParts.count == 1 ? 0 : precisionParts[1].count

                return NSDecimalNumber(decimal: decimal * pow(10, decimals)).uint64Value
            }
        }
    }

    var fundamentalAmountBignum: Bignum {
        get throws {
            if nativeAmount != nil && !nativeAmount!.starts(with: amount) {
                throw AmountError.invalidDecimal
            }
            return Bignum(number: (nativeAmount ?? amount).replacingOccurrences(of: ".", with: ""), withBase: 10)
        }
    }
}

extension EthereumWalletNameUpdate: EthereumSignable {
    func messageHash() throws -> Data {
        Data()
    }
}

extension EthereumWalletWhitelistUpdate: EthereumSignable {
    func messageHash() throws -> Data {
        Data()
    }
}

extension EthereumDAppTransactionRequest: EthereumSignable {
    func messageHash() throws -> Data {
        Data()
    }
}

extension EthereumTransferPolicyUpdate: EthereumSignable {
    func messageHash() throws -> Data {
        Data()
    }
}

extension EthereumWalletSettingsUpdate: EthereumSignable {
    func messageHash() throws -> Data {
        Data()
    }
}
