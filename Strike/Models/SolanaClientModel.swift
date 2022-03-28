//
//  SolanaClientModel.swift
//  Strike
//
//  Created by Ata Namvari on 2022-03-07.
//

import Foundation

enum ApprovalDisposition: String, Codable {
    case Approve
    case Deny

    func toSolanaProgramValue() -> UInt8 {
        switch self {
        case .Approve:
            return 1
        case .Deny:
            return 2
        }
    }
}

enum SlotUpdateType: String, Codable {
    case SetIfEmpty
    case Clear
    
    func toSolanaProgramValue() -> UInt8 {
        switch self {
        case .SetIfEmpty:
            return 0
        case .Clear:
            return 1
        }
    }
}

enum BooleanSetting: String, Codable {
    case Off
    case On
    
    func toSolanaProgramValue() -> UInt8 {
        switch self {
        case .Off:
            return 0
        case .On:
            return 1
        }
    }
}

enum WalletType: String, Codable {
    case Solana = "Solana"
}

struct ApprovalDispositionRequestResponse: Codable, Equatable {
    let signature: String
    let approvalDisposition: ApprovalDisposition
    let recentBlockhash: String
}

struct WalletApprovalRequest: Codable, Equatable {
    let id: String
    let walletType: WalletType
    let submitterName: String
    let submitterEmail: String
    let submitDate: Date
    let approvalTimeoutInSeconds: Int
    let numberOfDispositionsRequired: Int
    let numberOfApprovalsReceived: Int
    let numberOfDeniesReceived: Int
    let requestType: SolanaApprovalRequestType

    private enum CodingKeys: String, CodingKey {
        case id,
             walletType,
             submitterName,
             submitterEmail,
             submitDate,
             approvalTimeoutInSeconds,
             numberOfDispositionsRequired,
             numberOfApprovalsReceived,
             numberOfDeniesReceived,
             requestType = "details"
    }

    init(id: String,
                walletType: WalletType,
                submitterName: String,
                submitterEmail: String,
                submitDate: Date,
                approvalTimeoutInSeconds: Int,
                numberOfDispositionsRequired: Int,
                numberOfApprovalsReceived: Int,
                numberOfDeniesReceived: Int,
                requestType: SolanaApprovalRequestType) {
        self.id = id
        self.walletType = walletType
        self.submitterName = submitterName
        self.submitterEmail = submitterEmail
        self.submitDate = submitDate
        self.approvalTimeoutInSeconds = approvalTimeoutInSeconds
        self.numberOfDispositionsRequired = numberOfDispositionsRequired
        self.numberOfApprovalsReceived = numberOfApprovalsReceived
        self.numberOfDeniesReceived = numberOfDeniesReceived
        self.requestType = requestType
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.walletType = try container.decode(WalletType.self, forKey: .walletType)
        self.submitterName = try container.decode(String.self, forKey: .submitterName)
        self.submitterEmail = try container.decode(String.self, forKey: .submitterEmail)
        self.submitDate = try container.decode(Date.self, forKey: .submitDate)
        self.approvalTimeoutInSeconds = try container.decode(Int.self, forKey: .approvalTimeoutInSeconds)
        self.numberOfDispositionsRequired = try container.decode(Int.self, forKey: .numberOfDispositionsRequired)
        self.numberOfApprovalsReceived = try container.decode(Int.self, forKey: .numberOfApprovalsReceived)
        self.numberOfDeniesReceived = try container.decode(Int.self, forKey: .numberOfDeniesReceived)
        self.requestType = try container.decodeIfPresent(SolanaApprovalRequestType.self, forKey: .requestType) ?? .unknown
    }
}

indirect enum SolanaApprovalRequestType: Codable, Equatable {

    case withdrawalRequest(WithdrawalRequest)
    case conversionRequest(ConversionRequest)
    case signersUpdate(SignersUpdate)
    case balanceAccountCreation(BalanceAccountCreation)
    case multisigOpInitiation(MultisigOpInitiation)
    case unknown

    enum DetailsCodingKeys: String, CodingKey {
        case type
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DetailsCodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "WithdrawalRequest":
            self = .withdrawalRequest(try WithdrawalRequest(from: decoder))
        case "ConversionRequest":
            self = .conversionRequest(try ConversionRequest(from: decoder))
        case "SignersUpdate":
            self = .signersUpdate(try SignersUpdate(from: decoder))
        case "BalanceAccountCreation":
            self = .balanceAccountCreation(try BalanceAccountCreation(from: decoder))
        case "MultisigOpInitiation":
            self = .multisigOpInitiation(try MultisigOpInitiation(from: decoder))
        default:
            self = .unknown
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DetailsCodingKeys.self)
        switch self {
        case .withdrawalRequest(let withdrawalRequest):
            try container.encode("WithdrawalRequest", forKey: .type)
            try withdrawalRequest.encode(to: encoder)
        case .conversionRequest(let conversionRequest):
            try container.encode("ConversionRequest", forKey: .type)
            try conversionRequest.encode(to: encoder)
        case .signersUpdate(let signersUpdate):
            try container.encode("SignersUpdate", forKey: .type)
            try signersUpdate.encode(to: encoder)
        case .balanceAccountCreation(let balanceAccountCreation):
            try container.encode("BalanceAccountCreation", forKey: .type)
            try balanceAccountCreation.encode(to: encoder)
        case .multisigOpInitiation(let multisigOpInitiation):
            try container.encode("MultisigOpInitiation", forKey: .type)
            try multisigOpInitiation.encode(to: encoder)
        case .unknown:
            try container.encode("Unknown", forKey: .type)
        }
    }
}

