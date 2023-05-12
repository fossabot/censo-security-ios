//
//  SharedClientModel.swift
//  Censo
//
//  Created by Ata Namvari on 2022-03-07.
//

import Foundation

enum ApprovalDisposition: String, Codable {
    case Approve
    case Deny
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
    case bitcoin = "bitcoin"
    case ethereum = "ethereum"
    case polygon = "polygon"
    case offchain = "offchain"
}

enum LogoType: String, Codable {
    case png = "png"
    case jpeg = "jpeg"
    case svg = "svg"
    case ico = "ico"
}

enum AddressBookChange {
    case add
    case remove
}

struct AddressBookEntry: Codable, Equatable {
    var chain: Chain
    var name: String
    var address: String
}

struct AddressBookUpdate: Equatable {
    var change: AddressBookChange
    var entry: AddressBookEntry
}

struct DestinationAddress: Codable, Equatable {
    let name: String
    let subName: String?
    let address: String
    let tag: String?
}

struct Amount: Codable, Equatable {
    let value: String
    let nativeValue: String
    let usdEquivalent: String?
}

extension Amount {
    enum AmountError: Error {
        case invalidDecimal
    }

    var fundamentalAmount: UInt64 {
        get throws {
            guard let decimal = Decimal(string: value) else { throw AmountError.invalidDecimal }

            let precisionParts = value.components(separatedBy: ".")
            let decimals = precisionParts.count == 1 ? 0 : precisionParts[1].count

            return NSDecimalNumber(decimal: decimal * pow(10, decimals)).uint64Value
        }
    }

    var fundamentalAmountBignum: Bignum {
        get throws {
            if !nativeValue.starts(with: value) {
                throw AmountError.invalidDecimal
            }
            return Bignum(number: nativeValue.replacingOccurrences(of: ".", with: ""), withBase: 10)
        }
    }
    
    var isNegative: Bool {
        get {
            return value.hasPrefix("-")
        }
    }
}

struct WalletInfo: Codable, Equatable {
    let name: String
    let identifier: String
    let address: String
}

struct SignerInfo: Codable, Equatable {
    let publicKey: String
    let name: String
    let email: String
    let nameHashIsEmpty: Bool
    let jpegThumbnail: String?
}

struct ApprovalPolicy: Codable, Equatable {
    let approvalsRequired: Int
    let approvalTimeout: UInt64
    let approvers: [SignerInfo]
}

struct ShardingParticipant: Codable, Equatable {
    let participantId: String
    let devicePublicKeys: [String]
}

struct ShardingPolicy: Codable, Equatable {
    let policyRevisionGuid: String
    let threshold: Int
    let participants: [ShardingParticipant]
}

struct NftMetadata: Codable, Equatable {
    let name: String
}


struct LoginApproval: Codable, Equatable  {
    var jwtToken: String
    var email: String
    var name: String
}

// TODO: This may not be needed
struct PasswordReset: Codable, Equatable  {}

enum DeviceType: String, Codable {
    case ios = "ios"
    case android = "android"
    
    var description : String {
        switch self {
        case .ios: return "iOS"
        case .android: return "Android"
        }
      }
}

struct EnableDevice: Codable, Equatable  {
    var name: String
    var email: String
    var jpegThumbnail: String
    var deviceGuid: String
    var deviceKey: String
    var deviceType: DeviceType
    var firstTime: Bool
    var currentShardingPolicyRevisionGuid: String?
    var targetShardingPolicy: ShardingPolicy?
    var replacingDeviceGuid: String?
}

struct DisableDevice: Codable, Equatable  {
    var name: String
    var email: String
    var jpegThumbnail: String
    var deviceGuid: String
    var deviceKey: String
    var deviceType: DeviceType
}

struct OrgNameUpdate: Codable, Equatable  {
    var oldName: String
    var newName: String
}

enum VaultUserRoleEnum: String, Codable {
    case Viewer = "Viewer"
    case TransactionSubmitter = "TransactionSubmitter"
    
