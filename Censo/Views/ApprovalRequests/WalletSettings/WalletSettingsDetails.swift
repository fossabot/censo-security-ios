//
//  BalanceAccountSettingsDetails.swift
//  Censo
//
//  Created by Ata Namvari on 2022-05-03.
//

import Foundation
import SwiftUI

struct WalletSettingsDetails: View {
    var request: ApprovalRequest
    var update: WalletSettingsUpdate
    var user: CensoApi.User

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            if let feeInUsd = update.fee.formattedUSDEquivalent {
                FactsSection(title: "Fees") {
                    Fact("Fee Estimate", "\(feeInUsd) USD")
                }
            }
        }
    }
}

#if DEBUG
struct WalletSettingsDetails_Previews: PreviewProvider {
    static var previews: some View {
        WalletSettingsDetails(request: .sample, update: EthereumWalletSettingsUpdate.sample, user: .sample)

        let timerPublisher = Timer.TimerPublisher(interval: 1, runLoop: .current, mode: .default).autoconnect()

        NavigationView {
            ApprovalRequestDetails(registeredDevice: RegisteredDevice(email: "test@test.com", deviceKey: .sample, encryptedRootSeed: Data()), user: .sample, request: .sample, timerPublisher: timerPublisher) {
                WalletSettingsDetails(request: .sample,
                                      update: EthereumWalletSettingsUpdate.sample,
                                      user: .sample)
            }
        }
    }
}

extension EthereumWalletSettingsUpdate {
    static var sample: Self {
        EthereumWalletSettingsUpdate(
            wallet: .sample,
            currentGuardAddress: "",
            change: .whitelistEnabled(true),
            signingData: .sample,
            fee: .feeSample,
            feeSymbolInfo: .sample
        )
    }
}
#endif
