//
//  WalletConfigPolicyDetails.swift
//  Strike
//
//  Created by Ata Namvari on 2022-05-03.
//

import Foundation
import SwiftUI

struct WalletConfigPolicyDetails: View {
    var request: ApprovalRequest
    var update: WalletConfigPolicyUpdate

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            FactsSection(title: "Approvals") {
                Fact("Approvals Required", "\(update.approvalPolicy.approvalsRequired)")
                Fact("Approval Expiration", "\(DateComponentsFormatter.abbreviatedFormatter.string(for: DateComponents(second: Int(update.approvalPolicy.approvalTimeout / 1000))) ?? "")")
            }

            FactsSection(title: "Administrators") {
                if update.approvalPolicy.approvers.count > 0 {
                    for approver in update.approvalPolicy.approvers.sorted(by: { $0.value.name < $1.value.name }) {
                        Fact(approver.value.name, approver.value.email)
                    }
                } else {
                    Fact("No users may approve requests", "")
                }
            }
        }
    }
}

#if DEBUG
struct WalletConfigPolicyDetails_Previews: PreviewProvider {
    static var previews: some View {
        WalletConfigPolicyDetails(request: .sample, update: .sample)

        let timerPublisher = Timer.TimerPublisher(interval: 1, runLoop: .current, mode: .default).autoconnect()

        NavigationView {
            ApprovalRequestDetails(user: .sample, request: .sample, timerPublisher: timerPublisher) {
                WalletConfigPolicyDetails(request: .sample, update: .sample)
            }
        }
    }
}
#endif
