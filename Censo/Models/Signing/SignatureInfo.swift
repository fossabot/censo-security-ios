//
//  SignatureInfo.swift
//  Censo
//
//  Created by Ata Namvari on 2023-01-11.
//

import Foundation

enum SignatureInfo: Encodable, Equatable {
    case offchain(OffChainSignature)
    case bitcoin(BitcoinSignatures)
    case ethereum(EthereumSignature)
    case ethereumWithOffchain(EthereumSignatureWithOffchain)
    case polygon(PolygonSignature)
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
        case .bitcoin(let request):
            try container.encode("bitcoin", forKey: .type)
            try request.encode(to: encoder)
        case .ethereum(let request):
            try container.encode("ethereum", forKey: .type)
            try request.encode(to: encoder)
        case .ethereumWithOffchain(let request):
            try container.encode("ethereum", forKey: .type)
            try request.encode(to: encoder)
        case .polygon(let request):
            try container.encode("polygon", forKey: .type)
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

struct BitcoinSignatures: Codable, Equatable  {
    let signatures: [String]
}

struct EthereumSignature: Codable, Equatable  {
    let signature: String
}

struct PolygonSignature: Codable, Equatable  {
    let signature: String
}

struct EthereumSignatureWithOffchain:  Encodable, Equatable {
    let signature: String
    var offchainSignature: OffChainSignature? = nil
    
    enum DetailsCodingKeys: String, CodingKey {
        case signature
        case offchainSignature
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DetailsCodingKeys.self)
        try container.encode(signature, forKey: .signature)
        if offchainSignature != nil {
            try container.encode(SignatureInfo.offchain(offchainSignature!), forKey: .offchainSignature)
        }
    }
}

struct PolygonSignatureWithOffchain:  Encodable, Equatable {
    let signature: String
    var offchainSignature: OffChainSignature? = nil
    
    enum DetailsCodingKeys: String, CodingKey {
        case signature
        case offchainSignature
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DetailsCodingKeys.self)
        try container.encode(signature, forKey: .signature)
        if offchainSignature != nil {
            try container.encode(SignatureInfo.offchain(offchainSignature!), forKey: .offchainSignature)
        }
    }
}
