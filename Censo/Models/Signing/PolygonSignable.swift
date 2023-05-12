//
//  PolygonSignable.swift
//  Censo
//
//  Created by Brendan Flood on 2/8/23.
//

import Foundation

extension PolygonWithdrawalRequest: EvmSignable {
    func signableData() throws -> Data {
        return try EvmTransferTransactionBuilder.withdrawalSafeHash(
            evmTokenInfo: symbolInfo.tokenInfo,
            amount: amount,
            walletAddress: wallet.address,
            destinationAddress: destination.address,
            evmTransaction: signingData.transaction
        )
    }
}

extension PolygonWalletNameUpdate: EvmSignable {
    func signableData() throws -> Data {
        Data()
    }
}

extension PolygonWalletWhitelistUpdate: EvmSignable {
    func signableData() throws -> Data {
        return try EvmConfigTransactionBuilder.getUpdateWhitelistExecutionFromModuleDataSafeHash(
            walletAddress: wallet.address,
            addsOrRemoves: EvmWhitelistHelper(
                addresses: currentOnChainWhitelist,
                targetDests: destinations.map { EvmDestination(name: $0.name, address: $0.address) }
            ).allChanges().map { $0.data(using: .hexadecimal)! },
            evmTransaction: signingData.transaction
        )
    }
}


extension PolygonDAppRequest: EvmSignable {
    func signableData() throws -> Data {
        switch (dappParams) {
        case .ethSendTransaction(let ethSendTransaction):
            return try EvmDAppTransactionBuilder.ethSendSafeHash(walletAddress: wallet.address, ethSendTransaction: ethSendTransaction, evmTransaction: signingData.transaction)
        case .ethSign(let ethSign):
            return try EvmDAppTransactionBuilder.ethSignSafeHash(walletAddress: wallet.address, ethSign: ethSign, evmTransaction: signingData.transaction)
        case .ethSignTypedData(let ethSignTypedData):
            return try EvmDAppTransactionBuilder.ethSignTypedDataSafeHash(walletAddress: wallet.address, ethSignTypedData: ethSignTypedData, evmTransaction: signingData.transaction)
        default:
            return Data()
        }
    }
}

extension PolygonTransferPolicyUpdate: EvmSignable {
    func signableData() throws -> Data {
        let startingPolicy = try Policy(
            owners: currentOnChainPolicy.owners,
            threshold: currentOnChainPolicy.threshold
        )
        let targetPolicy = try Policy(
            owners: approvalPolicy.approvers.map { EvmTransactionUtil.getEthereumAddressFromBase58(base58Key: $0.publicKey) },
            threshold: approvalPolicy.approvalsRequired
        )
        return try EvmConfigTransactionBuilder.getPolicyUpdateExecutionFromModuleDataSafeHash(
            verifyingContract: signingData.transaction.vaultAddress,
            safeAddress: wallet.address,
            txs: startingPolicy.safeTransactions(targetPolicy).0,
            evmTransaction: signingData.transaction
        )
    }
}

extension PolygonWalletSettingsUpdate: EvmSignable {
    func signableData() throws -> Data {
        
        let evmTransaction = signingData.transaction
        return try EvmConfigTransactionBuilder.getSetGuardExecutionFromModuleDataSafeHash(
            walletAddress: wallet.address,
            guardAddress: EvmWhitelistHelper.getTargetGuardAddress(
                currentGuardAddress: currentGuardAddress,
                whitelistEnabled: {
                    switch change {
                    case .whitelistEnabled(let setting):
                        return setting
                    default:
                        return nil
                    }
                }(),
                dappsEnabled: {
                    switch change {
                    case .dappsEnabled(let setting):
                        return setting
                    default:
                        return nil
                    }
                }(),
                guardAddresses: evmTransaction.contractAddresses
            ) ,
            evmTransaction: evmTransaction
        )
    }
}
