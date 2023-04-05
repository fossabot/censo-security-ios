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

        let secretSharer = try SecretSharer(
            secret: BigInt(rootSeed: rootSeed),
            threshold: shardingPolicy.threshold,
            participants: shardingPolicy.participants.map { try BigInt(shardingParticipant: $0) }
        )

        let participantIdToAdminUserMap = Dictionary(uniqueKeysWithValues: shardingPolicy.participants.map({ ($0.participantId, $0) }))

        let share = CensoApi.Share(
            policyRevisionId: shardingPolicy.policyRevisionGuid,
            shards: try secretSharer.shards.map { point in
                CensoApi.Shard(
                    participantId: point.x.magnitude.toHexString(),
                    shardCopies: try participantIdToAdminUserMap[point.x.magnitude.toHexString()]!.devicePublicKeys.map { devicePublicKey in
                        CensoApi.ShardCopy(
                            encryptionPublicKey: devicePublicKey,
                            encryptedData: try ECPublicKey(base58String: devicePublicKey).encrypt(data: point.y.serialize()).base64EncodedString()
                        )
                    },
                    shardId: nil,
                    shardParentId: nil
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
