//
//  MultichainClientModel.swift
//  Censo
//
//  Created by Brendan Flood on 2/4/23.
//

import Foundation

enum SigningData: Codable, Equatable {
    case ethereum(signingData: EthereumSigningData)
    case polygon(signingData: PolygonSigningData)
    
    enum CodingKeys: String, CodingKey {
        case type
        case transaction
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "ethereum":
            self = .ethereum(signingData: try EthereumSigningData(from: decoder))
        case "polygon":
            self = .polygon(signingData: try PolygonSigningData(from: decoder))
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "unrecognized type \(type)")
        }
    }

    
    func encode(to encoder: Encoder) throws {
        switch self {
        case .ethereum(let signingData):
            try signingData.encode(to: encoder)
        case .polygon(let signingData):
            try signingData.encode(to: encoder)
        }
    }
}

struct VaultSigner: Codable, Equatable {
    let name: String
    let email: String
    let publicKeys: [ChainPubkey]
    let nameHashIsEmpty: Bool
    let jpegThumbnail: String?
}

struct ChainPubkey: Codable, Equatable {
    let chain: Chain
    let key: String
}

struct ChainFee: Codable, Equatable {
    let chain: Chain
    let fee: Amount
    let feeSymbolInfo: EvmSymbolInfo
}

struct VaultApprovalPolicy: Codable, Equatable {
    let approvalsRequired: Int
    let approvalTimeout: UInt64
    let approvers: [VaultSigner]
}

struct VaultPolicyUpdate: Codable, Equatable  {
    var approvalPolicy: VaultApprovalPolicy
    var currentOnChainPolicies: [OnChainPolicy]
    var vaultName: String
    var signingData: [SigningData]
    var chainFees: [ChainFee]
}

struct VaultNameUpdate: Codable, Equatable  {
    var oldName: String
    var newName: String
    var signingData: [SigningData]
    var chainFees: [ChainFee]
}

struct VaultCreation: Codable, Equatable  {
    var approvalPolicy: VaultApprovalPolicy
    var name: String
    var signingData: [SigningData]
    var chainFees: [ChainFee]
}

struct ShardingPolicyChangeInfo : Codable, Equatable  {
    var currentPolicyRevisionGuid: String
    var targetPolicy: ShardingPolicy
}

struct OrgAdminPolicyUpdate: Codable, Equatable  {
    var approvalPolicy: VaultApprovalPolicy
    var currentOnChainPolicies: [OnChainPolicy]
    var signingData: [SigningData]
    var chainFees: [ChainFee]
    var shardingPolicyChangeInfo: ShardingPolicyChangeInfo
}

struct RecoveryContractPolicyUpdate: Codable, Equatable {
    var recoveryThreshold: Int
    var recoveryAddresses: [String]
    var currentOnChainPolicies: [OnChainPolicy]
    var signingData: [SigningData]
    var chainFees: [ChainFee]
    var recoveryContractAddress: String
    var isEnabled: Bool
}


enum RecoverySafeTx: Codable, Equatable {
    case orgVaultSwapOwner(prev: String)
    case vaultSwapOwner(prev: String, vaultSafeAddress: String)
    case walletSwapOwner(prev: String, vaultSafeAddress: String, walletSafeAddress: String)
    
    enum CodingKeys: String, CodingKey {
        case type
        case prev
        case vaultSafeAddress
        case walletSafeAddress
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        let prev = try container.decode(String.self, forKey: .prev)
        switch type {
        case "OrgVaultSwapOwner":
            self = .orgVaultSwapOwner(prev: prev)
        case "VaultSwapOwner":
            let vaultSafeAddress = try container.decode(String.self, forKey: .vaultSafeAddress)
            self = .vaultSwapOwner(prev: prev, vaultSafeAddress: vaultSafeAddress)
        case "WalletSwapOwner":
            let vaultSafeAddress = try container.decode(String.self, forKey: .vaultSafeAddress)
            let walletSafeAddress = try container.decode(String.self, forKey: .walletSafeAddress)
            self = .walletSwapOwner(prev: prev, vaultSafeAddress: vaultSafeAddress, walletSafeAddress: walletSafeAddress)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "unrecognized type \(type)")
        }
    }

    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .orgVaultSwapOwner(let prev):
            try container.encode("OrgVaultSwapOwner", forKey: .type)
            try container.encode(prev, forKey: .prev)
        case .vaultSwapOwner(let prev, let vaultSafeAddress):
            try container.encode("VaultSwapOwner", forKey: .type)
            try container.encode(prev, forKey: .prev)
            try container.encode(vaultSafeAddress, forKey: .vaultSafeAddress)
        case .walletSwapOwner(let prev, let vaultSafeAddress, let walletSafeAddress):
            try container.encode("WalletSwapOwner", forKey: .type)
            try container.encode(prev, forKey: .prev)
            try container.encode(vaultSafeAddress, forKey: .vaultSafeAddress)
            try container.encode(walletSafeAddress, forKey: .walletSafeAddress)
        }
    }
}

struct AdminRecoveryTxs: Codable, Equatable  {
    var chain: Chain
    var recoveryContractAddress: String
    var orgVaultSafeAddress: String
    var oldOwnerAddress: String
    var newOwnerAddress: String
    var txs: [RecoverySafeTx]
}

struct RecoveryPolicy: Codable, Equatable  {
    var threshold: Int
    var addresses: [String]
}

struct OrgAdminRecoveryRequestEnvelope: Codable, Equatable  {
    var request: OrgAdminRecoveryRequest
    var recoveryPolicy: RecoveryPolicy
    var signaturesReceivedFrom: [String]
}

struct OrgAdminRecoveryRequest: Codable, Equatable  {
    var deviceKey: String
    var chainKeys: [PublicKey]
    var recoveryTxs: [AdminRecoveryTxs]
    var signingData: [SigningData]
}

