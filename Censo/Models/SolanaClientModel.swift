//
//  SolanaClientModel.swift
//  Censo
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

enum Chain: String, Codable {
    case solana = "solana"
    case bitcoin = "bitcoin"
    case ethereum = "ethereum"
}

enum LogoType: String, Codable {
    case png = "png"
    case jpeg = "jpeg"
    case svg = "svg"
    case ico = "ico"
}


struct ApprovalRequest: Codable, Equatable {
    let id: String
    let submitterName: String
    let submitterEmail: String
    let submitDate: Date
    let approvalTimeoutInSeconds: Int?
    let numberOfDispositionsRequired: Int
    let numberOfApprovalsReceived: Int
    let numberOfDeniesReceived: Int
    let vaultName: String?
    let initiationOnly: Bool
    let details: SolanaApprovalRequestDetails
}

extension ApprovalRequest {
    var requestType: SolanaApprovalRequestType {
        switch details {
        case .multisigOpInitiation(_, let requestType):
            return requestType
        case .approval(let requestType):
            return requestType
        }
    }
}


enum SolanaApprovalRequestType: Codable, Equatable {
    case withdrawalRequest(WithdrawalRequest)
    case conversionRequest(ConversionRequest)
    case wrapConversionRequest(WrapConversionRequest)
    case signersUpdate(SignersUpdate)
    case walletCreation(WalletCreation)
    case balanceAccountNameUpdate(BalanceAccountNameUpdate)
    case balanceAccountPolicyUpdate(BalanceAccountPolicyUpdate)
    case balanceAccountSettingsUpdate(BalanceAccountSettingsUpdate)
    case balanceAccountAddressWhitelistUpdate(BalanceAccountAddressWhitelistUpdate)
    case addressBookUpdate(AddressBookUpdate)
    case dAppBookUpdate(DAppBookUpdate)
    case walletConfigPolicyUpdate(WalletConfigPolicyUpdate)
    case dAppTransactionRequest(DAppTransactionRequest)
    case loginApproval(LoginApproval)
    case acceptVaultInvitation(AcceptVaultInvitation)
    case passwordReset(PasswordReset)
    case signData(SignData)
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
        case "WrapConversionRequest":
            self = .wrapConversionRequest(try WrapConversionRequest(from: decoder))
        case "SignersUpdate":
            self = .signersUpdate(try SignersUpdate(from: decoder))
        case "WalletCreation":
            self = .walletCreation(try WalletCreation(from: decoder))
        case "BalanceAccountNameUpdate":
            self = .balanceAccountNameUpdate(try BalanceAccountNameUpdate(from: decoder))
        case "BalanceAccountPolicyUpdate":
            self = .balanceAccountPolicyUpdate(try BalanceAccountPolicyUpdate(from: decoder))
        case "BalanceAccountSettingsUpdate":
            self = .balanceAccountSettingsUpdate(try BalanceAccountSettingsUpdate(from: decoder))
        case "BalanceAccountAddressWhitelistUpdate":
            self = .balanceAccountAddressWhitelistUpdate(try BalanceAccountAddressWhitelistUpdate(from: decoder))
        case "CreateAddressBookEntry":
            self = .addressBookUpdate(try AddressBookUpdate(from: decoder))
        case "DeleteAddressBookEntry":
            self = .addressBookUpdate(try AddressBookUpdate(from: decoder))
        case "DAppBookUpdate":
            self = .dAppBookUpdate(try DAppBookUpdate(from: decoder))
        case "WalletConfigPolicyUpdate":
            self = .walletConfigPolicyUpdate(try WalletConfigPolicyUpdate(from: decoder))
        case "DAppTransactionRequest":
            self = .dAppTransactionRequest(try DAppTransactionRequest(from: decoder))
        case "LoginApproval":
            self = .loginApproval(try LoginApproval(from: decoder))
        case "AcceptVaultInvitation":
            self = .acceptVaultInvitation(try AcceptVaultInvitation(from: decoder))
        case "PasswordReset":
            self = .passwordReset(try PasswordReset(from: decoder))
        case "SignData":
            self = .signData(try SignData(from: decoder))
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
        case .wrapConversionRequest(let wrapConversionRequest):
            try container.encode("WrapConversionRequest", forKey: .type)
            try wrapConversionRequest.encode(to: encoder)
        case .signersUpdate(let signersUpdate):
            try container.encode("SignersUpdate", forKey: .type)
            try signersUpdate.encode(to: encoder)
        case .walletCreation(let walletCreation):
            try container.encode("WalletCreation", forKey: .type)
            try walletCreation.encode(to: encoder)
        case .balanceAccountNameUpdate(let balanceAccountNameUpdate):
            try container.encode("BalanceAccountNameUpdate", forKey: .type)
            try balanceAccountNameUpdate.encode(to: encoder)
        case .balanceAccountPolicyUpdate(let balanceAccountPolicyUpdate):
            try container.encode("BalanceAccountPolicyUpdate", forKey: .type)
            try balanceAccountPolicyUpdate.encode(to: encoder)
        case .balanceAccountSettingsUpdate(let balanceAccountSettingsUpdate):
            try container.encode("BalanceAccountSettingsUpdate", forKey: .type)
            try balanceAccountSettingsUpdate.encode(to: encoder)
        case .balanceAccountAddressWhitelistUpdate(let balanceAccountAddressWhitelistUpdate):
            try container.encode("BalanceAccountAddressWhitelistUpdate", forKey: .type)
            try balanceAccountAddressWhitelistUpdate.encode(to: encoder)
        case .addressBookUpdate(let addressBookUpdate):
            try addressBookUpdate.encode(to: encoder)
        case .dAppBookUpdate(let dAppBookUpdate):
            try container.encode("DAppBookUpdate", forKey: .type)
            try dAppBookUpdate.encode(to: encoder)
        case .walletConfigPolicyUpdate(let walletConfigPolicyUpdate):
            try container.encode("WalletConfigPolicyUpdate", forKey: .type)
            try walletConfigPolicyUpdate.encode(to: encoder)
        case .dAppTransactionRequest(let dAppTransactionRequest):
            try container.encode("DAppTransactionRequest", forKey: .type)
            try dAppTransactionRequest.encode(to: encoder)
        case .loginApproval(let loginApproval):
            try container.encode("LoginApproval", forKey: .type)
            try loginApproval.encode(to: encoder)
        case .acceptVaultInvitation(let acceptVaultInvitation):
            try container.encode("AcceptVaultInvitation", forKey: .type)
            try acceptVaultInvitation.encode(to: encoder)
        case .passwordReset(let passwordReset):
            try container.encode("PasswordReset", forKey: .type)
            try passwordReset.encode(to: encoder)
        case .signData(let signData):
            try container.encode("SignData", forKey: .type)
            try signData.encode(to: encoder)
        case .unknown:
            try container.encode("Unknown", forKey: .type)
        }
    }
}

