//
//  WithdrawalDetails.swift
//  Censo
//
//  Created by Ata Namvari on 2021-04-19.
//

import Foundation
import SwiftUI

struct WithdrawalDetails: View {
    var request: ApprovalRequest
    var withdrawal: WithdrawalRequest

    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            FactList {
                Fact("From Wallet", withdrawal.account.name)
                Fact("Destinaton", withdrawal.destination.name)
                Fact("Destination Address", withdrawal.destination.address.masked())
                if withdrawal.symbolAndAmountInfo.symbolInfo.nftMetadata != nil {
                    Fact("NFT Name", withdrawal.symbolAndAmountInfo.symbolInfo.nftMetadata!.name)
                }
                if let fee = withdrawal.symbolAndAmountInfo.fee, let replacementFee = withdrawal.symbolAndAmountInfo.replacementFee {
                    Fact("Amount", "\(withdrawal.symbolAndAmountInfo.formattedAmount) \(withdrawal.symbolAndAmountInfo.symbolInfo.symbol)")
                    Fact("Original Fee", "\(fee.formattedAmount) \(fee.symbolInfo.symbol)")
                    Fact("New Fee", "\(replacementFee.formattedAmount) \(replacementFee.symbolInfo.symbol)")
                } else if let fee = withdrawal.symbolAndAmountInfo.fee {
                    Fact("Fee", "\(fee.formattedAmount) \(fee.symbolInfo.symbol)")
                }
            }
        }
    }
}

extension ApprovalRequest {
    var numberOfApprovalsNeeded: Int {
        numberOfDispositionsRequired - numberOfApprovalsReceived
    }
}

extension DateFormatter {
    static let mediumFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()
}

#if DEBUG
struct WithdrawalDetails_Previews: PreviewProvider {
    static var previews: some View {
        WithdrawalDetails(request: .sample, withdrawal: EthereumWithdrawalRequest.sample)
        let timerPublisher = Timer.TimerPublisher(interval: 1, runLoop: .current, mode: .default).autoconnect()

        NavigationView {
            ApprovalRequestDetails(deviceSigner: DeviceSigner(deviceKey: .sample, encryptedRootSeed: Data()), user: .sample, request: .sample, timerPublisher: timerPublisher) {
                WithdrawalDetails(request: .sample, withdrawal: EthereumWithdrawalRequest.sample)
            }
        }
    }
}
#endif


