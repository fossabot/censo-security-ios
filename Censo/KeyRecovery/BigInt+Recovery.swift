//
//  BigInt+Recovery.swift
//  Censo
//
//  Created by Ata Namvari on 2023-04-05.
//

import Foundation
import BigInt

extension BigInt {
    enum BigIntConversionError: Error {
        case badParticipantId
        case badRootSeed
        case badData
    }

    init(shardingParticipant: ShardingParticipant) throws {
        guard let bigInt = BigInt(shardingParticipant.participantId, radix: 16) else {
            throw BigIntConversionError.badParticipantId
        }

        self = bigInt
    }

    init(rootSeed: [UInt8]) throws {
        guard let bigInt = BigInt(rootSeed.toHexString(), radix: 16) else {
            throw BigIntConversionError.badRootSeed
        }

        self = bigInt
    }

    init(data: Data) throws {
        guard let bigInt = BigInt(data.toHexString(), radix: 16) else {
            throw BigIntConversionError.badData
        }

        self = bigInt
    }
}

extension BigUInt {
    func toHexString() -> String {
        self.serialize().toHexString()
    }
}
