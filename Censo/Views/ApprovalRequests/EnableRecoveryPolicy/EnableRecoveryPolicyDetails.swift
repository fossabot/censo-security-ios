//
//  VaultCreationDetails.swift
//  Censo
//
//  Created by Brendan Flood on 2/28/23.
//

import Foundation
import SwiftUI

struct EnableRecoveryPolicyDetails: View {
    var request: ApprovalRequest
    var enableRecoveryContract: EnableRecoveryContract

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            FactList {
                Fact("Recovery Threshold", enableRecoveryContract.recoveryThreshold.formatted())
            }

            FactsSection(title: "Recovery Addresses") {
                for (index, recoveryAddress) in enableRecoveryContract.recoveryAddresses.enumerated() {
                    Fact("Recovery Address #\(index + 1)", recoveryAddress)
                }
            }

            if enableRecoveryContract.chainFees.count > 0 {
                FactsSection(title: "Fees") {
                    for chainFee in enableRecoveryContract.chainFees {
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
struct EnableRecoveryPolicyDetails_Previews: PreviewProvider {
    static var previews: some View {
        EnableRecoveryPolicyDetails(request: .sample, enableRecoveryContract: .sample)
    }
}
#endif
