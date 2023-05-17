//
//  DAppTransactionRow.swift
//  Censo
//
//  Created by Ata Namvari on 2022-04-03.
//

import Foundation
import SwiftUI

struct DAppSignTypedDataRow: View {
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
struct DapSignTypedDataRow_Previews: PreviewProvider {
    static var previews: some View {
        DAppSignTypedDataRow(requestType: .ethereumDAppRequest(.signTypedDataSample))
            .preferredColorScheme(.light)
    }
}

extension EthereumDAppRequest {
    static var signTypedDataSample: Self {
        EthereumDAppRequest(
            wallet: .sample,
            fee: Amount(value: "0.0012", nativeValue: "0.001234", usdEquivalent: "2.34"),
            feeSymbolInfo: EvmSymbolInfo(symbol: "ETH", description: "Ethereum", tokenInfo: nil, imageUrl: nil, nftMetadata: nil),
            dappInfo: .sample,
            dappParams: .signTypedDataSample,
            signingData: .sample
        )
    }
}

extension DAppParams {
    static var signTypedDataSample: Self {
        DAppParams.ethSignTypedData(
            EthSignTypedData(eip712Data: "{\"types\":{\"EIP712Domain\":[{\"name\":\"name\",\"type\":\"string\"},{\"name\":\"version\",\"type\":\"string\"},{\"name\":\"chainId\",\"type\":\"uint256\"},{\"name\":\"verifyingContract\",\"type\":\"address\"}],\"Person\":[{\"name\":\"name\",\"type\":\"string\"},{\"name\":\"wallet\",\"type\":\"address\"}],\"Mail\":[{\"name\":\"from\",\"type\":\"Person\"},{\"name\":\"to\",\"type\":\"Person\"},{\"name\":\"contents\",\"type\":\"string\"}]},\"primaryType\":\"Mail\",\"domain\":{\"name\":\"Ether Mail\",\"version\":\"1\",\"chainId\":1,\"verifyingContract\":\"0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC\"},\"message\":{\"from\":{\"name\":\"Cow\",\"wallet\":\"0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826\"},\"to\":{\"name\":\"Bob\",\"wallet\":\"0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB\"},\"contents\":\"Hello, Bob!\"}}", messageHash: ""
            )
        )
    }
}

#endif
