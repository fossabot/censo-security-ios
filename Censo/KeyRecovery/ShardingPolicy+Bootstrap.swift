//
//  ShardingPolicy+Bootstrap.swift
//  Censo
//
//  Created by Ata Namvari on 2023-04-05.
//

import Foundation

extension ShardingPolicy {
    init(deviceKey: PreauthenticatedKey<DeviceKey>, bootstrapKey: PreauthenticatedKey<BootstrapKey>) throws {
        let devicePublicKeyData = try deviceKey.key.publicExternalRepresentation()
        let bootstrapPublicKeyData = try bootstrapKey.key.publicExternalRepresentation()

        let deviceShardingParticipant = ShardingParticipant(
            participantId: devicePublicKeyData[1..<33].toHexString(),
            devicePublicKeys: [devicePublicKeyData.base58String]
        )

        let bootstrapShardingParticipant = ShardingParticipant(
            participantId: bootstrapPublicKeyData[1..<33].toHexString(),
            devicePublicKeys: [bootstrapPublicKeyData.base58String]
        )

        self = ShardingPolicy(
            policyRevisionGuid: UUID().uuidString,
            threshold: 2,
            participants: [
                deviceShardingParticipant,
                bootstrapShardingParticipant
            ]
        )
    }
}
