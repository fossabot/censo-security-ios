//
//  DAppTransactionDetails.swift
//  Censo
//
//  Created by Ata Namvari on 2022-04-03.
//

import Foundation
import SwiftUI

struct DAppSignDetails: View {
    var request: DAppRequest
    var ethSign: EthSign
    var wallet: WalletInfo
    var dAppInfo: DAppInfo

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
                Text("Message")
                    .font(.title2)
                    .bold()
                    .lineLimit(1)
                    .allowsTightening(true)
                    .minimumScaleFactor(0.25)
                    .foregroundColor(Color.black)
                    .padding(EdgeInsets(top: 15, leading: 20, bottom: 0, trailing: 20))
                Text(ethSign.displayMessage())

            FactsSection(title: "DApp Info") {
                Fact("Name", dAppInfo.name)
                Fact("URL", dAppInfo.url)
            }

            if let feeInUsd = request.fee.formattedUSDEquivalent {
                FactsSection(title: "Fees") {
                    Fact("Fee Estimate", "\(feeInUsd) USD")
                }
            }
        }
    }
}

#if DEBUG
struct DAppSignDetails_Previews: PreviewProvider {
    static var previews: some View {
        DAppSignDetails(request: EthereumDAppRequest.sample, ethSign: .sample, wallet: .sample, dAppInfo: .sample)

        let timerPublisher = Timer.TimerPublisher(interval: 1, runLoop: .current, mode: .default).autoconnect()

        NavigationView {
            ApprovalRequestDetails(registeredDevice: RegisteredDevice(email: "test@test.com", deviceKey: .sample, encryptedRootSeed: Data(), publicKeys: PublicKeys(bitcoin: "0x01", ethereum: "0x02", offchain: "0x03")),
                user: .sample, request: .sample, timerPublisher: timerPublisher) {
                DAppSignDetails(request: EthereumDAppRequest.sample, ethSign: .sample, wallet: .sample, dAppInfo: .sample)
            }
        }
    }
}

extension EthSign {
    static var sample: Self {
        EthSign(message: "0x68656c6c6f20776f726c64", messageHash: "0xD9EBA16ED0ECAE432B71FE008C98CC872BB4CC214D3220A36F365326CF807D68")
    }
}

#endif
