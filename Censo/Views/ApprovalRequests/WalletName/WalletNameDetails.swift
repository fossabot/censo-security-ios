//
//  BalanceAccountNameDetails.swift
//  Censo
//
//  Created by Ata Namvari on 2022-05-03.
//

import Foundation
import SwiftUI

struct WalletNameDetails: View {
    var request: ApprovalRequest
    var update: WalletNameUpdate

    var body: some View {
        VStack(alignment: .center, spacing: 10) {

        }
    }
}

#if DEBUG
struct WalletNameDetails_Previews: PreviewProvider {
    static var previews: some View {
        WalletNameDetails(request: .sample, update:
                            EthereumWalletNameUpdate.sample)

        let timerPublisher = Timer.TimerPublisher(interval: 1, runLoop: .current, mode: .default).autoconnect()

        NavigationView {
            ApprovalRequestDetails(deviceSigner: DeviceSigner(deviceKey: .sample, encryptedRootSeed: Data()), user: .sample, request: .sample, timerPublisher: timerPublisher) {
                WalletNameDetails(request: .sample,
                                  update: EthereumWalletNameUpdate.sample)
            }
        }
    }
}
#endif


