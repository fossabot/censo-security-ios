//
//  BalanceAccountWhitelistDetails.swift
//  Censo
//
//  Created by Ata Namvari on 2022-05-24.
//

import Foundation
import SwiftUI

struct WalletWhitelistDetails: View {
    var request: ApprovalRequest
    var update: WalletWhitelistUpdate
    var user: CensoApi.User

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            FactsSection(title: "Whitelisted Addresses") {
                if update.destinations.count > 0 {
                    for destination in update.destinations.sorted(by: { $0.name < $1.name }) {
                        Fact(destination.name, destination.address.masked())
                    }
                } else {
                    Fact("No whitelisted addresses", "")
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
struct WalletWhitelistDetails_Previews: PreviewProvider {
    static var previews: some View {
        WalletWhitelistDetails(request: .sample,
                               update: EthereumWalletWhitelistUpdate.sample,
                               user: .sample)

        let timerPublisher = Timer.TimerPublisher(interval: 1, runLoop: .current, mode: .default).autoconnect()

        NavigationView {
            ApprovalRequestDetails(deviceSigner: DeviceSigner(deviceKey: .sample, encryptedRootSeed: Data()), user: .sample, request: .sample, timerPublisher: timerPublisher) {
                WalletWhitelistDetails(request: .sample,
                                       update: EthereumWalletWhitelistUpdate.sample,
                                       user: .sample)
            }
        }
    }
}
#endif
