//
//  ApprovalDispositionRequest+SolanaSignable.swift
//  Censo
//
//  Created by Ata Namvari on 2022-03-10.
//

import Foundation
import CryptoKit

extension CensoApi.ApprovalDispositionRequest: SignableData {
    var opIndex: UInt8 {
        return 9
    }

    var opCode: UInt8 {
        switch requestType {
        case .walletCreation:
            return 1
        case .withdrawalRequest:
            return 3
        case .conversionRequest:
            return 3
        case .wrapConversionRequest:
            return 4
        case .signersUpdate:
            return 5
        case .walletConfigPolicyUpdate:
            return 6
        case .dAppTransactionRequest:
            return 7
        case .balanceAccountSettingsUpdate:
            return 8
        case .dAppBookUpdate:
            return 9
        case .addressBookUpdate:
            return 10
        case .balanceAccountNameUpdate:
            return 11
        case .balanceAccountPolicyUpdate:
            return 12
        case .balanceAccountAddressWhitelistUpdate:
            return 14
        case .signData:
            return 15
        case .loginApproval, .acceptVaultInvitation, .passwordReset, .unknown:
            return 0
        }
    }

    var solanaProgramValue: UInt8 {
        switch disposition {
        case .Approve:
            return 1
        case .Deny:
            return 2
        }
    }

    var opHashData: Data {
        get throws {
            let commonBytes: [UInt8] = try signingData.commonOpHashBytes
            if let dataToSign = try signingData.dataToSign {
                return try Data(
                    [15] +
                    commonBytes +
                    SignData(base64Data: dataToSign, signingData: signingData).combinedBytes
                )
            }
            switch requestType {
            case .walletCreation(let request):
                return Data(
                    [opCode] +
                    commonBytes +
                    request.combinedBytes
                )
            case .balanceAccountNameUpdate(let request):
                return Data(
                    [opCode] +
                    commonBytes +
                    request.combinedBytes
                )
            case .balanceAccountSettingsUpdate(let request):
                return Data(
                    [opCode] +
                    commonBytes +
                    request.combinedBytes
                )
            case .balanceAccountPolicyUpdate(let request):
                return Data(
                    [opCode] +
                    commonBytes +
                    request.combinedBytes
                )
            case .balanceAccountAddressWhitelistUpdate(let request):
                return Data(
                    [opCode] +
                    commonBytes +
                    request.combinedBytes
                )
            case .walletConfigPolicyUpdate(let request):
                return Data(
                    [opCode] +
                    commonBytes +
                    request.approvalPolicy.combinedBytes
                )
            case .addressBookUpdate(let request):
                return Data(
                    [opCode] +
                    commonBytes +
                    request.combinedBytes
                )
            case .dAppBookUpdate(let request):
                return Data(
                    [opCode] +
                    commonBytes +
                    request.combinedBytes
                )
            case .withdrawalRequest(let request):
                let tokenMintAddress = request.symbolAndAmountInfo.symbolInfo.tokenMintAddress != nil ? request.symbolAndAmountInfo.symbolInfo.tokenMintAddress! : EMPTY_KEY.base58EncodedString
                return try
                Data(
                    [opCode] +
                    commonBytes) +
                Data(
                    request.account.identifier.sha256HashBytes +
                    request.destination.address.base58Bytes +
                    request.symbolAndAmountInfo.fundamentalAmount.bytes +
                    tokenMintAddress.base58Bytes
                )
            case .conversionRequest(let request):
                let tokenMintAddress = request.symbolAndAmountInfo.symbolInfo.tokenMintAddress != nil ? request.symbolAndAmountInfo.symbolInfo.tokenMintAddress! : EMPTY_KEY.base58EncodedString
                return try
                Data(
                    [opCode] +
                    commonBytes) +
                Data(
                    request.account.identifier.sha256HashBytes +
                    request.destination.address.base58Bytes +
                    request.symbolAndAmountInfo.fundamentalAmount.bytes +
                    tokenMintAddress.base58Bytes
                )
            case .wrapConversionRequest(let request):
                return try Data(
                    [opCode] +
                    commonBytes +
                    request.account.identifier.sha256HashBytes +
                    request.symbolAndAmountInfo.fundamentalAmount.bytes +
                    ([UInt8(request.symbolAndAmountInfo.symbolInfo.symbol == "SOL" ? 0 : 1)] as [UInt8])
                )
            case .signersUpdate(let request):
                return try Data(
                    [opCode] +
                    commonBytes +
                    [request.slotUpdateType.toSolanaProgramValue()] +
                    request.signer.opHashBytes
                )
            case .dAppTransactionRequest(let request):
                return try Data(
                    [opCode] +
                    commonBytes +
                    request.combinedBytes +
                    request.instructions.map { $0.decodedBytes }.joined()
                )
            case .signData(let request):
                return try Data(
                    [opCode] +
                    commonBytes +
                    request.combinedBytes
                )
            case .loginApproval, .acceptVaultInvitation, .passwordReset:
                throw ApprovalError.invalidRequest(reason: "Invalid request for Approval")
            case .unknown:
                throw ApprovalError.invalidRequest(reason: "Unknown Approval")
            }
        }
    }

