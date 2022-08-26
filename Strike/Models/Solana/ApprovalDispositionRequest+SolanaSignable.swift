//
//  ApprovalDispositionRequest+SolanaSignable.swift
//  Strike
//
//  Created by Ata Namvari on 2022-03-10.
//

import Foundation
import CryptoKit

extension StrikeApi.ApprovalDispositionRequest: SolanaSignable {
    var opIndex: UInt8 {
        return 9
    }

    var opCode: UInt8 {
        switch requestType {
        case .balanceAccountCreation:
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
            switch requestType {
            case .balanceAccountCreation(let request):
                return try Data(
                    [opCode] +
                    commonBytes +
                    signingData.walletAddress.base58Bytes +
                    request.combinedBytes
                )
            case .balanceAccountNameUpdate(let request):
                return try Data(
                    [opCode] +
                    commonBytes +
                    signingData.walletAddress.base58Bytes +
                    request.combinedBytes
                )
            case .balanceAccountSettingsUpdate(let request):
                return try Data(
                    [opCode] +
                    commonBytes +
                    signingData.walletAddress.base58Bytes +
                    request.combinedBytes
                )
            case .balanceAccountPolicyUpdate(let request):
                return try Data(
                    [opCode] +
                    commonBytes +
                    signingData.walletAddress.base58Bytes +
                    request.combinedBytes
                )
            case .balanceAccountAddressWhitelistUpdate(let request):
                return try Data(
                    [opCode] +
                    commonBytes +
                    signingData.walletAddress.base58Bytes +
                    request.combinedBytes
                )
            case .walletConfigPolicyUpdate(let request):
                return try Data(
                    [opCode] +
                    commonBytes +
                    signingData.walletAddress.base58Bytes +
                    request.approvalPolicy.combinedBytes
                )
            case .addressBookUpdate(let request):
                return try Data(
                    [opCode] +
                    commonBytes +
                    signingData.walletAddress.base58Bytes +
                    request.combinedBytes
                )
            case .dAppBookUpdate(let request):
                return try Data(
                    [opCode] +
                    commonBytes +
                    signingData.walletAddress.base58Bytes +
                    request.combinedBytes
                )
            case .withdrawalRequest(let request):
                return try
                Data(
                    [opCode] +
                    commonBytes) +
                Data(
                    signingData.walletAddress.base58Bytes +
                    request.account.identifier.sha256HashBytes +
                    request.destination.address.base58Bytes +
                    request.symbolAndAmountInfo.fundamentalAmount.bytes +
                    request.symbolAndAmountInfo.symbolInfo.tokenMintAddress.base58Bytes
                )
            case .conversionRequest(let request):
                return try
                Data(
                    [opCode] +
                    commonBytes) +
                Data(
                    signingData.walletAddress.base58Bytes +
                    request.account.identifier.sha256HashBytes +
                    request.destination.address.base58Bytes +
                    request.symbolAndAmountInfo.fundamentalAmount.bytes +
                    request.symbolAndAmountInfo.symbolInfo.tokenMintAddress.base58Bytes
                )
            case .wrapConversionRequest(let request):
                return try Data(
                    [opCode] +
                    commonBytes +
                    signingData.walletAddress.base58Bytes +
                    request.account.identifier.sha256HashBytes +
                    request.symbolAndAmountInfo.fundamentalAmount.bytes +
                    ([UInt8(request.symbolAndAmountInfo.symbolInfo.symbol == "SOL" ? 0 : 1)] as [UInt8])
                )
            case .signersUpdate(let request):
                return try Data(
                    [opCode] +
                    commonBytes +
                    signingData.walletAddress.base58Bytes +
                    [request.slotUpdateType.toSolanaProgramValue()] +
                    request.signer.combinedBytes
                )
            case .dAppTransactionRequest(let request):
                return try Data(
                    [opCode] +
                    commonBytes +
                    signingData.walletAddress.base58Bytes +
                    request.combinedBytes +
                    request.instructions.map { $0.decodedBytes }.joined()
                )
            case .loginApproval, .acceptVaultInvitation, .passwordReset:
                throw SolanaError.invalidRequest(reason: "Invalid request for Approval")
            case .unknown:
                throw SolanaError.invalidRequest(reason: "Unknown Approval")
            }
        }
    }

    var signingData: SolanaSigningData {
        get throws {
            switch requestType {
            case .balanceAccountCreation(let request):
                return request.signingData
            case .balanceAccountNameUpdate(let request):
                return request.signingData
            case .balanceAccountPolicyUpdate(let request):
                return request.signingData
            case .balanceAccountSettingsUpdate(let request):
                return request.signingData
            case .balanceAccountAddressWhitelistUpdate(let request):
                return request.signingData
            case .addressBookUpdate(let request):
                return request.signingData
            case .dAppBookUpdate(let request):
                return request.signingData
            case .walletConfigPolicyUpdate(let request):
                return request.signingData
            case .withdrawalRequest(let request):
                return request.signingData
            case .conversionRequest(let request):
                return request.signingData
            case .wrapConversionRequest(let request):
                return request.signingData
            case .signersUpdate(let request):
                return request.signingData
            case .dAppTransactionRequest(let request):
                return request.signingData
            case .loginApproval, .acceptVaultInvitation, .passwordReset:
                throw SolanaError.invalidRequest(reason: "Invalid request for Approval")
            case .unknown:
                throw SolanaError.invalidRequest(reason: "Unknown Approval")
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
        switch requestType {
        case .passwordReset(let request):
            return "".data(using: .utf8)!
        case .acceptVaultInvitation(let request):
            return request.vaultName.data(using: .utf8)!
        case .loginApproval(let request):
            return request.jwtToken.data(using: .utf8)!
        default:
            guard let nonce = nonces.first, let nonceAccountAddress = requestType.nonceAccountAddresses.first else {
                throw SolanaError.invalidRequest(reason: "Not enough nonce accounts")
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
}

extension SlotSignerInfo {
    var combinedBytes: [UInt8] {
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

enum SolanaError: Error, Equatable {
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

extension BalanceAccountCreation {
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
        [UInt8](decodedFeeAccountGuidHash!.bytes)
    }
}


