//
//  AccountCreationDetails.swift
//  Censo
//
//  Created by Ata Namvari on 2022-03-23.
//

import Foundation
import SwiftUI

struct WalletCreationDetails: View {
    var request: ApprovalRequest
    var walletCreation: WalletCreation

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            FactList {
                Fact("Wallet Name", walletCreation.name)
            }

            FactsSection(title: "Approvals") {
                Fact("Approvals Required", "\(walletCreation.approvalPolicy.approvalsRequired)")
                Fact("Approval Expiration", "\(DateComponentsFormatter.abbreviatedFormatter.string(for: DateComponents(second: Int(walletCreation.approvalPolicy.approvalTimeout / 1000))) ?? "")")
            }

            FactsSection(title: "Transfer Approvers") {
                if walletCreation.approvalPolicy.approvers.count > 0 {
                    for approver in walletCreation.approvalPolicy.approvers {
                        Fact(approver.name, approver.email)
                    }
                } else {
                    Fact("No users may approve requests", "")
                }
            }
            if let fee = walletCreation.feeAmount, let feeInUsd = fee.formattedUSDEquivalent {
                FactsSection(title: "Fees") {
                    Fact("Fee Estimate", "\(feeInUsd) USD")
                }
            }
        }
    }
}

extension DateComponentsFormatter {
    static let abbreviatedFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = [.pad]
        return formatter
    }()
}

#if DEBUG
//struct AccountCreationDetails_Previews: PreviewProvider {
//    static var previews: some View {
//        WalletCreationDetails(request: .sample, walletCreation: EthereumWalletCreation.sample)
//
//        let timerPublisher = Timer.TimerPublisher(interval: 1, runLoop: .current, mode: .default).autoconnect()
//
//        NavigationView {
//            ApprovalRequestDetails(registeredDevice: RegisteredDevice(email: "test@test.com", deviceKey: .sample, encryptedRootSeed: Data()), user: .sample, request: .sample, timerPublisher: timerPublisher) {
//                WalletCreationDetails(request: .sample, walletCreation: EthereumWalletCreation.sample)
//            }
//        }
//    }
//}
#endif