    var signingData: SolanaSigningData {
        get throws {
            switch requestType {
            case .walletCreation(let request):
                if request.accountInfo.chain == Chain.solana {
                    return request.signingData!
                } else {
                    throw ApprovalError.invalidRequest(reason: "Invalid signing data for approval")
                }
            case .balanceAccountNameUpdate(let request):
                return request.signingData
            case .balanceAccountPolicyUpdate(let request):
                return request.signingData
            case .balanceAccountSettingsUpdate(let request):
                return request.signingData
            case .balanceAccountAddressWhitelistUpdate(let request):
                return request.signingData
            case .addressBookUpdate(let request):
                if request.chain == Chain.solana {
                    return request.signingData!
                } else {
                    throw ApprovalError.invalidRequest(reason: "Invalid signing data for approval")
                }
            case .dAppBookUpdate(let request):
                return request.signingData
            case .walletConfigPolicyUpdate(let request):
                return request.signingData
            case .withdrawalRequest(let request):
                switch request.signingData {
                case .solana(let signingData):
                    return signingData
                default:
                    throw ApprovalError.invalidRequest(reason: "Invalid signing data for approval")
                }
            case .conversionRequest(let request):
                return request.signingData
            case .wrapConversionRequest(let request):
                return request.signingData
            case .signersUpdate(let request):
                return request.signingData
            case .dAppTransactionRequest(let request):
                return request.signingData
            case .signData(let request):
                return request.signingData
            case .loginApproval, .acceptVaultInvitation, .passwordReset:
                throw ApprovalError.invalidRequest(reason: "Invalid request for Approval")
            case .unknown:
                throw ApprovalError.invalidRequest(reason: "Unknown Approval")
            }
        }
    }

    var transactionInstructionData: Data {
        get throws {
            var data = Data()
            data.append(contentsOf: [opIndex])
            data.append(contentsOf: [solanaProgramValue])
            let opHash = try Data(SHA256.hash(data: opHashData))
            data.append(opHash)
            return data
        }
    }
    
    func signableData(approverPublicKey: String) throws -> Data {
        return try signableDataList(approverPublicKey: approverPublicKey)[0]
    }

    func signableDataList(approverPublicKey: String) throws -> [Data] {
        switch requestType {
        case .passwordReset:
            return [requestID.data(using: .utf8)!]
        case .acceptVaultInvitation(let request):
            return [request.vaultName.data(using: .utf8)!]
        case .loginApproval(let request):
            return [request.jwtToken.data(using: .utf8)!]
        case .walletCreation(let walletCreation):
            switch (walletCreation.accountInfo.chain) {
            case .bitcoin:
                return [try JSONEncoder().encode(requestType)]
            case .ethereum:
                return [try JSONEncoder().encode(requestType)]
            default:
                return [try getSolanaSignableData(requestType: requestType, approverPublicKey: approverPublicKey)]
            }
        case .addressBookUpdate(let request):
            switch (request.chain) {
            case .bitcoin:
                return [try JSONEncoder().encode(requestType)]
            case .ethereum:
                return [try JSONEncoder().encode(requestType)]
            default:
                return [try getSolanaSignableData(requestType: requestType, approverPublicKey: approverPublicKey)]
            }
        case .withdrawalRequest(let request):
            switch request.signingData {
            case .bitcoin(let signingData):
                return signingData.transaction.txIns.map( {Data(base64Encoded: $0.base64HashForSignature)!} )
            case .ethereum(let signingData):
                return [try ethereumWithdrawalSignableData(request: request, signingData: signingData)]
            default:
                break
            }
            fallthrough
        default:
            return [try getSolanaSignableData(requestType: requestType, approverPublicKey: approverPublicKey)]
        }
    }
    
