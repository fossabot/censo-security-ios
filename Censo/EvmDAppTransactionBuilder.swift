//
//  EvmDAppTransactionBuilder.swift
//  Censo
//
//  Created by Ben Holzman on 5/4/23.
//
import Foundation

class EvmDAppTransactionBuilder {
  
    static func ethSendSafeHash(walletAddress: String,
                                ethSendTransaction: EthSendTransaction,
                                evmTransaction: EvmTransaction) throws -> Data {
        var safeTransaction = Data()
        let value = ethSendTransaction.transaction.value.data(using: .hexadecimal)!

        safeTransaction.append(
            EvmTransactionUtil.computeSafeTransactionHash(
                chainId: evmTransaction.chainId,
                safeAddress: walletAddress,
                to: ethSendTransaction.transaction.to,
                value: Bignum(data: value),
                data: Data(hex: ethSendTransaction.transaction.data),
                nonce: evmTransaction.safeNonce
            )
        )
  
        return safeTransaction
    }
    

    static func signMessageHashData(_ messageHash: Data) -> Data {
        // signMessage(bytes), but bytes is always a 32-byte message hash
        var txData = Data(capacity: 4+32*3)
        txData.append("85a5affe".data(using: .hexadecimal)!)
        // this is the offset where bytes starts
        EvmTransactionUtil.appendPadded(destination: &txData, source: Bignum(32).data)
        // followed by 32 bytes with the length of the data
        EvmTransactionUtil.appendPadded(destination: &txData, source: Bignum(32).data)
        // followed by the data
        txData.append(messageHash)
        return txData
    }

    
    static func ethSignSafeHash(walletAddress: String,
                                ethSign: EthSign,
                                evmTransaction: EvmTransaction) throws -> Data {
        var safeTransaction = Data()
        safeTransaction.append(
            EvmTransactionUtil.computeSafeTransactionHash(
                chainId: evmTransaction.chainId,
                safeAddress: walletAddress,
                to: EvmConfigTransactionBuilder.signMessageLibAddress,
                value: Bignum(0),
                data: signMessageHashData(ethSign.messageHash.data(using: .hexadecimal)!),
                operation: .delegatecall,
                nonce: evmTransaction.safeNonce
            )
        )
        return safeTransaction
    }
    
    static func ethSignTypedDataSafeHash(walletAddress: String,
                                         ethSignTypedData: EthSignTypedData,
                                         evmTransaction: EvmTransaction) throws -> Data {
        var safeTransaction = Data()
        safeTransaction.append(
            EvmTransactionUtil.computeSafeTransactionHash(
                chainId: evmTransaction.chainId,
                safeAddress: walletAddress,
                to: EvmConfigTransactionBuilder.signMessageLibAddress,
                value: Bignum(0),
                data: signMessageHashData(ethSignTypedData.messageHash.data(using: .hexadecimal)!),
                operation: .delegatecall,
                nonce: evmTransaction.safeNonce
            )
        )
        return safeTransaction
    }
}
