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
                Fact("From Wallet", withdrawal.wallet.name)
                Fact("Destinaton", withdrawal.destination.name)
                Fact("Destination Address", withdrawal.destination.address.masked())
                if withdrawal.symbol.nftMetadata != nil {
                    Fact("NFT Name", withdrawal.symbol.nftMetadata!.name)
                }
                if let replacementFee = withdrawal.replacementFee {
                    Fact("Amount", "\(withdrawal.amount.formattedAmount) \(withdrawal.symbol.symbol)")
                    Fact("Original Fee", "\(withdrawal.fee.formattedAmount) \(withdrawal.feeSymbol)")
                    Fact("New Fee", "\(replacementFee.formattedAmount) \(withdrawal.feeSymbol)")
                } else {
                    if withdrawal.showFeeInUsd, let feeInUsd = withdrawal.fee.formattedUSDEquivalent {
                        Fact("Fee Estimate", "\(feeInUsd) USD")
                    } else {
                        Fact("Fee", "\(withdrawal.fee.formattedAmount) \(withdrawal.feeSymbol)")
                    }
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


