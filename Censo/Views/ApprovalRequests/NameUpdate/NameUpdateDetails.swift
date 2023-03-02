//
//  BalanceAccountNameDetails.swift
//  Censo
//
//  Created by Ata Namvari on 2022-05-03.
//

import Foundation
import SwiftUI

struct NameUpdateDetails: View {
    var request: ApprovalRequest
    var update: NameUpdate

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
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
struct NameUpdateDetails_Previews: PreviewProvider {
    static var previews: some View {
        NameUpdateDetails(request: .sample, update:
                          VaultNameUpdate.sample)

        let timerPublisher = Timer.TimerPublisher(interval: 1, runLoop: .current, mode: .default).autoconnect()

        NavigationView {
            ApprovalRequestDetails(deviceSigner: DeviceSigner(deviceKey: .sample, encryptedRootSeed: Data()), user: .sample, request: .sample, timerPublisher: timerPublisher) {
                NameUpdateDetails(request: .sample,
                                  update: VaultNameUpdate.sample)
            }
        }
    }
}
#endif


