//
//  OrgAdminPolicyRow.swift
//  Censo
//
//  Created by Brendan Flood on 2/28/23.
//

import Foundation
import SwiftUI


struct OrgAdminPolicyRow: View {
    var requestType: ApprovalRequestType
    var update: OrgAdminPolicyUpdate

    var body: some View {
        VStack(spacing: 8) {
            Text(requestType.header)
                .font(.title2)
                .bold()
                .lineLimit(1)
                .allowsTightening(true)
                .minimumScaleFactor(0.25)
                .padding(EdgeInsets(top: 15, leading: 20, bottom: 20, trailing: 20))
        }
    }
}


#if DEBUG
struct OrgAdminPolicyRow_Previews: PreviewProvider {
    static var previews: some View {
        OrgAdminPolicyRow(requestType: .orgAdminPolicyUpdate(.sample), update: .sample)
            .preferredColorScheme(.light)
    }
}

extension ShardingParticipant {
    static var sample: Self {
        ShardingParticipant(
            participantId: "01234",
            devicePublicKeys: ["publicKey1"]
        )
    }
}
extension ShardingPolicy {
    static var sample: Self {
        ShardingPolicy(
            policyRevisionGuid: "1234",
            threshold: 1,
            participants: [.sample])
    }
}

extension ShardingPolicyChangeInfo {
    static var sample: Self {
        ShardingPolicyChangeInfo(
            currentPolicyRevisionGuid: "01234",
            targetPolicy: .sample)
    }
}

extension OrgAdminPolicyUpdate {
    static var sample: Self {
        OrgAdminPolicyUpdate(
            approvalPolicy: .sample,
            currentOnChainPolicies: [.sample],
            signingData: [SigningData.ethereum(signingData: .sample)],
            chainFees: [.sample, .sample2],
            shardingPolicyChangeInfo: .sample
        )
    }
}

#endif
