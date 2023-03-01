//
//  EthereumSignable.swift
//  Censo
//
//  Created by Ata Namvari on 2023-01-19.
//

import Foundation

protocol EvmSignable {
    func signableData() throws -> Data
}

extension EthereumWithdrawalRequest: EvmSignable {
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

extension EthereumWalletNameUpdate: EvmSignable {
    func signableData() throws -> Data {
        Data()
    }
}

extension EthereumWalletWhitelistUpdate: EvmSignable {
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


extension EthereumDAppTransactionRequest: EvmSignable {
    func signableData() throws -> Data {
        Data()
    }
}

extension EthereumTransferPolicyUpdate: EvmSignable {
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

extension EthereumWalletSettingsUpdate: EvmSignable {
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

