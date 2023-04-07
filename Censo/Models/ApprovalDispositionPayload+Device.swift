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
        registeredDevice: RegisteredDevice,
        apiProvider: MoyaProvider<CensoApi.Target>
    ) async throws {
        self.approvalDisposition = dispositionRequest.disposition
        self.requestID = dispositionRequest.request.id
        self.signatures = try await dispositionRequest.signatureInfos(using: registeredDevice, apiProvider: apiProvider)

        switch dispositionRequest.request.details {
        case .orgAdminPolicyUpdate(let policyUpdate):
            self.shards = try await reshareShards(
                currentShardingPolicyGuid: policyUpdate.shardingPolicyChangeInfo.currentPolicyRevisionGuid,
                targetShardingPolicy: policyUpdate.shardingPolicyChangeInfo.targetPolicy,
                registeredDevice: registeredDevice,
                apiProvider: apiProvider
            )
        case .addDevice(let addDevice):
            if let currentShardingPolicyRevisionGuid = addDevice.currentShardingPolicyRevisionGuid {
                if let targetShardingPolicy = addDevice.targetShardingPolicy {
                    self.shards = try await reshareShards(
                        currentShardingPolicyGuid: currentShardingPolicyRevisionGuid,
                        targetShardingPolicy: targetShardingPolicy,
                        registeredDevice: registeredDevice,
                        apiProvider: apiProvider
                    )
                }

                self.recoveryShards = try await recoveryShards(
                    forUserWithEmail: addDevice.email,
                    newDeviceKey: try ECPublicKey(base58String: addDevice.deviceKey),
                    currentShardingPolicyGuid: currentShardingPolicyRevisionGuid,
                    registeredDevice: registeredDevice,
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
        registeredDevice: RegisteredDevice,
        apiProvider: MoyaProvider<CensoApi.Target>
    ) async throws -> [CensoApi.RecoveryShard] {
        let devicePublicKey = try registeredDevice.devicePublicKey()

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
                                data: try registeredDevice.decrypt(encryptedShardData)
                            ).base64EncodedString()
                        )
                    } else if let bootstrapKey = registeredDevice.bootstrapKey, try shardCopy.encryptionPublicKey == bootstrapKey.publicExternalRepresentation().base58String {
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
        registeredDevice: RegisteredDevice,
        apiProvider: MoyaProvider<CensoApi.Target>
    ) async throws -> [CensoApi.Shard] {
        let devicePublicKey = try registeredDevice.devicePublicKey()
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
                            return try registeredDevice.decrypt(encryptedShardData)
                        } else if let bootstrapKey = registeredDevice.bootstrapKey, try shardCopy.encryptionPublicKey == bootstrapKey.publicExternalRepresentation().base58String {
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
                            shardParentId: shard.shardId
                        )
                    }
                }
            }
            .flatMap { $0 }
            .flatMap { $0 }
    }
}
