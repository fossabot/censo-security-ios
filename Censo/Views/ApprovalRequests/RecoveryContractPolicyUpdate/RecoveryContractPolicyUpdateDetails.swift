//
//  VaultCreationDetails.swift
//  Censo
//
//  Created by Brendan Flood on 2/28/23.
//

import Foundation
import SwiftUI

struct RecoveryContractPolicyUpdateDetails: View {
    var request: ApprovalRequest
    var recoveryContractPolicyUpdate: RecoveryContractPolicyUpdate

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            FactList {
                Fact("Recovery Threshold", recoveryContractPolicyUpdate.recoveryThreshold.formatted())
            }

            FactsSection(title: "Recovery Addresses") {
                for (index, recoveryAddress) in recoveryContractPolicyUpdate.recoveryAddresses.enumerated() {
                    Fact("Recovery Address #\(index + 1)", recoveryAddress)
                }
            }

            if recoveryContractPolicyUpdate.chainFees.count > 0 {
                FactsSection(title: "Fees") {
                    for chainFee in recoveryContractPolicyUpdate.chainFees {
                        if let feeInUsd = chainFee.fee.formattedUSDEquivalent {
                            Fact("\(chainFee.chain.rawValue.capitalized) Fee Estimate", "\(feeInUsd) USD")
                        }
                    }
                }
            }
        }
    }
}

#if DEBUG
struct RecoveryContractPolicyUpdateDetails_Previews: PreviewProvider {
    static var previews: some View {
        RecoveryContractPolicyUpdateDetails(request: .sample, recoveryContractPolicyUpdate: .sample)
    }
}
#endif
