//
//  OrgAdminRecoverySignaturesRequest.swift
//  Censo
//
//  Created by Brendan Flood on 5/1/23.
//

import Foundation

struct OrgAdminRecoverySignaturesRequest: Codable, Equatable {
    let recoveryAddress: String
    let signatures: [RecoverySignature]
    
    static func fromRecoveryAppSigningResponse(myOrgAdminRecoveryRequest: OrgAdminRecoveryRequest, recoveryAppSigningResponse: RecoveryAppSigningResponse) throws -> OrgAdminRecoverySignaturesRequest{
        return OrgAdminRecoverySignaturesRequest(
            recoveryAddress: recoveryAppSigningResponse.recoveryAddress,
            signatures: try recoveryAppSigningResponse.items.map({
                switch $0.chain {
                case Chain.ethereum:
                    return .ethereum(signature: $0.signature)
                case Chain.polygon:
                    return .polygon(signature: $0.signature)
                default:
                    return .offchain(signature: $0.signature, dataToSign: try myOrgAdminRecoveryRequest.toJsonString().base64EncodedString())
                }
            })
        )
    }
}

enum RecoverySignature: Codable, Equatable {
    case ethereum(signature: String)
    case polygon(signature: String)
    case offchain(signature: String, dataToSign: String)
    
    enum CodingKeys: String, CodingKey {
        case type
        case signature
        case dataToSign
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        let signature = try container.decode(String.self, forKey: .signature)
        switch type {
        case "ethereum":
            self = .ethereum(signature: signature)
        case "polygon":
            self = .polygon(signature: signature)
        case "offchain":
            let dataToSign = try container.decode(String.self, forKey: .dataToSign)
            self = .offchain(signature: signature, dataToSign: dataToSign)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "unrecognized type \(type)")
        }
    }

    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .ethereum(let signature):
            try container.encode("ethereum", forKey: .type)
            try container.encode(signature, forKey: .signature)
        case .polygon(let signature):
            try container.encode("polygon", forKey: .type)
            try container.encode(signature, forKey: .signature)
        case .offchain(let signature, let dataToSign):
            try container.encode("polygon", forKey: .type)
            try container.encode(signature, forKey: .signature)
            try container.encode(dataToSign, forKey: .dataToSign)
        }
    }
}