enum SolanaApprovalRequestDetails: Codable, Equatable {
    case approval(SolanaApprovalRequestType)
    case multisigOpInitiation(MultisigOpInitiation, requestType: SolanaApprovalRequestType)

    enum DetailsCodingKeys: String, CodingKey {
        case type
        case details
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DetailsCodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "MultisigOpInitiation":
            let requestType = try container.decode(SolanaApprovalRequestType.self, forKey: .details)
            let initiation = try MultisigOpInitiation(from: decoder)
            self = .multisigOpInitiation(initiation, requestType: requestType)
        default:
            self = .approval(try SolanaApprovalRequestType(from: decoder))
        }
    }

    func encode(to encoder: Encoder) throws {
        switch self {
        case .multisigOpInitiation(let multisigOpInitiation, let request):
            var container = encoder.container(keyedBy: DetailsCodingKeys.self)
            try container.encode("MultisigOpInitiation", forKey: .type)
            try container.encode(request, forKey: .details)
            try multisigOpInitiation.encode(to: encoder)
        case .approval(let request):
            try request.encode(to: encoder)
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

enum EthTokenType: String, Codable {
    case ERC20 = "ERC20"
    case ERC721 = "ERC721"
    case ERC1155 = "ERC1155"
}

struct EthTokenInfo: Codable, Equatable {
    let tokenId: String?
    let tokenType: EthTokenType
}

struct SymbolInfo: Codable, Equatable {
    let symbol: String
    let symbolDescription: String
    let tokenMintAddress: String?
    let imageUrl: String?
    let nftMetadata: NftMetadata?
    let ethTokenInfo: EthTokenInfo?
}

struct SymbolAndAmountInfo: Codable, Equatable {
    let symbolInfo: SymbolInfo
    let amount: String
    let usdEquivalent: String?
    let fee: Fee?
    let replacementFee: Fee?
}

struct Fee: Codable, Equatable {
    let symbolInfo: SymbolInfo
    let amount: String
    let usdEquivalent: String?
}

struct AccountInfo: Codable, Equatable {
    let name: String
    let identifier: String
    let accountType: AccountType
    let address: String?
    let chain: Chain?
}

struct TransactionInput: Codable, Equatable {
    let txId: String
    let index: Int
    let amount: Int64
    let inputScriptHex: String
    let base64HashForSignature: String
}

struct TransactionOutput: Codable, Equatable {
    let index: Int
    let amount: Int64
    let pubKeyScriptHex: String
    let address: String
    let isChange: Bool
}

struct BitcoinTransaction: Codable, Equatable {
    let version: Int
    let txIns: [TransactionInput]
    let txOuts: [TransactionOutput]
    let totalFee: Int64
}

struct EthereumTransaction: Codable, Equatable {
    let safeNonce: UInt64
    let chainId: UInt64
}

enum SigningData: Codable, Equatable {
    case bitcoin(BitcoinSigningData)
    case solana(SolanaSigningData)
    case ethereum(EthereumSigningData)

    enum SigningDataCodingKeys: String, CodingKey {
        case type
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SigningDataCodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "bitcoin":
            self = .bitcoin(try BitcoinSigningData(from: decoder))
        case "ethereum":
            self = .ethereum(try EthereumSigningData(from: decoder))
        default:
            self = .solana(try SolanaSigningData(from: decoder))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SigningDataCodingKeys.self)

        switch self {
        case .bitcoin(let request):
            try container.encode("bitcoin", forKey: .type)
            try request.encode(to: encoder)
        case .ethereum(let request):
            try container.encode("ethereum", forKey: .type)
            try request.encode(to: encoder)
        case .solana(let request):
            try container.encode("solana", forKey: .type)
            try request.encode(to: encoder)
        }
    }
}


struct BitcoinSigningData: Codable, Equatable {
    let childKeyIndex: UInt32
    let transaction: BitcoinTransaction
}

struct EthereumSigningData: Codable, Equatable {
    let transaction: EthereumTransaction
}

struct SolanaSigningData: Codable, Equatable {
    let feePayer: String
    let walletProgramId: String
    let multisigOpAccountAddress: String
    let walletAddress: String
    let nonceAccountAddresses: [String]
    let nonceAccountAddressesSlot: UInt64
    let initiator: String
    let strikeFeeAmount: UInt64
    let feeAccountGuidHash: String
    let walletGuidHash: String
    var dataToSign: String?
}

struct SignerInfo: Codable, Equatable {
    let publicKey: String
    let name: String
    let email: String
    let nameHashIsEmpty: Bool
}

struct SolanaDApp: Codable, Equatable {
    let address: String
    let name: String
    let logo: String
}

struct SlotSignerInfo: Codable, Equatable {
    let slotId: UInt8
    let value: SignerInfo
}

struct SlotDestinationInfo: Codable, Equatable {
    let slotId: UInt8
    let value: DestinationAddress
}

struct SlotDAppInfo: Codable, Equatable {
    let slotId: UInt8
    let value: SolanaDApp
}

struct ApprovalPolicy: Codable, Equatable {
    let approvalsRequired: UInt8
    let approvalTimeout: UInt64
    let approvers: [SlotSignerInfo]
}

struct WhitelistUpdate: Codable, Equatable {
    let account: AccountInfo
    let destinationsToAdd: [SlotDestinationInfo]
    let destinationsToRemove: [SlotDestinationInfo]
}

struct NftMetadata: Codable, Equatable {
    let name: String
}

struct WithdrawalRequest: Codable, Equatable  {
    var account: AccountInfo
    var symbolAndAmountInfo: SymbolAndAmountInfo
    var destination: DestinationAddress
    var signingData: SigningData
}

struct ConversionRequest: Codable, Equatable {
    var account: AccountInfo
    var symbolAndAmountInfo: SymbolAndAmountInfo
    var destination: DestinationAddress
    var destinationSymbolInfo: SymbolInfo
    var signingData: SolanaSigningData
}

struct WrapConversionRequest: Codable, Equatable {
    var account: AccountInfo
    var symbolAndAmountInfo: SymbolAndAmountInfo
    var destinationSymbolInfo: SymbolInfo
    var signingData: SolanaSigningData
}

struct SolanaInstructionChunk: Codable, Equatable {
    var offset: UInt16
    var instructionData: String
}

struct DAppTransactionRequest: Codable, Equatable  {
    struct SymbolAndAmountInfo: Codable, Equatable {
        struct SymbolInfo: Codable, Equatable {
            let symbol: String
            let symbolDescription: String
        }

        let symbolInfo: SymbolInfo
        let amount: String
        let usdEquivalent: String?
    }

    var account: AccountInfo
    var dappInfo: SolanaDApp
    var balanceChanges: [SymbolAndAmountInfo]
    var instructions: [SolanaInstructionChunk]
    var signingData: SolanaSigningData
}

struct SignersUpdate: Codable, Equatable  {
    var slotUpdateType: SlotUpdateType
    var signer: SlotSignerInfo
    var signingData: SolanaSigningData
}

struct WalletCreation: Codable, Equatable  {
    var accountSlot: UInt8
    var accountInfo: AccountInfo
    var approvalPolicy: ApprovalPolicy
    var whitelistEnabled: BooleanSetting
    var dappsEnabled: BooleanSetting
    var addressBookSlot: UInt8
    var signingData: SolanaSigningData?
}

struct BalanceAccountNameUpdate: Codable, Equatable  {
    var accountInfo: AccountInfo
    var newAccountName: String
    var signingData: SolanaSigningData
}

struct BalanceAccountPolicyUpdate: Codable, Equatable  {
    var accountInfo: AccountInfo
    var approvalPolicy: ApprovalPolicy
    var signingData: SolanaSigningData
}

struct BalanceAccountSettingsUpdate: Codable, Equatable  {
    enum Change: Equatable {
        case whitelistEnabled(Bool)
        case dappsEnabled(Bool)
    }

    var account: AccountInfo
    var change: Change
    var signingData: SolanaSigningData

    enum CodingKeys: String, CodingKey {
        case account
        case whitelistEnabled
        case dappsEnabled
        case signingData
    }

    init(account: AccountInfo, change: Change, signingData: SolanaSigningData) {
        self.account = account
        self.change = change
        self.signingData = signingData
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.account = try container.decode(AccountInfo.self, forKey: .account)
        self.signingData = try container.decode(SolanaSigningData.self, forKey: .signingData)

        let whitelistEnabled = try container.decode(BooleanSetting?.self, forKey: .whitelistEnabled)
        let dappsEnabled = try container.decode(BooleanSetting?.self, forKey: .dappsEnabled)

        if let whitelistEnabled = whitelistEnabled, dappsEnabled == nil {
            self.change = .whitelistEnabled(whitelistEnabled == .On)
        } else if let dappsEnabled = dappsEnabled, whitelistEnabled == nil {
            self.change = .dappsEnabled(dappsEnabled == .On)
        } else {
            throw DecodingError.dataCorruptedError(forKey: .whitelistEnabled, in: container, debugDescription: "Only one setting should be changed")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(account, forKey: .account)
        try container.encode(signingData, forKey: .signingData)

        switch change {
        case .whitelistEnabled(let bool):
            try container.encode(bool ? BooleanSetting.On : .Off, forKey: .whitelistEnabled)
        case .dappsEnabled(let bool):
            try container.encode(bool ? BooleanSetting.On : .Off, forKey: .dappsEnabled)
        }
    }
}

struct BalanceAccountAddressWhitelistUpdate: Codable, Equatable  {
    var accountInfo: AccountInfo
    var destinations: [SlotDestinationInfo]
    var signingData: SolanaSigningData
}

struct AddressBookUpdate: Codable, Equatable  {
    enum Change {
        case add
        case remove
    }

    var chain: Chain
    var change: Change
    var entry: SlotDestinationInfo
    var signingData: SolanaSigningData?

    init(chain: Chain, change: Change, entry: SlotDestinationInfo, signingData: SolanaSigningData?) {
        self.chain = chain
        self.change = change
        self.entry = entry
        self.signingData = signingData
    }

    enum CodingKeys: String, CodingKey {
        case type
        case chain
        case name
        case address
        case slotId
        case signingData
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.chain = try container.decode(Chain.self, forKey: .chain)
        
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "CreateAddressBookEntry":
            self.change = Change.add
        case "DeleteAddressBookEntry":
            self.change = Change.remove
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid address book change type")
        }
        
        self.entry = SlotDestinationInfo(
            slotId: try container.decode(UInt8.self, forKey: .slotId),
            value: DestinationAddress(
                name: try container.decode(String.self, forKey: .name),
                subName: nil,
                address: try container.decode(String.self, forKey: .address),
                tag: nil
            )
        )

        self.signingData = try container.decodeIfPresent(SolanaSigningData.self, forKey: .signingData)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch change {
        case .add:
            try container.encode("CreateAddressBookEntry", forKey: .type)
        case .remove:
            try container.encode("DeleteAddressBookEntry", forKey: .type)
        }

        try container.encode(chain, forKey: .chain)
        try container.encode(entry.slotId, forKey: .slotId)
        try container.encode(entry.value.name, forKey: .name)
        try container.encode(entry.value.address, forKey: .address)
        
        try container.encode(signingData, forKey: .signingData)
    }
}

struct DAppBookUpdate: Codable, Equatable  {
    var entriesToAdd: [SlotDAppInfo]
    var entriesToRemove: [SlotDAppInfo]
    var signingData: SolanaSigningData
}

struct WalletConfigPolicyUpdate: Codable, Equatable  {
    var approvalPolicy: ApprovalPolicy
    var signingData: SolanaSigningData
}

struct MultisigAccountCreationInfo: Codable, Equatable  {
    var accountSize: UInt64
    var minBalanceForRentExemption: UInt64
}

struct MultisigOpInitiation: Codable, Equatable {
    let opAccountCreationInfo: MultisigAccountCreationInfo
    let initiatorIsApprover: Bool
}

protocol SolanaSignable {
    func signableData(approverPublicKey: String) throws -> Data
}

protocol SignableData {
    func signableData(approverPublicKey: String) throws -> Data
    func signableDataList(approverPublicKey: String) throws -> [Data]
}

struct LoginApproval: Codable, Equatable  {
    var jwtToken: String
    var email: String
    var name: String
}

struct AcceptVaultInvitation: Codable, Equatable  {
    var vaultGuid: String
    var vaultName: String
}

struct PasswordReset: Codable, Equatable  {}

struct SignData: Codable, Equatable  {
    var base64Data: String
    var signingData: SolanaSigningData
}

struct SignDataApprovalRequestJson: Codable, Equatable  {
    var data: SolanaApprovalRequestType
}

struct NoChainSignature: Codable, Equatable  {
    let signature: String
    let signedData: String
}

struct SolanaSignature: Codable, Equatable  {
    let signature: String
    let nonce: String
    let nonceAccountAddress: String
}

struct BitcoinSignatures: Codable, Equatable  {
    let signatures: [String]
}

struct EthereumSignature: Codable, Equatable {
    let signature: String
}

enum SignatureType: Codable, Equatable {
    case nochain(NoChainSignature)
    case solana(SolanaSignature)
    case bitcoin(BitcoinSignatures)
    case ethereum(EthereumSignature)
    case unknown

    enum DetailsCodingKeys: String, CodingKey {
        case type
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DetailsCodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "nochain":
            self = .nochain(try NoChainSignature(from: decoder))
        case "solana":
            self = .solana(try SolanaSignature(from: decoder))
        case "bitcoin":
            self = .bitcoin(try BitcoinSignatures(from: decoder))
        case "ethereum":
            self = .ethereum(try EthereumSignature(from: decoder))
        default:
            self = .unknown
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DetailsCodingKeys.self)
        switch self {
        case .nochain(let request):
            try container.encode("nochain", forKey: .type)
            try request.encode(to: encoder)
        case .solana(let request):
            try container.encode("solana", forKey: .type)
            try request.encode(to: encoder)
        case .bitcoin(let request):
            try container.encode("bitcoin", forKey: .type)
            try request.encode(to: encoder)
        case .ethereum(let request):
            try container.encode("ethereum", forKey: .type)
            try request.encode(to: encoder)
        case .unknown:
            try container.encode("unknown", forKey: .type)
        }
    }
}

