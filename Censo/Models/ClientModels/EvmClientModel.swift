//
//  EvmClientModel.swift
//  Censo
//
//  Created by Brendan Flood on 2/5/23.
//

import Foundation

enum EvmTokenInfo: Codable, Equatable {
    case erc20(contractAddress: String)
    case erc721(contractAddress: String, tokenId: String)
    case erc1155(contractAddress: String, tokenId: String)
    
    enum CodingKeys: String, CodingKey {
        case type
        case contractAddress
        case tokenId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        let contractAddress = try container.decode(String.self, forKey: .contractAddress)
        switch type {
        case "ERC20":
            self = .erc20(contractAddress: contractAddress)
        case "ERC721":
            let tokenId = try container.decode(String.self, forKey: .tokenId)
            self = .erc721(contractAddress: contractAddress, tokenId: tokenId)
        case "ERC1155":
            let tokenId = try container.decode(String.self, forKey: .tokenId)
            self = .erc1155(contractAddress: contractAddress, tokenId: tokenId)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "unrecognized type \(type)")
        }
    }

    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .erc20(let contractAddress):
            try container.encode("ERC20", forKey: .type)
            try container.encode(contractAddress, forKey: .contractAddress)
        case .erc721(let contractAddress, let tokenId):
            try container.encode("ERC721", forKey: .type)
            try container.encode(contractAddress, forKey: .contractAddress)
            try container.encode(tokenId, forKey: .tokenId)
        case .erc1155(let contractAddress, let tokenId):
            try container.encode("ERC1155", forKey: .type)
            try container.encode(contractAddress, forKey: .contractAddress)
            try container.encode(tokenId, forKey: .tokenId)
        }
    }
}

struct OnChainPolicy: Codable, Equatable {
    let owners: [String]
    let threshold: Int
    let chain: Chain
}

struct ContractNameAndAddress: Codable, Equatable {
    let name: String
    let address: String
}

struct EvmTransaction: Codable, Equatable {
    let safeNonce: UInt64
    let chainId: UInt64
    var vaultAddress: String? = nil
    var contractAddresses: [ContractNameAndAddress] = []
}

struct EvmSymbolInfo: Codable, Equatable {
    let symbol: String
    let description: String
    let tokenInfo: EvmTokenInfo?
    let imageUrl: String?
    let nftMetadata: NftMetadata?
}

#if DEBUG

extension EvmTokenInfo {
    static var sample: Self {
        EvmTokenInfo.erc20(contractAddress: "address")
    }
}

extension EvmSymbolInfo {
    static var sample: Self {
        EvmSymbolInfo(
            symbol: "ETH",
            description: "Ethereum",
            tokenInfo: .sample,
            imageUrl: nil,
            nftMetadata: nil
        )
    }
}
extension EvmTransaction {
    static var sample: Self {
        EvmTransaction(safeNonce: 0, chainId: 1, vaultAddress: "", contractAddresses: [])
    }
}

extension OnChainPolicy {
    static var sample: Self {
        OnChainPolicy(owners: ["onwer1"], threshold: 1, chain: Chain.censo)
    }
}
#endif
