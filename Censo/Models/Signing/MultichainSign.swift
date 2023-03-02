//
//  MultichainSign.swift
//  Censo
//
//  Created by Brendan Flood on 2/4/23.
//

import Foundation

protocol MultichainSignable {
    func signableData() throws -> [(Chain, Data)]
}


extension VaultPolicyUpdate: MultichainSignable {
    
    func signableData() throws -> [(Chain, Data)] {
        return try signingData.map {
            switch $0 {
            case .ethereum(let signingData):
                return (Chain.ethereum, try getSafeHash(chain: Chain.ethereum, evmTransaction: signingData.transaction))
            case .polygon(let signingData):
                return (Chain.polygon, try getSafeHash(chain: Chain.polygon, evmTransaction: signingData.transaction))
            }
        }
    }
    
    private func getSafeHash(chain: Chain, evmTransaction: EvmTransaction) throws -> Data {
        guard let currentOnChainPolicy = currentOnChainPolicies.first(where: {$0.chain == chain} ) else {
            throw EvmConfigError.missingChain
        }
        let startingPolicy = try Policy(
            owners: currentOnChainPolicy.owners,
            threshold: currentOnChainPolicy.threshold
        )
        return try EvmConfigTransactionBuilder.getPolicyUpdateExecutionFromModuleDataSafeHash(
            verifyingContract: evmTransaction.orgVaultAddress,
            safeAddress: evmTransaction.vaultAddress,
            txs: startingPolicy.safeTransactions(
                try Policy(
                    owners: approvalPolicy.approvers.map { try getAddress($0.publicKeys, Chain.ethereum) },
                    threshold: approvalPolicy.approvalsRequired
                )
            ).0,
            evmTransaction: evmTransaction
        )
    }
    
    private func getAddress(_ publicKeys: [ChainPubkey], _ chain: Chain) throws -> String {
        guard let publicKey = publicKeys.first(where: {$0.chain == chain }) else {
            throw EvmConfigError.missingChain
        }
        return EvmTransactionUtil.getEthereumAddressFromBase58(base58Key: publicKey.key)
    }
    
}

extension VaultNameUpdate: MultichainSignable {
    func signableData() throws -> [(Chain, Data)] {
        return try signingData.map {
            switch $0 {
            case .ethereum(let signingData):
                return (Chain.ethereum, try getSafeHash(evmTransaction: signingData.transaction))
            case .polygon(let signingData):
                return (Chain.polygon, try getSafeHash(evmTransaction: signingData.transaction))
            }
        }
    }
    
    private func getSafeHash(evmTransaction: EvmTransaction) throws -> Data {
        return try EvmConfigTransactionBuilder.getNameUpdateExecutionFromModuleDataSafeHash(
            verifyingContract: evmTransaction.orgVaultAddress,
            safeAddress: evmTransaction.vaultAddress,
            newName: newName,
            evmTransaction: evmTransaction
        )
    }
}

extension OrgAdminPolicyUpdate: MultichainSignable {
    
    func signableData() throws -> [(Chain, Data)] {
        return try signingData.map {
            switch $0 {
            case .ethereum(let signingData):
                return (Chain.ethereum, try getSafeHash(chain: Chain.ethereum, evmTransaction: signingData.transaction))
            case .polygon(let signingData):
                return (Chain.polygon, try getSafeHash(chain: Chain.polygon, evmTransaction: signingData.transaction))
            }
        }
    }
    
    private func getSafeHash(chain: Chain, evmTransaction: EvmTransaction) throws -> Data {
        guard let currentOnChainPolicy = currentOnChainPolicies.first(where: {$0.chain == chain} ) else {
            throw EvmConfigError.missingChain
        }
        let startingPolicy = try Policy(
            owners: currentOnChainPolicy.owners,
            threshold: currentOnChainPolicy.threshold
        )
        return try EvmConfigTransactionBuilder.getVaultPolicyUpdateDataSafeHash(
            txs: startingPolicy.safeTransactions(
                try Policy(
                    owners: approvalPolicy.approvers.map { try getAddress($0.publicKeys, Chain.ethereum) },
                    threshold: approvalPolicy.approvalsRequired
                )
            ).0,
            evmTransaction: evmTransaction
        )
    }
    
    private func getAddress(_ publicKeys: [ChainPubkey], _ chain: Chain) throws -> String {
        guard let publicKey = publicKeys.first(where: {$0.chain == chain }) else {
            throw EvmConfigError.missingChain
        }
        return EvmTransactionUtil.getEthereumAddressFromBase58(base58Key: publicKey.key)
    }
    
}