extension SolanaApprovalRequestDetails {
    var nonceAccountAddresses: [String] {
        switch self {
        case .approval(let requestType):
            return requestType.nonceAccountAddresses
        case .multisigOpInitiation(_, let requestType):
            return requestType.nonceAccountAddresses
        }
    }
}

extension SolanaSigningData {
    func addDataToSign(dataToSign: String) -> Self {
        return SolanaSigningData(feePayer: self.feePayer,
                                 walletProgramId: self.walletProgramId,
                                 multisigOpAccountAddress: self.multisigOpAccountAddress,
                                 walletAddress: self.walletAddress,
                                 nonceAccountAddresses: self.nonceAccountAddresses,
                                 nonceAccountAddressesSlot: self.nonceAccountAddressesSlot,
                                 initiator: self.initiator,
                                 strikeFeeAmount: self.strikeFeeAmount,
                                 feeAccountGuidHash: self.feeAccountGuidHash,
                                 walletGuidHash: self.walletGuidHash,
                                 dataToSign: dataToSign)
    }
}

extension SolanaApprovalRequestType {
    var nonceAccountAddresses: [String] {
        switch self {
        case .dAppTransactionRequest(let request):
            return request.signingData.nonceAccountAddresses
        case .addressBookUpdate(let request):
            return request.signingData?.nonceAccountAddresses ?? []
        case .walletCreation(let request):
            return request.signingData?.nonceAccountAddresses ?? []
        case .balanceAccountNameUpdate(let request):
            return request.signingData.nonceAccountAddresses
        case .balanceAccountPolicyUpdate(let request):
            return request.signingData.nonceAccountAddresses
        case .balanceAccountSettingsUpdate(let request):
            return request.signingData.nonceAccountAddresses
        case .balanceAccountAddressWhitelistUpdate(let request):
            return request.signingData.nonceAccountAddresses
        case .conversionRequest(let request):
            return request.signingData.nonceAccountAddresses
        case .dAppBookUpdate(let request):
            return request.signingData.nonceAccountAddresses
        case .signersUpdate(let request):
            return request.signingData.nonceAccountAddresses
        case .withdrawalRequest(let request):
            switch request.signingData {
            case .solana(let signingData):
                return signingData.nonceAccountAddresses
            default:
                return []
            }
        case .walletConfigPolicyUpdate(let request):
            return request.signingData.nonceAccountAddresses
        case .wrapConversionRequest(let request):
            return request.signingData.nonceAccountAddresses
        case .signData(let request):
            return request.signingData.nonceAccountAddresses
        case .loginApproval,
             .acceptVaultInvitation,
             .passwordReset,
             .unknown:
            return []
        }
    }
}

