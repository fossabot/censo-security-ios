//
//  DAppTransactionDetails.swift
//  Censo
//
//  Created by Ata Namvari on 2022-04-03.
//

import Foundation
import SwiftUI

struct DAppTransactionDetails: View {
    var request: ApprovalRequest
    var ethSendTransaction: EthSendTransaction
    var wallet: WalletInfo
    var dAppInfo: DAppInfo

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            ForEach(0..<ethSendTransaction.simulatedChanges.count, id: \.self) { i in
                let balanceChange = ethSendTransaction.simulatedChanges[i]

                VStack {
                    Text(balanceChange.symbolInfo.symbol)
                        .font(.title2)
                        .bold()
                        .lineLimit(1)
                        .allowsTightening(true)
                        .minimumScaleFactor(0.25)
                        .foregroundColor(Color.white)
                        .padding(EdgeInsets(top: 15, leading: 20, bottom: 0, trailing: 20))

                    Text(balanceChange.amount.value)
                        .font(Font.subheadline)
                        .foregroundColor(balanceChange.amount.isNegative ? Color.red : Color.green)

                    if let usdEquivalent = balanceChange.amount.formattedUSDEquivalent {
                        Text(usdEquivalent)
                            .font(.caption)
                            .foregroundColor(Color.white.opacity(0.5))
                            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    }

                    HStack(spacing: 0) {
                        AccountDetail(name: dAppInfo.name)
                            .padding(10)
                            .frame(maxWidth: .infinity, maxHeight: 40)
                            .roundedCell(background: .Censo.thirdBackground)

                        Text(balanceChange.amount.isNegative ? "←" : "→")
                            .font(.body)
                            .foregroundColor(Color.white)
                            .frame(width: 20, height: 20)

                        AccountDetail(name: wallet.name)
                            .padding(10)
                            .frame(maxWidth: .infinity, maxHeight: 40)
                            .roundedCell(background: .Censo.thirdBackground)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(EdgeInsets(top: 5, leading: 14, bottom: 5, trailing: 14))
                }
            }
            .padding([.bottom], 20)

            Spacer()
                .frame(height: 10)
        }
    }
}

#if DEBUG
//struct DAppTransactionDetails_Previews: PreviewProvider {
//    static var previews: some View {
//        DAppTransactionDetails(request: .sample, ethSendTransaction: .sample, wallet: .sample, dAppInfo: .sample)
//
//        let timerPublisher = Timer.TimerPublisher(interval: 1, runLoop: .current, mode: .default).autoconnect()
//
//        NavigationView {
//            ApprovalRequestDetails(registeredDevice: RegisteredDevice(email: "test@test.com", deviceKey: .sample, encryptedRootSeed: Data()), user: .sample, request: .sample, timerPublisher: timerPublisher) {
//                DAppTransactionDetails(request: .sample, ethSendTransaction: .sample, wallet: .sample, dAppInfo: .sample)
//            }
//        }
//    }
//}
//
//extension EthSendTransaction {
//    static var sample: Self {
//        EthSendTransaction(simulatedChanges: [
//            EvmSimulatedChange(
//                amount: Amount(value: "1.23", nativeValue: "1.23000", usdEquivalent: "2.34"),
//                symbolInfo: EvmSymbolInfo(symbol: "PEPE", description: "Pepe Token", tokenInfo: nil, imageUrl: nil, nftMetadata: nil))
//        ],
//        transaction: EvmTransactionParams(from: "0x01010101", to: "0x02020202", value: "0x", data: "0x")
//        )
//    }
//}
#endif
