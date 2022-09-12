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
        switch requestType {
        case .balanceAccountCreation:
            return 3
        case .withdrawalRequest:
            return 7
        case .conversionRequest:
            return 7
        case .wrapConversionRequest:
            return 10
        case .signersUpdate:
            return 12
        case .walletConfigPolicyUpdate:
            return 14
        case .dAppTransactionRequest:
            return 16
        case .balanceAccountSettingsUpdate:
            return 18
        case .dAppBookUpdate:
            return 20
        case .addressBookUpdate:
            return 22
        case .balanceAccountNameUpdate:
            return 24
        case .balanceAccountPolicyUpdate:
            return 26
        case .balanceAccountAddressWhitelistUpdate:
            return 33
        case .signData:
            return 35
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

    var createOpAccountMeta: [Account.Meta] {
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
                keys: try createOpAccountMeta,
                programId: SYS_PROGRAM_ID,
                data: [UInt8](createOpAccounTransactionInstructionData)
            )
        }
    }
    
    var createOpAccounTransactionInstructionData: Data {
        get throws {
            try Data(
                UInt32(0).bytes +
                initiation.opAccountCreationInfo.minBalanceForRentExemption.bytes +
                initiation.opAccountCreationInfo.accountSize.bytes +
                signingData.walletProgramId.base58Bytes
            )
        }
    }
        
    var instructionData: Data {
        get throws {
            let commonBytes = try signingData.commonInitiationBytes
            
            if let dataToSign = try signingData.dataToSign  {
                return try Data(
                    [35] +
                    commonBytes +
                    SignData(base64Data: dataToSign, signingData: signingData).combinedBytes
                )
            }
            
            switch requestType {
            case .balanceAccountCreation(let request):
                return Data(
                    [opCode] +
                    commonBytes +
                    request.combinedBytes
                )
            case .withdrawalRequest(let request):
                return try Data(
                    [opCode] +
                    commonBytes +
                    request.account.identifier.sha256HashBytes +
                    request.symbolAndAmountInfo.fundamentalAmount.bytes +
                    request.destination.name.sha256HashBytes
                )
            case .conversionRequest(let request):
                return try Data(
                    [opCode] +
                    commonBytes +
                    request.account.identifier.sha256HashBytes +
                    request.symbolAndAmountInfo.fundamentalAmount.bytes +
                    request.destination.name.sha256HashBytes
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
                return Data(
                    [opCode] +
                    commonBytes +
                    [request.slotUpdateType.toSolanaProgramValue()] +
                    request.signer.combinedBytes
                )
            case .dAppTransactionRequest(let request):
                return Data(
                    [opCode] +
                    commonBytes +
                    request.account.identifier.sha256HashBytes +
                    request.dappInfo.address.base58Bytes +
                    request.dappInfo.name.sha256HashBytes +
                    (UInt16(request.instructions.map { $0.decodedBytes.count }.reduce(0, +)).bytes)
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
            case .signData(let request):
                return Data(
                    [opCode] +
                    commonBytes +
                    request.combinedBytes
                )
            default:
                throw SolanaError.invalidRequest(reason: "Unknown Approval")
            }
        }
    }

    var supplyInstructions: [SupplyDappInstruction] {
        get throws {
            switch requestType {
            case .dAppTransactionRequest(let request) where request.instructions.count + 1 == nonces.count && nonces.count == request.signingData.nonceAccountAddresses.count:
                return try request.instructions.enumerated().map { (i, instructionChunk) in
                    SupplyDappInstruction(
                        nonce: nonces[i + 1],
                        nonceAccountAddress: request.signingData.nonceAccountAddresses[i + 1],
                        instructionChunk: instructionChunk,
                        signingData: try signingData,
                        opAccountPublicKey: try opAccountPublicKey,
                        walletAccountPublicKey: try PublicKey(string: signingData.walletAddress)
                    )
                }
            case .dAppTransactionRequest:
                throw SolanaError.invalidRequest(reason: "Nonce count does not match instruction count")
            default:
                return []
            }
        }
    }
    

    var signingData: SolanaSigningData {
        get throws {
            switch requestType {
            case .balanceAccountCreation(let request):
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
            case .signData(let request):
                return request.signingData
            default:
                throw SolanaError.invalidRequest(reason: "Unknown Initiation")
            }
        }
    }
    
    func instructionAccountMeta(approverPublicKey: PublicKey) throws -> [Account.Meta] {
        switch requestType {
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
        case .wrapConversionRequest(let request):
            let sourcePublicKey = try PublicKey(string: request.account.address)
            let sourceTokenPublicKey = try PublicKey.associatedTokenAddress(walletAddress: sourcePublicKey,
                                                                          tokenMintAddress: WRAPPED_SOL_MINT).get()
            var accounts = [
                Account.Meta(publicKey: try opAccountPublicKey, isSigner: false, isWritable: true),
                Account.Meta(publicKey: try PublicKey(string: signingData.walletAddress), isSigner: false, isWritable: true),
                Account.Meta(publicKey: sourcePublicKey, isSigner: false, isWritable: true),
                Account.Meta(publicKey: sourceTokenPublicKey, isSigner: false, isWritable: true),
                Account.Meta(publicKey: WRAPPED_SOL_MINT, isSigner: false, isWritable: false),
                Account.Meta(publicKey: approverPublicKey, isSigner: true, isWritable: false),
                Account.Meta(publicKey: SYSVAR_CLOCK_PUBKEY, isSigner: false, isWritable: false),
                Account.Meta(publicKey: try PublicKey(string: signingData.feePayer), isSigner: true, isWritable: false)
            ]
            
            if request.destinationSymbolInfo.symbol == "SOL" {
                let walletGuidHash: Data?
                do {
                    walletGuidHash = try Data(base64Encoded: signingData.walletGuidHash)
                } catch {
                    walletGuidHash = Data(count: 32)
                }
                accounts.append(Account.Meta(
                    publicKey: try PublicKey.temporaryUnwrappingAccount(
                        walletGuidHash: walletGuidHash!,
                        multisigOpAddress: try opAccountPublicKey,
                        walletProgramId: try PublicKey(string: signingData.walletProgramId)).get(),
                    isSigner: false,
                    isWritable: true
                ))
            }
    
            accounts = accounts + [
                Account.Meta(publicKey: SYS_PROGRAM_ID, isSigner: false, isWritable: false),
                Account.Meta(publicKey: TOKEN_PROGRAM_ID, isSigner: false, isWritable: false),
                Account.Meta(publicKey: SYSVAR_RENT_PUBKEY, isSigner: false, isWritable: false),
                Account.Meta(publicKey: ASSOCIATED_TOKEN_PROGRAM_ID, isSigner: false, isWritable: false)
            ]
            
            if request.signingData.strikeFeeAmount > 0 {
                let feeAccountGuidHash: Data?
                do {
                    feeAccountGuidHash = try Data(base64Encoded: signingData.feeAccountGuidHash)
                } catch {
                    feeAccountGuidHash = Data(count: 32)
                }
                let walletGuidHash: Data?
                do {
                    walletGuidHash = try Data(base64Encoded: signingData.walletGuidHash)
                } catch {
                    walletGuidHash = Data(count: 32)
                }
                accounts.append(
                    Account.Meta(
                        publicKey: try PublicKey.balanceAccount(
                            walletGuidHash: walletGuidHash!,
                            feeAccountGuidHash: feeAccountGuidHash!,
                            walletProgramId: try PublicKey(string: signingData.walletProgramId)).get(),
                        isSigner: false,
                        isWritable: true))
            }
            return accounts
        case .dAppTransactionRequest:
            return [
                Account.Meta(publicKey: try opAccountPublicKey, isSigner: false, isWritable: true),
                Account.Meta(publicKey: try PublicKey(string: signingData.walletAddress), isSigner: false, isWritable: true),
                Account.Meta(publicKey: approverPublicKey, isSigner: true, isWritable: false),
                Account.Meta(publicKey: SYSVAR_CLOCK_PUBKEY, isSigner: false, isWritable: false),
                Account.Meta(publicKey: try PublicKey(string: signingData.feePayer), isSigner: true, isWritable: false)
            ]
        default:
            return [
                Account.Meta(publicKey: try opAccountPublicKey, isSigner: false, isWritable: true),
                Account.Meta(publicKey: try PublicKey(string: signingData.walletAddress), isSigner: false, isWritable: true),
                Account.Meta(publicKey: approverPublicKey, isSigner: true, isWritable: false),
                Account.Meta(publicKey: SYSVAR_CLOCK_PUBKEY, isSigner: false, isWritable: false),
                Account.Meta(publicKey: try PublicKey(string: signingData.feePayer), isSigner: true, isWritable: false)
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
            Account.Meta(publicKey: try PublicKey(string: signingData.walletAddress), isSigner: false, isWritable: true),
            Account.Meta(publicKey: sourcePublicKey, isSigner: false, isWritable: true),
            Account.Meta(publicKey: destinationPublicKey, isSigner: false, isWritable: false),
            Account.Meta(publicKey: approverPublicKey, isSigner: true, isWritable: false),
            Account.Meta(publicKey: SYSVAR_CLOCK_PUBKEY, isSigner: false, isWritable: false),
            Account.Meta(publicKey: try PublicKey(string: signingData.feePayer), isSigner: true, isWritable: true),
            Account.Meta(publicKey: tokenMintPublicKey, isSigner: false, isWritable: false),
            Account.Meta(publicKey: destinationTokenAddress, isSigner: false, isWritable: true),
            Account.Meta(publicKey: SYS_PROGRAM_ID, isSigner: false, isWritable: false),
            Account.Meta(publicKey: TOKEN_PROGRAM_ID, isSigner: false, isWritable: false),
            Account.Meta(publicKey: SYSVAR_RENT_PUBKEY, isSigner: false, isWritable: false),
            Account.Meta(publicKey: ASSOCIATED_TOKEN_PROGRAM_ID, isSigner: false, isWritable: false)
        ]
    }
    
    func signableData(approverPublicKey: String) throws -> Data {
        guard let nonce = nonces.first, let nonceAccountAddress = requestType.nonceAccountAddresses.first else {
            throw SolanaError.invalidRequest(reason: "Not enough nonce accounts")
        }

        var instructions = try [TransactionInstruction.createAdvanceNonceInstruction(
            nonceAccountAddress: nonceAccountAddress,
            feePayer: signingData.feePayer)
        ]

        instructions.append(try createOpAccountInstruction)

        instructions.append(try TransactionInstruction(
                keys: instructionAccountMeta(approverPublicKey: try PublicKey(string: approverPublicKey)),
                programId: PublicKey(string: signingData.walletProgramId),
                data: [UInt8](instructionData)
            )
        )

        return try Transaction.compileMessage(
            feePayer: PublicKey(string: signingData.feePayer),
            recentBlockhash: nonce.value,
            instructions: instructions
        ).serialize()
    }

    struct SupplyDappInstruction: SolanaSignable {
        var nonce: StrikeApi.Nonce
        var nonceAccountAddress: String
        var instructionChunk: SolanaInstructionChunk
        var signingData: SolanaSigningData
        var opAccountPublicKey: PublicKey
        var walletAccountPublicKey: PublicKey

        func signableData(approverPublicKey: String) throws -> Data {
            return try Transaction.compileMessage(
                    feePayer: try PublicKey(string: signingData.feePayer),
                    recentBlockhash: nonce.value,
                    instructions: [
                        TransactionInstruction.createAdvanceNonceInstruction(
                            nonceAccountAddress: nonceAccountAddress,
                            feePayer: signingData.feePayer
                        ),
                        TransactionInstruction(
                            keys: [
                                Account.Meta(publicKey: opAccountPublicKey, isSigner: false, isWritable: true),
                                Account.Meta(publicKey: walletAccountPublicKey, isSigner: false, isWritable: false),
                                Account.Meta(publicKey: try PublicKey(string: approverPublicKey), isSigner: true, isWritable: false)
                            ],
                            programId: try PublicKey(string: signingData.walletProgramId),
                            data: [UInt8](instructionChunk.combinedBytes)
                        )
                    ]
                ).serialize()
        }
    }
}


extension SolanaInstructionChunk {
    var combinedBytes: [UInt8] {
        return [UInt8](Data(
            [28] +
            offset.bytes +
            UInt16(decodedBytes.count).bytes +
            decodedBytes
        ))
    }
}

extension SolanaInstructionChunk {
    var decodedBytes: [UInt8] {
        guard let b64DecodedData = Data(base64Encoded: instructionData) else {
            return []
        }
        return [UInt8](b64DecodedData)
    }
}

extension TransactionInstruction {
    static func createAdvanceNonceInstruction(nonceAccountAddress: String, feePayer: String) throws -> TransactionInstruction {
        return try TransactionInstruction(
            keys: [
                Account.Meta(publicKey: PublicKey(string: nonceAccountAddress), isSigner: false, isWritable: true),
                Account.Meta(publicKey: RECENT_BLOCKHASHES_SYSVAR_ID, isSigner: false, isWritable: false),
                Account.Meta(publicKey: PublicKey(string: feePayer), isSigner: true, isWritable: false)
            ],
            programId: SYS_PROGRAM_ID,
            data: UInt32(4).bytes
        )
    }
}

extension SolanaSigningData {
    var commonInitiationBytes: [UInt8] {
        guard let b64DecodedData = Data(base64Encoded: feeAccountGuidHash) else {
            return []
        }
        let isEmpty = b64DecodedData.allSatisfy { $0 == 0 }
        return
            strikeFeeAmount.bytes +
            ([UInt8(isEmpty ? 0 : 1)] as [UInt8]) +
            ([UInt8](b64DecodedData))
    }
}

