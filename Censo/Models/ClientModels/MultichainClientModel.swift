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

struct VaultApprovalPolicy: Codable, Equatable {
    let approvalsRequired: Int
    let approvalTimeout: UInt64
    let approvers: [VaultSigner]
}

struct VaultPolicyUpdate: Codable, Equatable  {
    var approvalPolicy: VaultApprovalPolicy
    var currentOnChainPolicies: [OnChainPolicy]
    var signingData: [SigningData]
}
