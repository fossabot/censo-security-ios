//
//  BalanceAccountPolicyDetails.swift
//  Censo
//
//  Created by Ata Namvari on 2022-05-03.
//

import Foundation
import SwiftUI

struct WalletTransferPolicyDetails: View {
    var request: ApprovalRequest
    var update: TransferPolicyUpdate
    var user: CensoApi.User

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            FactsSection(title: "Approvals") {
                Fact("Approvals Required", "\(update.approvalPolicy.approvalsRequired)")
                Fact("Approval Expiration", "\(DateComponentsFormatter.abbreviatedFormatter.string(for: DateComponents(second: Int(update.approvalPolicy.approvalTimeout / 1000))) ?? "")")
            }

            FactsSection(title: "Transfer Approvers") {
                if update.approvalPolicy.approvers.count > 0 {
                    for approver in update.approvalPolicy.approvers.sorted(by: { $0.name < $1.name }) {
                        Fact(approver.name, approver.email, approver.jpegThumbnail)
                    }
                } else {
                    Fact("No users may approve requests", "")
                }
            }
            if let feeInUsd = update.fee.formattedUSDEquivalent {
                FactsSection(title: "Fees") {
                    Fact("Fee Estimate", "\(feeInUsd) USD")
                }
            }
        }
    }
}

#if DEBUG
struct WalletTransferPolicyDetails_Previews: PreviewProvider {
    static var previews: some View {
        WalletTransferPolicyDetails(request: .sample, update: EthereumTransferPolicyUpdate.sample, user: .sample)
    }
}
#endif
