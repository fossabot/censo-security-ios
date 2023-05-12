//
//  DAppTransactionRow.swift
//  Censo
//
//  Created by Ata Namvari on 2022-04-03.
//

import Foundation
import SwiftUI

struct DAppSignRow: View {
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
struct DapSignRow_Previews: PreviewProvider {
    static var previews: some View {
        DAppSignRow(requestType: .ethereumDAppRequest(.signSample))
            .preferredColorScheme(.light)
    }
}

extension EthereumDAppRequest {
    static var signSample: Self {
        EthereumDAppRequest(
            wallet: .sample,
            fee: Amount(value: "0.0012", nativeValue: "0.001234", usdEquivalent: "2.34"),
            feeSymbolInfo: EvmSymbolInfo(symbol: "ETH", description: "Ethereum", tokenInfo: nil, imageUrl: nil, nftMetadata: nil),
            dappInfo: .sample,
            dappParams: .signSample,
            signingData: .sample
        )
    }
}

extension DAppParams {
    static var signSample: Self {
        DAppParams.ethSign(
            EthSign(message: "0x68656c6c6f20776f726c64", messageHash: "0xD9EBA16ED0ECAE432B71FE008C98CC872BB4CC214D3220A36F365326CF807D68"
            )
        )
    }
}

#endif
