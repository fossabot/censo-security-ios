//
//  BalanceAccountSettingsDetails.swift
//  Censo
//
//  Created by Ata Namvari on 2022-05-03.
//

import Foundation
import SwiftUI

struct BalanceAccountSettingsDetails: View {
    var request: ApprovalRequest
    var update: EthereumWalletSettingsUpdate
    var user: CensoApi.User

    var body: some View {
        VStack(alignment: .center, spacing: 10) {

        }
    }
}

#if DEBUG
struct BBalanceAccountSettingsDetails_Previews: PreviewProvider {
    static var previews: some View {
        BalanceAccountSettingsDetails(request: .sample, update: .sample, user: .sample)

        let timerPublisher = Timer.TimerPublisher(interval: 1, runLoop: .current, mode: .default).autoconnect()

        NavigationView {
            ApprovalRequestDetails(deviceSigner: DeviceSigner(deviceKey: .sample, encryptedRootSeed: Data()), user: .sample, request: .sample, timerPublisher: timerPublisher) {
                BalanceAccountSettingsDetails(request: .sample, update: .sample, user: .sample)
            }
        }
    }
}

extension EthereumWalletSettingsUpdate {
    static var sample: Self {
        EthereumWalletSettingsUpdate(account: .sample, change: .whitelistEnabled(true), signingData: .sample)
    }
}
#endif
