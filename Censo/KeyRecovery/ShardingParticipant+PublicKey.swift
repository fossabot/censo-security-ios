//
//  ShardingParticipant+PublicKey.swift
//  Censo
//
//  Created by Ata Namvari on 2023-04-05.
//

import Foundation

extension ShardingParticipant {
    enum PublicKeyError: Error {
        case invalidPublicKey
    }

    init(publicKeyData: Data) throws {
        guard publicKeyData.count == 65 else {
            throw PublicKeyError.invalidPublicKey
        }

        self.participantId = publicKeyData[1..<33].toHexString()
        self.devicePublicKeys = [publicKeyData.base58String]
    }
}
