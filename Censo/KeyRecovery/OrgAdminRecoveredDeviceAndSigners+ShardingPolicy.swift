//
//  OrgAdminRecoveredDeviceAndSigners+ShardingPolicy.swift
//  Censo
//
//  Created by Brendan Flood on 5/1/23.
//

import Foundation
import CryptoKit

extension CensoApi.OrgAdminRecoveredDeviceAndSigners {
<<<<<<< HEAD
    init(imageData: Data, deviceKey: PreauthenticatedKey<DeviceKey>, rootSeed: [UInt8], shardingPolicy: ShardingPolicy, participantId: String) throws {
=======
    init(imageData: Data, deviceKey: DeviceKey, rootSeed: [UInt8], shardingPolicy: ShardingPolicy, participantId: String, bootstrapParticipantId: String?) throws {
>>>>>>> 5d9548d (bootstrap user fix)
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
            threshold: bootstrapParticipantId != nil ? 1 : shardingPolicy.threshold,
            participants: try shardingPolicy.participants.filter(
                { $0.participantId != bootstrapParticipantId }
            ).map({
                if $0.participantId == participantId {
                    return ShardingParticipant(participantId: participantId, devicePublicKeys: [try deviceKey.key.publicExternalRepresentation().base58String])
                } else {
                    return $0
                }
                    
            })
        )

        self.signersInfo = try CensoApi.SignersInfo(
            shardingPolicy: updatedShardingPolicy,
            rootSeed: rootSeed,
            deviceKey: deviceKey
        )
    }
}