    private func ethereumWithdrawalSignableData(request: WithdrawalRequest, signingData: EthereumSigningData) throws -> Data {
        var safeTransaction = Data()
        safeTransaction.append(contentsOf: [0x19, 0x1])
        safeTransaction.append(domainHash(chainId: signingData.transaction.chainId, verifyingContract: request.account.address!))
        if request.symbolAndAmountInfo.symbolInfo.tokenMintAddress == nil {
            safeTransaction.append(
                withdrawalMessageHash(
                    destinationAddress: request.destination.address,
                    amount: try request.symbolAndAmountInfo.fundamentalAmountBignum,
                    data: Data(count: 0),
                    nonce: signingData.transaction.safeNonce
                )
            )
        } else {
            safeTransaction.append(
                withdrawalMessageHash(
                    destinationAddress: request.symbolAndAmountInfo.symbolInfo.tokenMintAddress!,
                    amount: Bignum(0),
                    data: erc20WithdrawalTx(destinationAddress: request.destination.address, amount: try request.symbolAndAmountInfo.fundamentalAmountBignum),
                    nonce: signingData.transaction.safeNonce
                )
            )
        }
        return Crypto.sha3keccak256(data: safeTransaction)
    }
    
    private func getSolanaSignableData(requestType: SolanaApprovalRequestType, approverPublicKey: String) throws -> Data {
        guard let nonce = nonces.first, let nonceAccountAddress = requestType.nonceAccountAddresses.first else {
            throw ApprovalError.invalidRequest(reason: "Not enough nonce accounts")
        }
        
        return try Transaction.compileMessage(
            feePayer: try PublicKey(string: signingData.feePayer),
            recentBlockhash: nonce.value,
            instructions: [
                try TransactionInstruction.createAdvanceNonceInstruction(
                    nonceAccountAddress: nonceAccountAddress,
                    feePayer: signingData.feePayer),
                TransactionInstruction(
                    keys: [
                        Account.Meta(publicKey: try PublicKey(string: signingData.multisigOpAccountAddress), isSigner: false, isWritable: true),
                        Account.Meta(publicKey: PublicKey(string: approverPublicKey), isSigner: true, isWritable: false),
                        Account.Meta(publicKey: SYSVAR_CLOCK_PUBKEY, isSigner: false, isWritable: false)
                    ],
                    programId: PublicKey(string: signingData.walletProgramId),
                    data: [UInt8](transactionInstructionData)
                )
            ]
        ).serialize()
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
            return Bignum(number: amount.replacingOccurrences(of: ".", with: ""), withBase: 10)
        }
    }
}

extension SlotSignerInfo {
    var combinedBytes: [UInt8] {
        return [slotId] + value.publicKey.base58Bytes + (value.nameHashIsEmpty ? Data(count: 32).bytes : value.email.sha256HashBytes)
    }
    var opHashBytes: [UInt8] {
        return [slotId] + value.publicKey.base58Bytes
    }
}

extension SlotDAppInfo {
    var combinedBytes: [UInt8] {
        return [slotId] + value.address.base58Bytes + value.name.sha256HashBytes
    }
}

extension SolanaDApp {
    var combinedBytes: [UInt8] {
        return address.base58Bytes + name.sha256HashBytes
    }
}

extension SlotDestinationInfo {
    var combinedBytes: [UInt8] {
        return [slotId] + value.address.base58Bytes + value.name.sha256HashBytes
    }
}


extension ApprovalPolicy {
    var combinedBytes: [UInt8] {
        return
            [approvalsRequired] +
            approvalTimeout.convertToSeconds.bytes +
            ([UInt8(approvers.count)] as [UInt8]) +
            (approvers.map({ $0.slotId }) as [UInt8]) +
            Data(approvers.flatMap({ $0.value.publicKey.base58Bytes })).sha256HashBytes
    }
}

extension WhitelistUpdate {
    var combinedBytes: [UInt8] {
        return
            account.identifier.sha256HashBytes +
            ([UInt8(destinationsToAdd.count)] as [UInt8]) +
            (destinationsToAdd.map({ $0.slotId }) as [UInt8]) +
            ([UInt8(destinationsToRemove.count)] as [UInt8]) +
            (destinationsToRemove.map({ $0.slotId }) as [UInt8]) +
            Data(destinationsToAdd.flatMap({ $0.value.name.sha256HashBytes }) +
                 [UInt8(1)] +
                 destinationsToRemove.flatMap({ $0.value.name.sha256HashBytes })
            ).sha256HashBytes
    }
}

extension String {
    var base58Bytes: [UInt8] {
        Base58.decode(self)
    }
}

extension String {
    var sha256HashBytes: [UInt8] {
        Data(SHA256.hash(data: Data(utf8))).bytes
    }
}

extension Data {
    var sha256HashBytes: [UInt8] {
        Data(SHA256.hash(data: self)).bytes
    }
}

extension Data {
    var base58String: String {
        Base58.encode(self.bytes)
    }
}

extension UInt64 {
    var convertToSeconds: UInt64 {
        return self / 1000
    }
    
    var bytes: [UInt8] {
        var littleEndian = self.littleEndian
        return withUnsafeBytes(of: &littleEndian) { Array($0) }
    }
}

extension UInt32 {
    
    var bytes: [UInt8] {
        var littleEndian = self.littleEndian
        return withUnsafeBytes(of: &littleEndian) { Array($0) }
    }
}