extension SolanaApprovalRequestType {
    var nonceAccountAddressesSlot: UInt64 {
        switch self {
        case .dAppTransactionRequest(let request):
            return request.signingData.nonceAccountAddressesSlot
        case .addressBookUpdate(let request):
            return request.signingData?.nonceAccountAddressesSlot ?? 0
        case .walletCreation(let request):
            return request.signingData?.nonceAccountAddressesSlot ?? 0
        case .balanceAccountNameUpdate(let request):
            return request.signingData.nonceAccountAddressesSlot
        case .balanceAccountPolicyUpdate(let request):
            return request.signingData.nonceAccountAddressesSlot
        case .balanceAccountSettingsUpdate(let request):
            return request.signingData.nonceAccountAddressesSlot
        case .balanceAccountAddressWhitelistUpdate(let request):
            return request.signingData.nonceAccountAddressesSlot
        case .conversionRequest(let request):
            return request.signingData.nonceAccountAddressesSlot
        case .dAppBookUpdate(let request):
            return request.signingData.nonceAccountAddressesSlot
        case .signersUpdate(let request):
            return request.signingData.nonceAccountAddressesSlot
        case .withdrawalRequest(let request):
            switch request.signingData {
            case .solana(let signingData):
                return signingData.nonceAccountAddressesSlot
            default:
                return 0
            }
        case .walletConfigPolicyUpdate(let request):
            return request.signingData.nonceAccountAddressesSlot
        case .wrapConversionRequest(let request):
            return request.signingData.nonceAccountAddressesSlot
        case .signData(let request):
            return request.signingData.nonceAccountAddressesSlot
        case .loginApproval,
             .acceptVaultInvitation,
             .passwordReset,
             .unknown:
            return 0
        }
    }
}

