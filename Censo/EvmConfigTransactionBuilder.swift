//
//  EvmConfigTransactionBuilder.swift
//  Censo
//
//  Created by Brendan Flood on 1/31/23.
//

import Foundation


enum PolicyUpdateData: Equatable {
    case multisend(Data)
    case single(Data)
    
    var data: Data {
        switch self {
        case .multisend(let data):
            return data
        case .single(let data):
            return data
        }
    }
    
    var operation: Operation {
        switch self {
        case .multisend:
            return .delegatecall
        case .single:
            return .call
        }
    }
}

public class EvmConfigTransactionBuilder {
    static let multiSendCallOnlyAddress = "0x40A2aCCbd92BCA938b02010E17A5b8929b49130D"
    
    // setting guard
    static func getSetGuardExecutionFromModuleDataSafeHash(walletAddress: String, guardAddress: String, evmTransaction: EvmTransaction) throws -> Data {
        guard let vaultAddress = evmTransaction.vaultAddress else {
            throw EvmConfigError.missingVault
        }
        return EvmTransactionUtil.computeSafeTransactionHash(
            chainId: evmTransaction.chainId,
            safeAddress: vaultAddress,
            to: walletAddress,
            value: Bignum(0),
            data: getSetGuardExecutionFromModuleData(walletAddress: walletAddress, guardAddress: guardAddress),
            nonce: evmTransaction.safeNonce
        )
    }
        
        
    static func getSetGuardExecutionFromModuleData(walletAddress: String, guardAddress: String) -> Data{
        return execTransactionFromModuleTx(
            to: walletAddress,
            value: Bignum(0),
            data: setGuardTx(guardAddress: guardAddress),
            operation: .call)
    }
    
    // updating whitelist
    static func getUpdateWhitelistExecutionFromModuleDataSafeHash(walletAddress: String, addsOrRemoves: [Data], evmTransaction: EvmTransaction) throws -> Data {
        guard let vaultAddress = evmTransaction.vaultAddress else {
            throw EvmConfigError.missingVault
        }
        return EvmTransactionUtil.computeSafeTransactionHash(
            chainId: evmTransaction.chainId,
            safeAddress: vaultAddress,
            to: walletAddress,
            value: Bignum(0),
            data: getUpdateWhitelistExecutionFromModuleData(walletAddress: walletAddress, addsOrRemoves: addsOrRemoves),
            nonce: evmTransaction.safeNonce
        )
    }
    
    static func getUpdateWhitelistExecutionFromModuleData(walletAddress: String, addsOrRemoves: [Data]) -> Data {
        return execTransactionFromModuleTx(
            to: walletAddress,
            value: Bignum(0),
            data: updateWhitelistTx(addsOrRemoves: addsOrRemoves),
            operation: .call)
    }
    
    // setting vault policy
    static func getVaultPolicyUpdateDataSafeHash(txs: [SafeTx], evmTransaction: EvmTransaction) throws -> Data {
        guard let vaultAddress = evmTransaction.vaultAddress else {
            throw EvmConfigError.missingVault
        }
        let updateData = getPolicyUpdateData(safeAddress: vaultAddress, txs: txs)
        return EvmTransactionUtil.computeSafeTransactionHash(
            chainId: evmTransaction.chainId,
            safeAddress: vaultAddress,
            to: {
                switch updateData {
                case .multisend:
                    return multiSendCallOnlyAddress
                case .single:
                    return vaultAddress
                    
                }
            }(),
            value: Bignum(0),
            data: updateData.data,
            operation: updateData.operation,
            nonce: evmTransaction.safeNonce
        )
    }
    
    static func getPolicyUpdateData(safeAddress: String, txs: [SafeTx]) -> PolicyUpdateData {
        let encodedTxs = getPolicyChangeDataList(txs: txs)
        switch encodedTxs.count {
        case 0:
            return .single(Data())
        case 1:
            return .single(encodedTxs[0])
        default:
            let normalizedAddress = EvmTransactionUtil.normalizeAddress(safeAddress)
            return .multisend(multiSendTx(
                encodedTxs.map({
                    encodeTransaction(address: normalizedAddress, data: $0)
                }).reduce(Data(), { x, y in x + y })
            ))
        }
    }
    
    // setting wallet policy
    static func getPolicyUpdateExecutionFromModuleDataSafeHash(verifyingContract: String?, safeAddress: String?, txs: [SafeTx], evmTransaction: EvmTransaction) throws -> Data {
        guard let verifyingContract = verifyingContract else {
            throw EvmConfigError.missingVault
        }
        guard let safeAddress = safeAddress else {
            throw EvmConfigError.missingVault
        }
        return EvmTransactionUtil.computeSafeTransactionHash(
            chainId: evmTransaction.chainId,
            safeAddress: verifyingContract,
            to: safeAddress,
            value: Bignum(0),
            data: getPolicyUpdateExecutionFromModuleData(safeAddress: safeAddress, txs: txs),
            nonce: evmTransaction.safeNonce
        )
    }
    
    static func getPolicyUpdateExecutionFromModuleData(safeAddress: String, txs: [SafeTx]) -> Data {
        let updateData = getPolicyUpdateData(safeAddress: safeAddress, txs: txs)
        return execTransactionFromModuleTx(
            to: {
                switch updateData {
                case .multisend:
                    return multiSendCallOnlyAddress
                case .single:
                    return safeAddress
                    
                }
            }(),
            value: Bignum(0),
            data: updateData.data,
            operation: updateData.operation
        )
    }
    
    
    private class func getPolicyChangeDataList(txs: [SafeTx]) -> [Data] {
        return txs.map({ getPolicyChangeData(tx: $0) })
    }
    