    var description : String {
        switch self {
        case .Viewer: return "Viewer"
        case .TransactionSubmitter: return "Transaction Submitter"
        }
    }
}

struct VaultUserRole: Codable, Equatable {
    let name: String
    let email: String
    let jpegThumbnail: String?
    let role: VaultUserRoleEnum
}

struct VaultUserRolesUpdate: Codable, Equatable  {
    let vaultName: String
    let userRoles: [VaultUserRole]
}

struct SuspendUser: Codable, Equatable  {
    let name: String
    let email: String
    let jpegThumbnail: String?
}

struct RestoreUser: Codable, Equatable  {
    let name: String
    let email: String
    let jpegThumbnail: String?
}

struct EvmSimulatedChange: Codable, Equatable {
    let amount: Amount
    let symbolInfo: EvmSymbolInfo
}

struct DAppInfo: Codable, Equatable {
    let name: String
    let url: String
    let description: String
    let icons: [String]
}

struct EvmTransactionParams: Codable, Equatable {
    let from: String
    let to: String
    let value: String
    let data: String
}

enum DAppParams: Codable, Equatable {
    case ethSendTransaction(EthSendTransaction)
    case ethSign(EthSign)
    case ethSignTypedData(EthSignTypedData)

    enum DAppParamsTypeCodingKeys: String, CodingKey {
        case type
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DAppParamsTypeCodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "EthSendTransaction":
            self = .ethSendTransaction(try EthSendTransaction(from: decoder))
        case "EthSign":
            self = .ethSign(try EthSign(from: decoder))
        case "EthSignTypedData":
            self = .ethSignTypedData(try EthSignTypedData(from: decoder))
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid dApp Param Type")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DAppParamsTypeCodingKeys.self)
        switch self {
        case .ethSendTransaction(let ethSendTransaction):
            try container.encode("EthSendTransaction", forKey: .type)
            try ethSendTransaction.encode(to: encoder)
        case .ethSign(let ethSign):
            try container.encode("EthSign", forKey: .type)
            try ethSign.encode(to: encoder)
        case .ethSignTypedData(let ethSignTypedData):
            try container.encode("EthSignTypedData", forKey: .type)
            try ethSignTypedData.encode(to: encoder)
        }
    }
}

struct EthSendTransaction: Codable, Equatable {
    let simulatedChanges: [EvmSimulatedChange]
    let transaction: EvmTransactionParams
}

struct EthSign: Codable, Equatable {
    let message: String
    let messageHash: String
}

struct EthSignTypedData: Codable, Equatable {
    let eip712Data: String
    let messageHash: String
}


struct PublicKey: Codable, Equatable {
    let key: String
    let chain: Chain
}

extension EthSign {
    func displayMessage() -> String {
        if let decoded = String(bytes: message.data(using: .hexadecimal)!, encoding: .utf8) {
            let alphaCount = decoded.filter { $0.isLetter || $0.isNumber || $0.isWhitespace || $0.isSymbol }.count
            if (Float(alphaCount) / Float(decoded.count) >= 0.66) {
                return decoded
            } else {
                return message
            }
        } else {
            return message
        }
    }
}

extension EthSignTypedData {
    func structuredData() -> EIP712TypedData? {
        return try? JSONDecoder().decode(EIP712TypedData.self, from: eip712Data.data(using: .utf8)!)
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
            vaultName: "BlueRock Securities",
            initiationOnly: false,
            details: .bitcoinWithdrawalRequest(.sample)
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
            details: .bitcoinWithdrawalRequest(.sample)
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
            details: .bitcoinWithdrawalRequest(.sample)
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

extension WalletInfo {
    static var sample: Self {
        WalletInfo(
            name: "Main",
            identifier: "identifier",
            address: "83746gfd8bj7"
        )
    }
}

extension Amount {
    static var sample: Self {
        Amount(
            value: "234325.000564",
            nativeValue: "234325.00056400",
            usdEquivalent: "2353453"
        )
    }
    static var feeSample: Self {
        Amount(
            value: "0.000564",
            nativeValue: "0.00056400",
            usdEquivalent: "6.53"
        )
    }
}


#endif