#if DEBUG
extension ApprovalRequest {
    static var sample: Self {
        ApprovalRequest(
            id: "id",
            submitterName: "John Q",
            submitterEmail: "johnq@gmail.com",
            submitDate: Date(),
            approvalTimeoutInSeconds: 40000,
            numberOfDispositionsRequired: 3,
            numberOfApprovalsReceived: 1,
            numberOfDeniesReceived: 1,
            vaultName: "Test Vault",
            initiationOnly: false,
            details: .approval(.withdrawalRequest(.sample))
        )
    }

    static var sample2: Self {
        ApprovalRequest(
            id: "id",
            submitterName: "John Q",
            submitterEmail: "johnq@gmail.com",
            submitDate: Date(),
            approvalTimeoutInSeconds: 40000,
            numberOfDispositionsRequired: 3,
            numberOfApprovalsReceived: 1,
            numberOfDeniesReceived: 1,
            vaultName: "Test Vault",
            initiationOnly: false,
            details: .approval(.conversionRequest(.sample))
        )
    }
    
    static var feeBump: Self {
        ApprovalRequest(
            id: "id",
            submitterName: "John Q",
            submitterEmail: "johnq@gmail.com",
            submitDate: Date(),
            approvalTimeoutInSeconds: 40000,
            numberOfDispositionsRequired: 3,
            numberOfApprovalsReceived: 1,
            numberOfDeniesReceived: 1,
            vaultName: "Test Vault",
            initiationOnly: false,
            details: .approval(.withdrawalRequest(.feeBump))
        )
    }
}