struct DestinationAddress: Codable, Equatable {
    let name: String
    let subName: String?
    let address: String
    let tag: String?
}

enum AccountType: String, Codable {
    case BalanceAccount = "BalanceAccount"
    case StakeAccount = "StakeAccount"
}

struct SymbolInfo: Codable, Equatable {
    let symbol: String
    let symbolDescription: String
    let tokenMintAddress: String
}

struct SymbolAndAmountInfo: Codable, Equatable {
    let symbolInfo: SymbolInfo
    let amount: String
    let usdEquivalent: String?
}

struct AccountInfo: Codable, Equatable {
    let name: String
    let identifier: String
    let accountType: AccountType
    let address: String?
}

struct SolanaSigningData: Codable, Equatable {
    let feePayer: String
    let walletProgramId: String
    let multisigOpAccountAddress: String
    let walletAddress: String
}

struct SignerInfo: Codable, Equatable {
    let publicKey: String
    let name: String
    let email: String
}

struct SlotSignerInfo: Codable, Equatable {
    let slotId: UInt8
    let value: SignerInfo
}

struct WithdrawalRequest: Codable, Equatable  {
    var account: AccountInfo
    var symbolAndAmountInfo: SymbolAndAmountInfo
    var destination: DestinationAddress
    var signingData: SolanaSigningData
}

struct ConversionRequest: Codable, Equatable {
    var account: AccountInfo
    var symbolAndAmountInfo: SymbolAndAmountInfo
    var destination: DestinationAddress
    var destinationSymbolInfo: SymbolInfo
    var signingData: SolanaSigningData
}

struct SignersUpdate: Codable, Equatable  {
    var slotUpdateType: SlotUpdateType
    var signer: SlotSignerInfo
    var signingData: SolanaSigningData
}

struct BalanceAccountCreation: Codable, Equatable  {
    var accountSlot: UInt8
    var accountInfo: AccountInfo
    var approvalsRequired: UInt8
    var approvalTimeout: UInt64
    var approvers: [SlotSignerInfo]
    var whitelistEnabled: BooleanSetting
    var dappsEnabled: BooleanSetting
    var addressBookSlot: UInt8
    var signingData: SolanaSigningData
}

struct MultisigAccountCreationInfo: Codable, Equatable  {
    var accountSize: UInt64
    var minBalanceForRentExemption: UInt64
}

struct MultisigOpInitiation: Codable, Equatable  {
    let details: SolanaApprovalRequestType
    let opAccountCreationInfo: MultisigAccountCreationInfo
    let dataAccountCreationInfo: MultisigAccountCreationInfo?
}


protocol SolanaSignable {
    func signableData(approverPublicKey: String) throws -> Data
}

#if DEBUG
extension WalletApprovalRequest {
    static var sample: Self {
        WalletApprovalRequest(
            id: "id",
            walletType: .Solana,
            submitterName: "John Q",
            submitterEmail: "johnq@gmail.com",
            submitDate: Date(),
            approvalTimeoutInSeconds: 40000,
            numberOfDispositionsRequired: 3,
            numberOfApprovalsReceived: 1,
            numberOfDeniesReceived: 1,
            requestType: .withdrawalRequest(.sample)
        )
    }

    static var sample2: Self {
        WalletApprovalRequest(
            id: "id",
            walletType: .Solana,
            submitterName: "John Q",
            submitterEmail: "johnq@gmail.com",
            submitDate: Date(),
            approvalTimeoutInSeconds: 40000,
            numberOfDispositionsRequired: 3,
            numberOfApprovalsReceived: 1,
            numberOfDeniesReceived: 1,
            requestType: .conversionRequest(.sample)
        )
    }
}

extension WithdrawalRequest {
    static var sample: Self {
        WithdrawalRequest(
            account: .sample,
            symbolAndAmountInfo: .sample,
            destination: .sample,
            signingData: .sample
        )
    }
}

extension DestinationAddress {
    static var sample: Self {
        DestinationAddress(
            name: "Dest",
            subName: "Sub",
            address: "32853987g87h",
            tag: nil
        )
    }
}

extension SolanaSigningData {
    static var sample: Self {
        SolanaSigningData(
            feePayer: "feePayer",
            walletProgramId: "walletPrgramId",
            multisigOpAccountAddress: "multisigAddress",
            walletAddress: "walletAddress"
        )
    }
}

extension AccountInfo {
    static var sample: Self {
        AccountInfo(
            name: "Main",
            identifier: "identifier",
            accountType: AccountType.BalanceAccount,
            address: "83746gfd8bj7"
        )
    }
}

extension SymbolAndAmountInfo {
    static var sample: Self {
        SymbolAndAmountInfo(
            symbolInfo: .sample,
            amount: "234325.000564",
            usdEquivalent: "2353453"
        )
    }
}

extension SymbolInfo {
    static var sample: Self {
        SymbolInfo(
            symbol: "BTC",
            symbolDescription: "Bitcoin",
            tokenMintAddress: "28548397fdsf"
        )
    }
}

extension ConversionRequest {
    static var sample: Self {
        ConversionRequest(
            account: .sample,
            symbolAndAmountInfo: .sample,
            destination: .sample,
            destinationSymbolInfo: .sample,
            signingData: .sample
        )
    }
}

#endif
