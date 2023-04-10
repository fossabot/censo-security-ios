//
//  SignersInfo+Recovery.swift
//  Censo
//
//  Created by Ata Namvari on 2023-04-05.
//

import Foundation
import BigInt

extension CensoApi.SignersInfo {
    init(shardingPolicy: ShardingPolicy, rootSeed: [UInt8], deviceKey: DeviceKey) throws {
        let privateKeys = try PrivateKeys(rootSeed: rootSeed)
        let signers = privateKeys.publicKeys.walletSigners

        let secretSharer = try ShardingPolicySecretSharer(
            secret: BigInt(rootSeed: rootSeed),
            shardingPolicy: shardingPolicy
        )

        let share = CensoApi.Share(
            policyRevisionId: shardingPolicy.policyRevisionGuid,
            shards: try secretSharer.shardsAndParticipants.map { point, participant in
                CensoApi.Shard(
                    participantId: point.x.magnitude.toHexString(),
                    shardCopies: try participant.devicePublicKeys.map { devicePublicKey in
                        CensoApi.ShardCopy(
                            encryptionPublicKey: devicePublicKey,
                            encryptedData: try ECPublicKey(base58String: devicePublicKey).encrypt(data: point.y.serialize()).base64EncodedString()
                        )
                    },
                    shardId: nil,
                    parentShardId: nil
                )
            }
        )

        self = CensoApi.SignersInfo(
            signers: signers,
            signature: try deviceKey.signature(for: signers.dataToSign).base64EncodedString(),
            share: share
        )
    }
}

struct ShardingPolicySecretSharer {
    let secretSharer: SecretSharer
    let shardsAndParticipants: [(Point, ShardingParticipant)]

    enum PolicyShardingError: Error {
        case notAllParticipantsSharded
    }

    init(secret: BigInt, shardingPolicy: ShardingPolicy) throws {
        self.secretSharer = try SecretSharer(
            secret: secret,
            threshold: shardingPolicy.threshold,
            participants: shardingPolicy.participants.map { try BigInt(shardingParticipant: $0) }
        )

        let participantIdToAdminUserMap = Dictionary(uniqueKeysWithValues: shardingPolicy.participants.map({ ($0.participantId, $0) }))

        self.shardsAndParticipants = try secretSharer.shards.map { point in
            if let participant = participantIdToAdminUserMap[point.x.magnitude.toHexString()] {
                return (point, participant)
            } else {
                throw PolicyShardingError.notAllParticipantsSharded
            }
        }
    }
}
