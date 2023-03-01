//
//  VaultCreationDetails.swift
//  Censo
//
//  Created by Brendan Flood on 2/28/23.
//

import Foundation
import SwiftUI

struct VaultCreationDetails: View {
    var request: ApprovalRequest
    var vaultCreation: VaultCreation

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            FactList {
                Fact("Vault Name", vaultCreation.name)
            }

            FactsSection(title: "Approvals") {
                Fact("Approvals Required", "\(vaultCreation.approvalPolicy.approvalsRequired)")
                Fact("Approval Expiration", "\(DateComponentsFormatter.abbreviatedFormatter.string(for: DateComponents(second: Int(vaultCreation.approvalPolicy.approvalTimeout / 1000))) ?? "")")
            }

            FactsSection(title: "Vault Managers") {
                if vaultCreation.approvalPolicy.approvers.count > 0 {
                    for approver in vaultCreation.approvalPolicy.approvers {
                        Fact(approver.name, approver.email)
                    }
                } else {
                    Fact("No users may approve requests", "")
                }
            }
            if vaultCreation.chainFees.count > 0 {
                FactsSection(title: "Fees") {
                    for chainFee in vaultCreation.chainFees {
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
struct VaultCreationDetails_Previews: PreviewProvider {
    static var previews: some View {
        VaultCreationDetails(request: .sample, vaultCreation: .sample)
    }
}
#endif