extension WithdrawalRequest {
    static var sample: Self {
        WithdrawalRequest(
            account: .sample,
            symbolAndAmountInfo: .sample,
            destination: .sample,
            signingData: .solana(.sample)
        )
    }
    
    static var feeBump: Self {
        WithdrawalRequest(
            account: .sample,
            symbolAndAmountInfo: .feeBump,
            destination: .sample,
            signingData: .solana(.sample)
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
            walletAddress: "walletAddress",
            nonceAccountAddresses: ["nonceAccountAddress"],
            nonceAccountAddressesSlot: 12345,
            initiator: "initiatorAddress",
            strikeFeeAmount: 234567,
            feeAccountGuidHash: "feeAccountGuidHash",
            walletGuidHash: "walletGuidHash"
        )
    }
}

extension AccountInfo {
    static var sample: Self {
        AccountInfo(
            name: "Main",
            identifier: "identifier",
            accountType: AccountType.BalanceAccount,
            address: "83746gfd8bj7",
            chain: nil
        )
    }
}

extension SymbolAndAmountInfo {
    static var sample: Self {
        SymbolAndAmountInfo(
            symbolInfo: .sample,
            amount: "234325.000564",
            usdEquivalent: "2353453",
            fee: Fee(
                symbolInfo: .sample,
                amount: "0.0000123",
                usdEquivalent: "10.12"
            ),
            replacementFee: nil
        )
    }
    
    static var feeBump: Self {
        SymbolAndAmountInfo(
            symbolInfo: .sample,
            amount: "234325.000564",
            usdEquivalent: "2353453",
            fee: Fee(
                symbolInfo: .sample,
                amount: "0.0000123",
                usdEquivalent: "10.12"
            ),
            replacementFee: Fee(
                symbolInfo: .sample,
                amount: "0.0000246",
                usdEquivalent: "20.24"
            )
        )
    }
}

extension SymbolInfo {
    static var sample: Self {
        SymbolInfo(
            symbol: "BTC",
            symbolDescription: "Bitcoin",
            tokenMintAddress: "28548397fdsf",
            imageUrl: nil,
            nftMetadata: nil,
            ethTokenInfo: nil
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
