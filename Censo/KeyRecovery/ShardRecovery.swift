//
//  ShardRecovery.swift
//  Censo
//
//  Created by Ata Namvari on 2023-04-10.
//

import Foundation
import BigInt

struct ShardRecovery {
    struct ShardEntry {
        var shardId: String?
        var participantId: BigInt
        var parentId: String?
        var data: BigInt
    }

    enum ShardRecoveryError: Error {
        case couldNotRecover
    }

    static func recoverRootSeed(recoverShardResponse: CensoApi.RecoveryShardsResponse, deviceKey: PreauthenticatedKey<DeviceKey>, bootstrapKey: PreauthenticatedKey<BootstrapKey>?) throws -> [UInt8] {
        let allParentShards = Dictionary(
            uniqueKeysWithValues: recoverShardResponse.ancestors.map { ancestor in
                (ancestor.shardId, ancestor)
            }
        )

        let shardEntries = try recoverShardResponse.shards.map { shard in
            ShardEntry(
                shardId: shard.shardId,
                participantId: try BigInt(participantId: shard.participantId),
                parentId: shard.parentShardId,
                data: try BigInt(data: try shard.decryptedShardData(with: deviceKey, bootstrapKey: bootstrapKey))
            )
        }

        if let shard = try recoverShards(shards: shardEntries, ancestors: allParentShards).first {
            return shard.data.magnitude.serialize().padded(toByteCount: 64).bytes
        } else {
            throw ShardRecoveryError.couldNotRecover
        }
    }

    private static func recoverShards(shards: [ShardEntry], ancestors: [String?: CensoApi.AncestorShard]) throws -> [ShardEntry] {
        if shards.count <= 1 {
            return shards
        }

        let shardsByParentId = Dictionary(grouping: shards, by: \.parentId)

        let recoveredShards = try shardsByParentId.map { key, shards in
            let secret = SecretSharerUtils.recoverSecret(
                shares: shards.map { shard in
                    Point(
                        x: shard.participantId,
                        y: shard.data
                    )
                },
                order: ORDER
            )

            if let key = key, let parent = ancestors[key] {
                return ShardEntry(
                    shardId: parent.shardId,
                    participantId: try BigInt(participantId: parent.participantId),
                    parentId: parent.parentShardId,
                    data: secret
                )
            } else {
                return ShardEntry(
                    shardId: nil,
                    participantId: BigInt.zero,
                    data: secret
                )
            }
        }

        return try recoverShards(shards: recoveredShards, ancestors: ancestors)
    }
}

extension CensoApi.Shard {
    enum ShardDecryptionError: Error {
        case noMatchedKeys
    }

    func decryptedShardData(with deviceKey: PreauthenticatedKey<DeviceKey>, bootstrapKey: PreauthenticatedKey<BootstrapKey>?) throws -> Data {
        let devicePublicKey = try deviceKey.key.publicExternalRepresentation().base58String
        let bootstrapKeyPublicKey = try bootstrapKey?.key.publicExternalRepresentation().base58String
        for shardCopy in shardCopies {
            let encryptedShardData = Data(base64Encoded: shardCopy.encryptedData)!

            if shardCopy.encryptionPublicKey == devicePublicKey {
                return try deviceKey.decrypt(data: encryptedShardData)
            } else if bootstrapKeyPublicKey == shardCopy.encryptionPublicKey, let bootstrapKey = bootstrapKey {
                return try bootstrapKey.decrypt(data: encryptedShardData)
            }
        }

        throw ShardDecryptionError.noMatchedKeys
    }
}

