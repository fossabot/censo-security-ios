//
//  OrgAdminRecoveredDeviceAndSigners+ShardingPolicy.swift
//  Censo
//
//  Created by Brendan Flood on 5/1/23.
//

import Foundation
import CryptoKit

extension CensoApi.OrgAdminRecoveredDeviceAndSigners {
    init(imageData: Data, deviceKey: PreauthenticatedKey<DeviceKey>, rootSeed: [UInt8], shardingPolicy: ShardingPolicy, participantId: String) throws {
        self.userDevice = CensoApi.UserDevice(
            publicKey: try deviceKey.key.publicExternalRepresentation().base58String,
            deviceType: .ios,
            userImage: CensoApi.UserImage(
                image: imageData.base64EncodedString(),
                type: .jpeg,
                signature: try deviceKey.signature(for: Data(SHA256.hash(data: imageData))).base64EncodedString()
            ),
            replacingDeviceIdentifier: nil
        )

        let updatedShardingPolicy = ShardingPolicy(
            policyRevisionGuid: shardingPolicy.policyRevisionGuid,
            threshold: shardingPolicy.threshold,
            participants: try shardingPolicy.participants.map({
                if $0.participantId == participantId {
                    return ShardingParticipant(participantId: participantId, devicePublicKeys: [try deviceKey.key.publicExternalRepresentation().base58String])
                } else {
                    return $0
                }
                    
            })
        )

        self.signersInfo = try CensoApi.SignersInfo(
            shardingPolicy: shardingPolicy,
            rootSeed: rootSeed,
            deviceKey: deviceKey
        )
    }
}
