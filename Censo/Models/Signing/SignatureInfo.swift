//
//  SignatureInfo.swift
//  Censo
//
//  Created by Ata Namvari on 2023-01-11.
//

import Foundation

enum SignatureInfo: Encodable, Equatable {
    case offchain(OffChainSignature)
    case bitcoinWithOffchain(BitcoinSignaturesWithOffchain)
    case ethereumWithOffchain(EthereumSignatureWithOffchain)
    case polygonWithOffchain(PolygonSignatureWithOffchain)

    enum DetailsCodingKeys: String, CodingKey {
        case type
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DetailsCodingKeys.self)
        switch self {
        case .offchain(let request):
            try container.encode("offchain", forKey: .type)
            try request.encode(to: encoder)
        case .bitcoinWithOffchain(let request):
            try container.encode("bitcoin", forKey: .type)
            try request.encode(to: encoder)
        case .ethereumWithOffchain(let request):
            try container.encode("ethereum", forKey: .type)
            try request.encode(to: encoder)
        case .polygonWithOffchain(let request):
            try container.encode("polygon", forKey: .type)
            try request.encode(to: encoder)
        }
        
    }
}

struct OffChainSignature: Codable, Equatable  {
    let signature: String
    let signedData: String
}

struct BitcoinSignaturesWithOffchain: Codable, Equatable  {
    let signatures: [String]
    var offchainSignature: OffChainSignature
    
    enum DetailsCodingKeys: String, CodingKey {
        case signatures
        case offchainSignature
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DetailsCodingKeys.self)
        try container.encode(signatures, forKey: .signatures)
        try container.encode(SignatureInfo.offchain(offchainSignature), forKey: .offchainSignature)
    }
}

struct EthereumSignatureWithOffchain:  Encodable, Equatable {
    let signature: String
    var offchainSignature: OffChainSignature
    
    enum DetailsCodingKeys: String, CodingKey {
        case signature
        case offchainSignature
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DetailsCodingKeys.self)
        try container.encode(signature, forKey: .signature)
        try container.encode(SignatureInfo.offchain(offchainSignature), forKey: .offchainSignature)
    }
}

struct PolygonSignatureWithOffchain:  Encodable, Equatable {
    let signature: String
    var offchainSignature: OffChainSignature
    
    enum DetailsCodingKeys: String, CodingKey {
        case signature
        case offchainSignature
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DetailsCodingKeys.self)
        try container.encode(signature, forKey: .signature)
        try container.encode(SignatureInfo.offchain(offchainSignature), forKey: .offchainSignature)
    }
}