extension UInt16 {
    
    var bytes: [UInt8] {
        var littleEndian = self.littleEndian
        return withUnsafeBytes(of: &littleEndian) { Array($0) }
    }
}

enum ApprovalError: Error, Equatable {
    case other(String)
    case invalidRequest(reason: String? = nil)
    case notFoundProgramAddress
    case invalidPublicKey
    case noAccountsForSlot
}

extension AddressBookUpdate {
    var combinedBytes: [UInt8] {
        switch change {
        case .add:
            return
                ([UInt8(1)] as [UInt8]) +
                (entry.combinedBytes as [UInt8]) +
                ([UInt8(0)] as [UInt8]) +
                ([UInt8(0)] as [UInt8])
        case .remove:
            return
                ([UInt8(0)] as [UInt8]) +
                ([UInt8(1)] as [UInt8]) +
                (entry.combinedBytes as [UInt8]) +
                ([UInt8(0)] as [UInt8])
        }
    }
}

extension DAppBookUpdate {
    var combinedBytes: [UInt8] {
        return
            ([UInt8(entriesToAdd.count)] as [UInt8]) +
            (entriesToAdd.flatMap(\.combinedBytes) as [UInt8]) +
            ([UInt8(entriesToRemove.count)] as [UInt8]) +
            (entriesToRemove.flatMap(\.combinedBytes) as [UInt8])
    }
}

extension DAppTransactionRequest {
    var combinedBytes: [UInt8] {
        return
            account.identifier.sha256HashBytes +
            dappInfo.combinedBytes +
            UInt16(instructions.map { $0.decodedBytes.count }.reduce(0, +)).bytes
    }
}

extension WalletCreation {
    var combinedBytes: [UInt8] {
        return
            accountInfo.identifier.sha256HashBytes +
            [accountSlot] as [UInt8] +
            accountInfo.name.sha256HashBytes +
            approvalPolicy.combinedBytes +
            ([whitelistEnabled.toSolanaProgramValue()] as [UInt8]) +
            ([dappsEnabled.toSolanaProgramValue()] as [UInt8]) +
            ([addressBookSlot] as [UInt8])
    }
}

extension BalanceAccountNameUpdate {
    var combinedBytes: [UInt8] {
        return
            accountInfo.identifier.sha256HashBytes +
            newAccountName.sha256HashBytes
    }
}

extension BalanceAccountPolicyUpdate {
    var combinedBytes: [UInt8] {
        return
            accountInfo.identifier.sha256HashBytes +
            approvalPolicy.combinedBytes
    }
}

extension BalanceAccountSettingsUpdate {
    var combinedBytes: [UInt8] {
        switch change {
        case .dappsEnabled(let value):
            return
                account.identifier.sha256HashBytes +
                ([UInt8(0)] as [UInt8]) +
                ([UInt8(0)] as [UInt8]) +
                ([UInt8(1)] as [UInt8]) +
                ([value ? BooleanSetting.On.toSolanaProgramValue() : BooleanSetting.Off.toSolanaProgramValue()] as [UInt8])
        case .whitelistEnabled(let value):
            return
                account.identifier.sha256HashBytes +
                ([UInt8(1)] as [UInt8]) +
                ([value ? BooleanSetting.On.toSolanaProgramValue() : BooleanSetting.Off.toSolanaProgramValue()] as [UInt8]) +
                ([UInt8(0)] as [UInt8]) +
                ([UInt8(0)] as [UInt8])
        }
    }
}

extension BalanceAccountAddressWhitelistUpdate {
    var combinedBytes: [UInt8] {
        return
            accountInfo.identifier.sha256HashBytes +
            ([UInt8(destinations.count)] as [UInt8]) +
            (destinations.map({ $0.slotId }) as [UInt8]) +
            Data(destinations.flatMap({ $0.value.name.sha256HashBytes }) 
            ).sha256HashBytes
    }
}

extension SignData {
    var combinedBytes: [UInt8] {
        let dataToSignHash: [UInt8] = Data(base64Encoded: base64Data)!.sha256HashBytes
        return UInt16(dataToSignHash.count).bytes + dataToSignHash
    }
}


extension SolanaSigningData {
    var commonOpHashBytes: [UInt8] {
        let decodedFeeAccountGuidHash: Data?
        do {
            decodedFeeAccountGuidHash = try Data(base64Encoded: feeAccountGuidHash)
        } catch {
            decodedFeeAccountGuidHash = Data(count: 32)
        }
        return
            initiator.base58Bytes +
            feePayer.base58Bytes +
            strikeFeeAmount.bytes +
            [UInt8](decodedFeeAccountGuidHash!.bytes) +
            walletAddress.base58Bytes
    }
}


