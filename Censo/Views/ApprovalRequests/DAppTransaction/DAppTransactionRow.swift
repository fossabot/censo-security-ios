//
//  DAppTransactionRow.swift
//  Censo
//
//  Created by Ata Namvari on 2022-04-03.
//

import Foundation
import SwiftUI

struct DAppTransactionRow: View {
    var requestType: ApprovalRequestType

    var body: some View {
        VStack(spacing: 8) {
            Text(requestType.header)
                .font(.title2.bold())
                .lineLimit(1)
                .allowsTightening(true)
                .minimumScaleFactor(0.25)
                .padding(EdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20))
            
            Text(requestType.subHeader!)
                .font(.title3)
                .foregroundColor(Color.Censo.primaryForeground.opacity(0.7))
                .padding(EdgeInsets(top: 2, leading: 20, bottom: 20, trailing: 20))
        }
    }
}


#if DEBUG
struct DapTransactionRow_Previews: PreviewProvider {
    static var previews: some View {
        DAppTransactionRow(requestType: .ethereumDAppRequest(.sample))
            .preferredColorScheme(.light)
    }
}

extension EthereumDAppRequest {
    static var sample: Self {
        EthereumDAppRequest(
            wallet: .sample,
            fee: Amount(value: "0.0012", nativeValue: "0.001234", usdEquivalent: "2.34"),
            feeSymbolInfo: EvmSymbolInfo(symbol: "ETH", description: "Ethereum", tokenInfo: nil, imageUrl: nil, nftMetadata: nil),
            dappInfo: .sample,
            dappParams: .sample,
            signingData: .sample
        )
    }
}

extension DAppInfo {
    static var sample: Self {
        DAppInfo(name: "Sample DApp", url: "dapp.url", description: "Sample Description", icons: [])
    }
}

extension DAppParams {
    static var sample: Self {
        DAppParams.ethSendTransaction(
            EthSendTransaction(
                simulationResult: .success(
                    EvmSimulationResultSuccess(
                        balanceChanges: [
                            EvmSimulatedChange(
                                amount: Amount(value: "1.23", nativeValue: "1.23000", usdEquivalent: "2.34"),
                                symbolInfo: EvmSymbolInfo(symbol: "PEPE", description: "Pepe Token", tokenInfo: nil, imageUrl: nil, nftMetadata: nil)
                            )
                        ]
                    )
                ),
                transaction: EvmTransactionParams(from: "0x01010101", to: "0x02020202", value: "0x", data: "0x")
            )
        )
    }
}

#endif
