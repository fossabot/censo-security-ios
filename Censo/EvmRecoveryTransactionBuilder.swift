//
//  EvmRecoveryTransactionBuilder.swift
//  Censo
//
//  Created by Brendan Flood on 5/1/23.
//

import Foundation

public class EvmRecoveryTransactionBuilder {
    
    static func getRecoveryContractExecutionFromModuleDataSafeHash(adminRecoveryTxs: AdminRecoveryTxs, evmTransaction: EvmTransaction) -> Data {
        return EvmTransactionUtil.computeSafeTransactionHash(
            chainId: evmTransaction.chainId,
            safeAddress: adminRecoveryTxs.recoveryContractAddress,
            to: adminRecoveryTxs.orgVaultSafeAddress,
            value: Bignum(0),
            data: getRecoveryContractExecutionFromModuleData(
                orgVaultAddress: adminRecoveryTxs.orgVaultSafeAddress,
                old: adminRecoveryTxs.oldOwnerAddress,
                new: adminRecoveryTxs.newOwnerAddress,
                changes: adminRecoveryTxs.txs
            ),
            nonce: evmTransaction.safeNonce
        )
    }
    
    private static func getRecoveryContractExecutionFromModuleData(orgVaultAddress: String, old: String, new: String, changes: [RecoverySafeTx]) -> Data {
        let updateData = getRecoveryUpdateData(orgVaultAddress: orgVaultAddress, old: old, new: new, changes: changes)
        return EvmConfigTransactionBuilder.execTransactionFromModuleTx(
            to: {
                switch updateData {
                case .multisend:
                    return EvmConfigTransactionBuilder.multiSendCallOnlyAddress
                case .single:
                    return orgVaultAddress
                    
                }
            }(),
            value: Bignum(0),
            data: updateData.data,
            operation: updateData.operation
        )
    }

    private class func getRecoveryUpdateData(orgVaultAddress: String, old: String, new: String, changes: [RecoverySafeTx]) -> ContractUpdateData {
        let encodedFunctionCalls = getRecoveryFunctionCalls(orgVaultAddress: orgVaultAddress, old: old, new: new, changes: changes)
        switch encodedFunctionCalls.count {
        case 0:
            return .single(Data())
        case 1:
            return .single(encodedFunctionCalls[0].1)
        default:
            return .multisend(EvmConfigTransactionBuilder.multiSendTx(
                encodedFunctionCalls.map({
                    let normalizedAddress = EvmTransactionUtil.normalizeAddress($0.0)
                    return EvmConfigTransactionBuilder.encodeTransaction(address: normalizedAddress, data: $0.1)
                }).reduce(Data(), { x, y in x + y })
            ))
        }
    }
    
    private class func getRecoveryFunctionCalls(orgVaultAddress: String, old: String, new: String, changes: [RecoverySafeTx]) -> [(String, Data)] {
        return changes.map({
            (
                getAddress(orgVaultAddress: orgVaultAddress, change: $0),
                getRecoverySafeTxData(old: old, new: new, change: $0)
            )
        })
    }
    
    private class func getAddress(orgVaultAddress: String, change: RecoverySafeTx) -> String {
        switch change {
        case .orgVaultSwapOwner:
            return orgVaultAddress
        case .vaultSwapOwner(_, let vaultSafeAddress):
            return vaultSafeAddress
        case .walletSwapOwner(_, let vaultSafeAddress, _):
            return vaultSafeAddress
        }
    }
    
    private class func getRecoverySafeTxData(old: String, new: String, change: RecoverySafeTx) -> Data {
        switch change {
        case .orgVaultSwapOwner(let prev):
            return EvmConfigTransactionBuilder.swapOwnerTx(prev: prev, old: old, new: new)
        case .vaultSwapOwner(let prev, let vaultSafeAddress):
            return EvmConfigTransactionBuilder.getPolicyUpdateExecutionFromModuleData(
                safeAddress: vaultSafeAddress,
                data: EvmConfigTransactionBuilder.swapOwnerTx(prev: prev, old: old, new: new)
            )
        case .walletSwapOwner(let prev, _, let walletSafeAddress):
            return EvmConfigTransactionBuilder.getPolicyUpdateExecutionFromModuleData(
                safeAddress: walletSafeAddress,
                data: EvmConfigTransactionBuilder.getPolicyUpdateExecutionFromModuleData(
                    safeAddress: walletSafeAddress,
                    data: EvmConfigTransactionBuilder.swapOwnerTx(prev: prev, old: old, new: new)
                )
            )
        }
    }
}
