//
//  ApprovalDispositionPayload+Device.swift
//  Censo
//
//  Created by Ata Namvari on 2023-04-06.
//

import Foundation
import Moya
import CryptoKit
import BigInt

enum ApprovalDispositionPayloadError: Error {
    case unknownDeviceKey(String)
}

extension CensoApi.ApprovalDispositionPayload {
    init(
        dispositionRequest: ApprovalDispositionRequest,
        deviceKey: PreauthenticatedKey<DeviceKey>,
        bootstrapKey: PreauthenticatedKey<BootstrapKey>?,
        encryptedRootSeed: Data,
        apiProvider: MoyaProvider<CensoApi.Target>
    ) async throws {
        self.approvalDisposition = dispositionRequest.disposition
        self.requestID = dispositionRequest.request.id
        self.signatures = try await dispositionRequest.signatureInfos(using: deviceKey, encryptedRootSeed: encryptedRootSeed, apiProvider: apiProvider)

        switch dispositionRequest.request.details {
        case .orgAdminPolicyUpdate(let policyUpdate):
            self.shards = try await reshareShards(
                currentShardingPolicyGuid: policyUpdate.shardingPolicyChangeInfo.currentPolicyRevisionGuid,
                targetShardingPolicy: policyUpdate.shardingPolicyChangeInfo.targetPolicy,
                deviceKey: deviceKey,
                bootstrapKey: bootstrapKey,
                apiProvider: apiProvider
            )
        case .enableDevice(let enableDevice):
            if let currentShardingPolicyRevisionGuid = enableDevice.currentShardingPolicyRevisionGuid {
                if let targetShardingPolicy = enableDevice.targetShardingPolicy {
                    self.shards = try await reshareShards(
                        currentShardingPolicyGuid: currentShardingPolicyRevisionGuid,
                        targetShardingPolicy: targetShardingPolicy,
                        deviceKey: deviceKey,
                        bootstrapKey: bootstrapKey,
                        apiProvider: apiProvider
                    )
                }

                self.recoveryShards = try await recoveryShards(
                    forUserWithEmail: enableDevice.email,
                    newDeviceKey: try ECPublicKey(base58String: enableDevice.deviceKey),
                    currentShardingPolicyGuid: currentShardingPolicyRevisionGuid,
                    deviceKey: deviceKey,
                    bootstrapKey: bootstrapKey,
                    apiProvider: apiProvider
                )
            }
        default:
            break
        }
    }

    private func recoveryShards(
        forUserWithEmail userEmail: String,
        newDeviceKey: ECPublicKey,
        currentShardingPolicyGuid: String,
        deviceKey: PreauthenticatedKey<DeviceKey>,
        bootstrapKey: PreauthenticatedKey<BootstrapKey>?,
        apiProvider: MoyaProvider<CensoApi.Target>
    ) async throws -> [CensoApi.RecoveryShard] {
        let devicePublicKey = try deviceKey.key.publicExternalRepresentation().base58String

        let shardsResponse: CensoApi.ShardsResponse = try await apiProvider.request(
            .shards(
                policyRevisionId: currentShardingPolicyGuid,
                userId: Data(SHA256.hash(data: userEmail.data(using: .utf8)!)).toHexString(),
                deviceIdentifier: devicePublicKey
            )
        )

        return try shardsResponse
            .shards
            .map { shard in
                try shard.shardCopies.map { shardCopy in
                    let encryptedShardData = Data(base64Encoded: shardCopy.encryptedData)!

                    if shardCopy.encryptionPublicKey == devicePublicKey {
                        return CensoApi.RecoveryShard(
                            shardId: shard.shardId,
                            encryptedData: try newDeviceKey.encrypt(
                                data: try deviceKey.decrypt(data: encryptedShardData)
                            ).base64EncodedString()
                        )
                    } else if let bootstrapKey = bootstrapKey, try shardCopy.encryptionPublicKey == bootstrapKey.key.publicExternalRepresentation().base58String {
                        return CensoApi.RecoveryShard(
                            shardId: shard.shardId,
                            encryptedData: try newDeviceKey.encrypt(
                                data: try bootstrapKey.decrypt(data: encryptedShardData)
                            ).base64EncodedString()
                        )
                    } else {
                        throw ApprovalDispositionPayloadError.unknownDeviceKey(shardCopy.encryptionPublicKey)
                    }
                }
            }
            .flatMap { $0 }
    }

    private func reshareShards(
        currentShardingPolicyGuid: String,
        targetShardingPolicy: ShardingPolicy,
        deviceKey: PreauthenticatedKey<DeviceKey>,
        bootstrapKey: PreauthenticatedKey<BootstrapKey>?,
        apiProvider: MoyaProvider<CensoApi.Target>
    ) async throws -> [CensoApi.Shard] {
        let devicePublicKey = try deviceKey.key.publicExternalRepresentation().base58String
        let shardsResponse: CensoApi.ShardsResponse = try await apiProvider.request(
            .shards(
                policyRevisionId: currentShardingPolicyGuid,
                userId: nil,
                deviceIdentifier: devicePublicKey
            )
        )

        return try shardsResponse
            .shards
            .map { shard in
                try shard.shardCopies.map { shardCopy in
                    let encryptedShardData = Data(base64Encoded: shardCopy.encryptedData)!
                    let decryptedShard = try {
                        if shardCopy.encryptionPublicKey == devicePublicKey {
                            return try deviceKey.decrypt(data: encryptedShardData)
                        } else if let bootstrapKey = bootstrapKey, try shardCopy.encryptionPublicKey == bootstrapKey.key.publicExternalRepresentation().base58String {
                            return try bootstrapKey.decrypt(data: encryptedShardData)
                        } else {
                            throw ApprovalDispositionPayloadError.unknownDeviceKey(shardCopy.encryptionPublicKey)
                        }
                    }()

                    let secretSharer = try ShardingPolicySecretSharer(
                        secret: try BigInt(data: decryptedShard),
                        shardingPolicy: targetShardingPolicy
                    )

                    return try secretSharer.shardsAndParticipants.map { point, participant in
                        CensoApi.Shard(
                            participantId: participant.participantId,
                            shardCopies: try participant.devicePublicKeys.map { devicePublicKey in
                                CensoApi.ShardCopy(
                                    encryptionPublicKey: devicePublicKey,
                                    encryptedData: try ECPublicKey(base58String: devicePublicKey).encrypt(data: point.y.serialize()).base64EncodedString()
                                )
                            },
                            shardId: nil,
                            parentShardId: shard.shardId
                        )
                    }
                }
            }
            .flatMap { $0 }
            .flatMap { $0 }
    }
}
