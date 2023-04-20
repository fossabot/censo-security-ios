//
//  OrgAdminPolicyDetails.swift
//  Censo
//
//  Created by Brendan Flood on 2/28/23.
//

import Foundation
import SwiftUI

struct OrgAdminPolicyDetails: View {
    var request: ApprovalRequest
    var update: OrgAdminPolicyUpdate

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            FactsSection(title: "Approvals") {
                Fact("Approvals Required", "\(update.approvalPolicy.approvalsRequired)")
                Fact("Approval Expiration", "\(DateComponentsFormatter.abbreviatedFormatter.string(for: DateComponents(second: Int(update.approvalPolicy.approvalTimeout / 1000))) ?? "")")
            }

            FactsSection(title: "Org Administrators") {
                if update.approvalPolicy.approvers.count > 0 {
                    for approver in update.approvalPolicy.approvers.sorted(by: { $0.name < $1.name }) {
                        Fact(approver.name, approver.email, approver.jpegThumbnail)
                    }
                } else {
                    Fact("No users may approve requests", "")
                }
            }
            
            if update.chainFees.count > 0 {
                FactsSection(title: "Fees") {
                    for chainFee in update.chainFees {
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
struct OrgAdminPolicyDetails_Previews: PreviewProvider {
    static var previews: some View {
        OrgAdminPolicyDetails(request: .sample, update: .sample)
    }
}
#endif
