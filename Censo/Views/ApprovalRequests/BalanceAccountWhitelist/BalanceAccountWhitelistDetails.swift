//
//  BalanceAccountWhitelistDetails.swift
//  Censo
//
//  Created by Ata Namvari on 2022-05-24.
//

import Foundation
import SwiftUI

struct BalanceAccountWhitelistDetails: View {
    var request: ApprovalRequest
    var update: EthereumWalletWhitelistUpdate
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
        }
    }
}

#if DEBUG
struct BalanceAccountWhitelistDetails_Previews: PreviewProvider {
    static var previews: some View {
        BalanceAccountWhitelistDetails(request: .sample, update: .sample, user: .sample)

        let timerPublisher = Timer.TimerPublisher(interval: 1, runLoop: .current, mode: .default).autoconnect()

        NavigationView {
            ApprovalRequestDetails(deviceSigner: DeviceSigner(deviceKey: .sample, encryptedRootSeed: Data()), user: .sample, request: .sample, timerPublisher: timerPublisher) {
                BalanceAccountWhitelistDetails(request: .sample, update: .sample, user: .sample)
            }
        }
    }
}
#endif
