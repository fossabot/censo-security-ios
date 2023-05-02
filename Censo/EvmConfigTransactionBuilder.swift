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
    static let gnosisSafeAddress = "0xd9Db270c1B5E3Bd161E8c8503c55cEABeE709552"
    static let gnosisSafeProxyFactoryAddress = "0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2"
    static let addressZero = "0x000000000000000000000000000000000000000000"
    static let gnosisSafeProxyBinary = "0x608060405234801561001057600080fd5b506040516101e63803806101e68339818101604052602081101561003357600080fd5b8101908080519060200190929190505050600073ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff1614156100ca576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260228152602001806101c46022913960400191505060405180910390fd5b806000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055505060ab806101196000396000f3fe608060405273ffffffffffffffffffffffffffffffffffffffff600054167fa619486e0000000000000000000000000000000000000000000000000000000060003514156050578060005260206000f35b3660008037600080366000845af43d6000803e60008114156070573d6000fd5b3d6000f3fea2646970667358221220d1429297349653a4918076d650332de1a1068c5f3e07c5c82360c277770b955264736f6c63430007060033496e76616c69642073696e676c65746f6e20616464726573732070726f7669646564"
    static let censoRecoveryGuard = "CensoRecoveryGuard"
    static let censoRecoveryFallbackHandler = "CensoRecoveryFallbackHandler"
    static let censoSetup = "CensoSetup"

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
    
    static func getPolicyUpdateExecutionFromModuleData(safeAddress: String, data: Data) -> Data {
        return execTransactionFromModuleTx(
            to: safeAddress,
            value: Bignum(0),
            data: data,
            operation: .call
        )
    }
    
    static func getNameUpdateExecutionFromModuleData(safeAddress: String, newName: String) -> Data {
        let data = setNameHash(name: newName)
        return execTransactionFromModuleTx(
            to: safeAddress,
            value: Bignum(0),
            data: data,
            operation: .call
        )
    }

    static func getNameUpdateExecutionFromModuleDataSafeHash(verifyingContract: String?, safeAddress: String?, newName: String, evmTransaction: EvmTransaction) throws -> Data {
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
            data: getNameUpdateExecutionFromModuleData(safeAddress: safeAddress, newName: newName),
            nonce: evmTransaction.safeNonce
        )
    }
    
    static func getEnableRecoveryContractSafeHash(evmTransaction: EvmTransaction, orgName: String, owners: [String], threshold: Bignum) throws -> Data {
        guard let guardAddress = getContractAddressByName(name: censoRecoveryGuard, contractAddresses: evmTransaction.contractAddresses) else {
            throw EvmConfigError.missingContractAddresses
        }
        guard let fallbackHandlerAddress = getContractAddressByName(name: censoRecoveryFallbackHandler, contractAddresses: evmTransaction.contractAddresses) else {
            throw EvmConfigError.missingContractAddresses
        }
        guard let setupAddress = getContractAddressByName(name: censoSetup, contractAddresses: evmTransaction.contractAddresses) else {
            throw EvmConfigError.missingContractAddresses
        }
        return EvmTransactionUtil.computeSafeTransactionHash(chainId: evmTransaction.chainId, safeAddress: evmTransaction.orgVaultAddress!, to: evmTransaction.orgVaultAddress!, value: Bignum(0), data: enableModuleTx(moduleAddress: calculateRecoveryContractAddress(guardAddress: guardAddress, vaultAddress: evmTransaction.orgVaultAddress!, fallbackHandlerAddress: fallbackHandlerAddress, setupAddress: setupAddress, orgName: orgName, owners: owners, threshold: threshold)), nonce: evmTransaction.safeNonce)
    }
    
    private class func getContractAddressByName(name: String, contractAddresses: [ContractNameAndAddress]) -> String? {
        return contractAddresses.first(where: { $0.name.lowercased() == name.lowercased() && !$0.deprecated })?.address
    }
    
    static func calculateRecoveryContractAddress(guardAddress: String, vaultAddress: String, fallbackHandlerAddress: String, setupAddress: String, orgName: String, owners: [String], threshold: Bignum) -> String {
        let salt = Crypto.sha3keccak256(data: ("Recovery-" + orgName).data(using: .utf8)!)
        let setupData = censoSetupTx(guardAddress: guardAddress, vaultAddress: vaultAddress, fallbackHandlerAddress: fallbackHandlerAddress, nameHash: salt)
        let initializer = safeSetupTx(owners: owners, threshold: threshold, to: setupAddress, data: setupData, fallbackHandlerAddress: fallbackHandlerAddress)
        let result = Crypto.sha3keccak256(
            data: "ff".data(using: .hexadecimal)! +
                  gnosisSafeProxyFactoryAddress.data(using: .hexadecimal)! +
                  Crypto.sha3keccak256(data: Crypto.sha3keccak256(data: initializer) + salt) +
            Crypto.sha3keccak256(data: gnosisSafeProxyBinary.data(using: .hexadecimal)! + "000000000000000000000000".data(using: .hexadecimal)! + gnosisSafeAddress.data(using: .hexadecimal)!))
        return result[12..<result.count].toHexString()
    }

    static func enableModuleTx(moduleAddress: String) -> Data {
        var txData = Data(capacity: 4 + 32)
        txData.append("610b5925".data(using: .hexadecimal)!)
        EvmTransactionUtil.appendPadded(destination: &txData, source: moduleAddress.data(using: .hexadecimal)!)
        return txData
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
        var txData = Data(capacity: 4 + 32)
        // setGuard(address)
        txData.append("e19a9dd9".data(using: .hexadecimal)!)
        // to
        EvmTransactionUtil.appendPadded(destination: &txData, source: guardAddress.data(using: .hexadecimal)!)
        return txData
    }
    
    private class func setNameHash(name: String) -> Data {
         // setNameHash(bytes32)
        var txData = Data(capacity: 4 + 32*2)
        txData.append("3afbdcf4".data(using: .hexadecimal)!)
        EvmTransactionUtil.appendPadded(destination: &txData, source: Crypto.sha3keccak256(data: name.data(using: .utf8)!))
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

    class func execTransactionFromModuleTx(to: String, value: Bignum, data: Data, operation: Operation) -> Data {
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

    class func swapOwnerTx(prev: String, old: String, new: String) -> Data {
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

    class func multiSendTx(_ data: Data) -> Data {
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

    class func encodeTransaction(address: Data, data: Data) -> Data {
        var txData = Data(capacity: 1 + 20 + 32 + 32 + data.count)
        txData.append(contentsOf: [UInt8(0)])
        txData.append(address)
        txData.append(Data(count: 32))
        EvmTransactionUtil.appendPadded(destination: &txData, source: Bignum(data.count).data)
        txData.append(data)
        return txData
    }

    private class func censoSetupTx(guardAddress: String, vaultAddress: String, fallbackHandlerAddress: String, nameHash: Data) -> Data {
        var txData = Data(capacity: 4 + 32 * 4)
        txData.append("ed6a2ed6".data(using: .hexadecimal)!)
        EvmTransactionUtil.appendPadded(destination: &txData, source: guardAddress.data(using: .hexadecimal)!)
        EvmTransactionUtil.appendPadded(destination: &txData, source: vaultAddress.data(using: .hexadecimal)!)
        EvmTransactionUtil.appendPadded(destination: &txData, source: fallbackHandlerAddress.data(using: .hexadecimal)!)
        EvmTransactionUtil.appendPadded(destination: &txData, source: nameHash)
        return txData
     }

     private class func safeSetupTx(owners: [String], threshold: Bignum, to: String, data: Data, fallbackHandlerAddress: String) -> Data {
         let mod = data.count % 32
         let padding = mod > 0 ? 32 - mod : 0
         var txData = Data(capacity: 4 + 32 * (10 + owners.count) + data.count + padding)
         txData.append("b63e800d".data(using: .hexadecimal)!)
         // offset of _owners array (first part of the tail)
         EvmTransactionUtil.appendPadded(destination: &txData, source: (Bignum(32) * Bignum(8)).data)
         EvmTransactionUtil.appendPadded(destination: &txData, source: threshold.data)
         EvmTransactionUtil.appendPadded(destination: &txData, source: to.data(using: .hexadecimal)!)
         // offset of data (second part of the tail)
         EvmTransactionUtil.appendPadded(destination: &txData, source: (Bignum(32) * Bignum(9 + owners.count)).data)
         EvmTransactionUtil.appendPadded(destination: &txData, source: fallbackHandlerAddress.data(using: .hexadecimal)!)
         EvmTransactionUtil.appendPadded(destination: &txData, source: addressZero.data(using: .hexadecimal)!)
         EvmTransactionUtil.appendPadded(destination: &txData, source: Bignum(0).data)
         EvmTransactionUtil.appendPadded(destination: &txData, source: addressZero.data(using: .hexadecimal)!)
         // _owners length
         EvmTransactionUtil.appendPadded(destination: &txData, source: Bignum(owners.count).data)
         // _owners
         owners.forEach { owner in
             EvmTransactionUtil.appendPadded(destination: &txData, source: owner.data(using: .hexadecimal)!)
         }
         // data length
         EvmTransactionUtil.appendPadded(destination: &txData, source: Bignum(data.count).data)
         txData.append(data)
         if padding > 0 {
             EvmTransactionUtil.appendPadded(destination: &txData, source: Data(), padTo: padding)
         }
         return txData
     }

}
