//
//  File.swift
//  Strike
//
//  Created by Brendan Flood on 3/25/22.
//

import Foundation
import CryptoKit

extension StrikeApi.InitiationRequest: SolanaSignable {

    var opCode: UInt8 {
        switch request.details {
        case .balanceAccountCreation:
            return 3
        case .withdrawalRequest:
            return 7
        case .conversionRequest:
            return 7
        case .signersUpdate:
            return 12
        default:
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
    
    var opAccountPublicKey: PublicKey {
        get throws {
            try PublicKey(string: Base58.encode(opAccountPrivateKey.publicKey.rawRepresentation.bytes))
        }
    }
    
    var createAccountMeta: [Account.Meta] {
        get throws {
            try [
                Account.Meta(publicKey: PublicKey(string: signingData.feePayer), isSigner: true, isWritable: true),
                Account.Meta(publicKey: opAccountPublicKey, isSigner: true, isWritable: true)
            ]
        }
    }
    
    var createOpAccountInstruction: TransactionInstruction {
        get throws {
            try TransactionInstruction(
                keys: try createAccountMeta,
                programId: SYS_PROGRAM_ID,
                data: [UInt8](createOpAccounTransactionInstructionData)
            )
        }
    }
    
    var createOpAccounTransactionInstructionData: Data {
        get throws {
            try Data(
                UInt32(0).bytes +
                request.opAccountCreationInfo.minBalanceForRentExemption.bytes +
                request.opAccountCreationInfo.accountSize.bytes +
                signingData.walletProgramId.base58Bytes
            )
        }
    }
    

    var instructionData: Data {
        get throws {
            switch request.details {
            case .balanceAccountCreation(let request):
                return try Data(
                    [opCode] +
                    request.accountInfo.identifier.sha256HashBytes +
                    [request.accountSlot] +
                    request.accountInfo.name.sha256HashBytes +
                    [request.approvalsRequired] +
                    request.approvalTimeout.convertToSeconds.bytes +
                    ([UInt8(request.approvers.count)] as [UInt8]) +
                    (request.approvers.flatMap(\.combinedBytes) as [UInt8]) +
                    ([request.whitelistEnabled.toSolanaProgramValue()] as [UInt8]) +
                    ([request.dappsEnabled.toSolanaProgramValue()] as [UInt8]) +
                    ([request.addressBookSlot] as [UInt8])
                )
            case .withdrawalRequest(let request):
                return try Data(
                    [opCode] +
                    request.account.identifier.sha256HashBytes +
                    request.symbolAndAmountInfo.fundamentalAmount.bytes +
                    request.destination.name.sha256HashBytes
                )
            case .conversionRequest(let request):
                return try Data(
                    [opCode] +
                    request.account.identifier.sha256HashBytes +
                    request.symbolAndAmountInfo.fundamentalAmount.bytes +
                    request.destination.name.sha256HashBytes
                )
            case .signersUpdate(let request):
                return Data(
                    [opCode] +
                    [request.slotUpdateType.toSolanaProgramValue()] +
                    request.signer.combinedBytes
                )
            default:
                throw SolanaError.invalidRequest(reason: "Unknown Approval")
            }
        }
    }

    var signingData: SolanaSigningData {
        get throws {
            switch request.details {
            case .balanceAccountCreation(let request):
                return request.signingData
            case .withdrawalRequest(let request):
                return request.signingData
            case .conversionRequest(let request):
                return request.signingData
            case .signersUpdate(let request):
                return request.signingData
            default:
                throw SolanaError.invalidRequest(reason: "Unknown Initiation")
            }
        }
    }
    
    func instructionAccountMeta(approverPublicKey: PublicKey) throws -> [Account.Meta] {
        switch request.details {
        case .withdrawalRequest(let request):
            return try getTransferAndConversionAccounts(
                sourceAddress: request.account.address!,
                destinationAddress: request.destination.address,
                tokenMintAddress: request.symbolAndAmountInfo.symbolInfo.tokenMintAddress,
                approverPublicKey: approverPublicKey
            )
        case .conversionRequest(let request):
            return try getTransferAndConversionAccounts(
                sourceAddress: request.account.address!,
                destinationAddress: request.destination.address,
                tokenMintAddress: request.symbolAndAmountInfo.symbolInfo.tokenMintAddress,
                approverPublicKey: approverPublicKey
            )
        default:
            return [
                Account.Meta(publicKey: try opAccountPublicKey, isSigner: false, isWritable: true),
                Account.Meta(publicKey: try PublicKey(string: signingData.walletAddress), isSigner: false, isWritable: false),
                Account.Meta(publicKey: approverPublicKey, isSigner: true, isWritable: false),
                Account.Meta(publicKey: SYSVAR_CLOCK_PUBKEY, isSigner: false, isWritable: false)
            ]
        }
    }
    
    func getTransferAndConversionAccounts(sourceAddress: String, destinationAddress: String, tokenMintAddress: String, approverPublicKey: PublicKey) throws -> [Account.Meta] {
        let sourcePublicKey = try PublicKey(string: sourceAddress)
        let tokenMintPublicKey = try PublicKey(string: tokenMintAddress)
        let destinationPublicKey = try PublicKey(string: destinationAddress)
        var destinationTokenAddress = EMPTY_KEY
        if tokenMintPublicKey != EMPTY_KEY {
            destinationTokenAddress = try PublicKey.associatedTokenAddress(walletAddress: destinationPublicKey,
                                                                           tokenMintAddress: tokenMintPublicKey).get()
        }
        return [
            Account.Meta(publicKey: try opAccountPublicKey, isSigner: false, isWritable: true),
            Account.Meta(publicKey: try PublicKey(string: signingData.walletAddress), isSigner: false, isWritable: false),
            Account.Meta(publicKey: sourcePublicKey, isSigner: false, isWritable: true),
            Account.Meta(publicKey: destinationPublicKey, isSigner: false, isWritable: false),
            Account.Meta(publicKey: approverPublicKey, isSigner: true, isWritable: false),
            Account.Meta(publicKey: SYSVAR_CLOCK_PUBKEY, isSigner: false, isWritable: false),
            Account.Meta(publicKey: tokenMintPublicKey, isSigner: false, isWritable: false),
            Account.Meta(publicKey: destinationTokenAddress, isSigner: false, isWritable: true),
            Account.Meta(publicKey: try PublicKey(string: signingData.feePayer), isSigner: true, isWritable: true),
            Account.Meta(publicKey: SYS_PROGRAM_ID, isSigner: false, isWritable: false),
            Account.Meta(publicKey: TOKEN_PROGRAM_ID, isSigner: false, isWritable: false),
            Account.Meta(publicKey: SYSVAR_RENT_PUBKEY, isSigner: false, isWritable: false),
            Account.Meta(publicKey: ASSOCIATED_TOKEN_PROGRAM_ID, isSigner: false, isWritable: false)
        ]
    }


    func signableData(approverPublicKey: String) throws -> Data {
        return try Transaction.compileMessage(
            feePayer: try PublicKey(string: signingData.feePayer),
            recentBlockhash: blockhash.value,
            instructions: [
                createOpAccountInstruction,
                TransactionInstruction(
                    keys: instructionAccountMeta(approverPublicKey: try PublicKey(string: approverPublicKey)),
                    programId: PublicKey(string: signingData.walletProgramId),
                    data: [UInt8](instructionData)
                )
            ]
        ).serialize()
    }
}
