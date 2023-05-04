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
    
}
