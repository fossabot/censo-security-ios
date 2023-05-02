//
//  RecoveryAppModel.swift
//  Censo
//
//  Created by Brendan Flood on 5/1/23.
//

import Foundation
struct SignableRecoveryItem: Codable, Equatable {
    let chain: Chain
    let dataToSign: String
}
    
struct RecoveryAppSigningRequest: Codable, Equatable {
    let items: [SignableRecoveryItem]
}

struct RecoverySignatureItem: Codable, Equatable {
    let chain: Chain
    let signature: String
}

struct RecoveryAppSigningResponse: Codable, Equatable {
    let recoveryAddress: String
    let items: [RecoverySignatureItem]
}