    private class func getPolicyChangeData(tx: SafeTx) -> Data {
        switch tx {
        case .swapOwner(let prev, let old, let new):
            return swapOwnerTx(prev: prev, old: old, new: new)
        case .addOwnerWithThreshold(let owner, let threshold):
            return addOwnerWithThresholdTx(owner: owner, threshold: Bignum(threshold))
        case .removeOwner(let prev, let owner, let threshold):
            return removeOwnerTx(prev: prev, owner: owner, threshold: Bignum(threshold))
        case .changeThreshold(let threshold):
            return changeThresholdTx(threshold: Bignum(threshold))
        }
    }
    
    
    private class func setGuardTx(guardAddress: String) -> Data {
        var txData = Data(capacity: 4 + 32*2)
        // setGuard(address)
        txData.append("e19a9dd9".data(using: .hexadecimal)!)
        // to
        EvmTransactionUtil.appendPadded(destination: &txData, source: guardAddress.data(using: .hexadecimal)!)
        return txData
    }

    private class func updateWhitelistTx(addsOrRemoves: [Data]) -> Data {
        // updateWhitelist(bytes[])
        var txData = Data(capacity: 4 + 32 * 2 +  32 * addsOrRemoves.count)
        txData.append("7aaea4f6".data(using: .hexadecimal)!)
        EvmTransactionUtil.appendPadded(destination: &txData, source: Bignum("32").data)
        EvmTransactionUtil.appendPadded(destination: &txData, source: Bignum(addsOrRemoves.count).data)
        addsOrRemoves.forEach { data in
            txData.append(data)
        }
        return txData
    }

    private class func execTransactionFromModuleTx(to: String, value: Bignum, data: Data, operation: Operation) -> Data {
        // execTransactionFromModule(address,uint256,bytes,unit256)
        let mod = data.count % 32
        let padding = mod > 0 ? 32 - mod : 0
        var txData = Data(capacity: 4 + 32*5 + data.count + padding)
        txData.append("468721a7".data(using: .hexadecimal)!)
        EvmTransactionUtil.appendPadded(destination: &txData, source: to.data(using: .hexadecimal)!)
        EvmTransactionUtil.appendPadded(destination: &txData, source: value.data)
        EvmTransactionUtil.appendPadded(destination: &txData, source: Bignum("128").data)  // offset
        EvmTransactionUtil.appendPadded(destination: &txData, source: Data([operation.value]))
        EvmTransactionUtil.appendPadded(destination: &txData, source: Bignum(data.count).data)
        txData.append(data)
        if padding > 0 {
            EvmTransactionUtil.appendPadded(destination: &txData, source: Data(), padTo: padding)
        }
        return txData
    }

    private class func addOwnerWithThresholdTx(owner: String, threshold: Bignum) -> Data {
        // addOwnerWithThreshold(address,uint256)
        var txData = Data(capacity: 4 + 32 * 2)
        txData.append("0d582f13".data(using: .hexadecimal)!)
        EvmTransactionUtil.appendPadded(destination: &txData, source: owner.data(using: .hexadecimal)!)
        EvmTransactionUtil.appendPadded(destination: &txData, source: threshold.data)
        return txData
    }

    private class func removeOwnerTx(prev: String, owner: String, threshold: Bignum) -> Data {
        // removeOwner(address,address,uint256)
        var txData = Data(capacity: 4 + 32 * 3)
        txData.append("f8dc5dd9".data(using: .hexadecimal)!)
        EvmTransactionUtil.appendPadded(destination: &txData, source: prev.data(using: .hexadecimal)!)
        EvmTransactionUtil.appendPadded(destination: &txData, source: owner.data(using: .hexadecimal)!)
        EvmTransactionUtil.appendPadded(destination: &txData, source: threshold.data)
        return txData
    }

    private class func swapOwnerTx(prev: String, old: String, new: String) -> Data {
        // swapOwner(address,address,address)
        var txData = Data(capacity: 4 + 32 * 3)
        txData.append("e318b52b".data(using: .hexadecimal)!)
        EvmTransactionUtil.appendPadded(destination: &txData, source: prev.data(using: .hexadecimal)!)
        EvmTransactionUtil.appendPadded(destination: &txData, source: old.data(using: .hexadecimal)!)
        EvmTransactionUtil.appendPadded(destination: &txData, source: new.data(using: .hexadecimal)!)
        return txData
    }

    private class func changeThresholdTx(threshold: Bignum) -> Data {
        // changeThreshold(uint256)
        var txData = Data(capacity: 4 + 32)
        txData.append("694e80c3".data(using: .hexadecimal)!)
        EvmTransactionUtil.appendPadded(destination: &txData, source: threshold.data)
        return txData
    }

    private class func multiSendTx(_ data: Data) -> Data {
        // multiSend(bytes)
        let mod = data.count % 32
        let padding = mod > 0 ? 32 - mod : 0
        var txData = Data(capacity: 4 + 32*2 + data.count + padding)
        txData.append("8d80ff0a".data(using: .hexadecimal)!)
        EvmTransactionUtil.appendPadded(destination: &txData, source: Bignum(32).data)  // offset
        EvmTransactionUtil.appendPadded(destination: &txData, source: Bignum(data.count).data)
        txData.append(data)
        if padding > 0 {
            EvmTransactionUtil.appendPadded(destination: &txData, source: Data(), padTo: padding)
        }
        return txData
    }

    private class func encodeTransaction(address: Data, data: Data) -> Data {
        var txData = Data(capacity: 1 + 20 + 32 + 32 + data.count)
        txData.append(contentsOf: [UInt8(0)])
        txData.append(address)
        txData.append(Data(count: 32))
        EvmTransactionUtil.appendPadded(destination: &txData, source: Bignum(data.count).data)
        txData.append(data)
        return txData
    }
    
}
