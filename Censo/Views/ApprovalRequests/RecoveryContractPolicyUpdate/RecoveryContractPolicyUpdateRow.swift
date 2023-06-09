//
//  EnableRecoveryPolicyRow.swift
//  Censo
//
//  Created by Ben Holzman on 3/30/23.
//

import Foundation
import SwiftUI


struct RecoveryContractPolicyUpdateRow: View {
    var requestType: ApprovalRequestType
    var recoveryContractPolicyUpdate: RecoveryContractPolicyUpdate

    var body: some View {
        VStack(spacing: 8) {
            Text(requestType.header)
                .font(.title2)
                .bold()
                .lineLimit(1)
                .allowsTightening(true)
                .minimumScaleFactor(0.25)
                .padding(EdgeInsets(top: 15, leading: 20, bottom: 0, trailing: 20))
        }
    }
}


#if DEBUG
struct RecoveryContractPolicyUpdateRow_Previews: PreviewProvider {
    static var previews: some View {
        RecoveryContractPolicyUpdateRow(requestType: .recoveryContractPolicyUpdate(.sample), recoveryContractPolicyUpdate: .sample)
            .preferredColorScheme(.light)
    }
}

extension RecoveryContractPolicyUpdate {
    static var sample: Self {
        RecoveryContractPolicyUpdate(
            recoveryThreshold: 2,
            recoveryAddresses: ["0x0101010101010101010101010101010101010101",
                                "0x0101010101010101010101010101010101010102",
                                "0x0101010101010101010101010101010101010103"],
            currentOnChainPolicies: [],
            signingData: [],
            chainFees: [],
            recoveryContractAddress: "",
            isEnabled: false
        )
    }
}

#endif
