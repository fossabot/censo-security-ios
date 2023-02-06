//
//  EthereumSigning.swift
//  Strike
//
//  Created by Benjamin Holzman on 11/23/22.
//


class EvmTransferTransactionBuilder {
    
    static func erc20WithdrawalTx(destinationAddress: String, amount: Bignum) -> Data {
        var txData = Data(capacity: 4 + 32*2)
        // transfer(address,uint256)
        txData.append("a9059cbb".data(using: .hexadecimal)!)
        // to
        EvmTransactionUtil.appendPadded(destination: &txData, source: destinationAddress.data(using: .hexadecimal)!)
        // amount
        EvmTransactionUtil.appendPadded(destination: &txData, source: amount.data)
        
        return txData
    }
    
    static func erc721WithdrawalTx(walletAddress: String, destinationAddress: String, tokenId: Bignum) -> Data {
        var txData = Data(capacity: 4 + 32*3)
        // safeTransferFrom(address,address,uint256)
        txData.append("42842e0e".data(using: .hexadecimal)!)
        // from
        EvmTransactionUtil.appendPadded(destination: &txData, source: walletAddress.data(using: .hexadecimal)!)
        // to
        EvmTransactionUtil.appendPadded(destination: &txData, source: destinationAddress.data(using: .hexadecimal)!)
        // tokenId
        EvmTransactionUtil.appendPadded(destination: &txData, source: tokenId.data)
        
        return txData
    }
    
    static func erc1155WithdrawalTx(walletAddress: String, destinationAddress: String, tokenId: Bignum, amount: Bignum) -> Data {
        var txData = Data(capacity: 4 + 32*6)
        // safeTransferFrom(address,address,uint256,uint256,bytes)
        txData.append("f242432a".data(using: .hexadecimal)!)
        // from
        EvmTransactionUtil.appendPadded(destination: &txData, source: walletAddress.data(using: .hexadecimal)!)
        // to
        EvmTransactionUtil.appendPadded(destination: &txData, source: destinationAddress.data(using: .hexadecimal)!)
        // tokenId
        EvmTransactionUtil.appendPadded(destination: &txData, source: tokenId.data)
        // amount
        EvmTransactionUtil.appendPadded(destination: &txData, source: amount.data)
        // dynamic data
        EvmTransactionUtil.appendPadded(destination: &txData, source: Bignum(160).data)
        // length
        EvmTransactionUtil.appendPadded(destination: &txData, source: Bignum(0).data)
        
        return txData
    }
    
    // for compatibility
    static func withdrawalMessageHash(chainId: UInt64, walletAddress: String, destinationAddress: String, amount: Bignum, data: Data, nonce: UInt64) -> Data {
        return EvmTransactionUtil.computeSafeTransactionHash(
            chainId: chainId,
            safeAddress: walletAddress,
            to: destinationAddress,
            value: amount,
            data: data,
            operation: .call,
            nonce: nonce
        )
    }
    
    // use after refactor
    static func withdrawalSafeHash(evmTokenInfo: EvmTokenInfo?,
                                   amount: Amount,
                                   walletAddress: String,
                                   destinationAddress: String,
                                   evmTransaction: EvmTransaction) throws -> Data {
        var safeTransaction = Data()
        if evmTokenInfo == nil {
            safeTransaction.append(
                try EvmTransactionUtil.computeSafeTransactionHash(
                    chainId: evmTransaction.chainId,
                    safeAddress: walletAddress,
                    to: destinationAddress,
                    value: amount.fundamentalAmountBignum,
                    data: Data(count: 0),
                    nonce: evmTransaction.safeNonce
                )
            )
        } else {
            let (data, contractAddress) = try {
                switch evmTokenInfo! {
                case .erc721(let contractAddress, let tokenId):
                    return (EvmTransferTransactionBuilder.erc721WithdrawalTx(
                        walletAddress: walletAddress,
                        destinationAddress: destinationAddress,
                        tokenId: Bignum(number: tokenId, withBase: 10)
                    ), contractAddress)
                case .erc1155(let contractAddress, let tokenId):
                    return (try EvmTransferTransactionBuilder.erc1155WithdrawalTx(
                        walletAddress: walletAddress,
                        destinationAddress: destinationAddress,
                        tokenId: Bignum(number: tokenId, withBase: 10),
                        amount: amount.fundamentalAmountBignum
                    ), contractAddress)
                case .erc20(let contractAddress):
                    return (try EvmTransferTransactionBuilder.erc20WithdrawalTx(
                        destinationAddress: destinationAddress,
                        amount: amount.fundamentalAmountBignum
                    ), contractAddress)
                }
            }()
            safeTransaction.append(
                EvmTransactionUtil.computeSafeTransactionHash(
                    chainId: evmTransaction.chainId,
                    safeAddress: walletAddress,
                    to: contractAddress,
                    value: Bignum(0),
                    data: data,
                    nonce: evmTransaction.safeNonce
                )
            )
        }
        return safeTransaction
    }
    
}
