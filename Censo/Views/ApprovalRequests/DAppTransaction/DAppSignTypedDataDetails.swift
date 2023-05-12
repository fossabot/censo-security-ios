//
//  DAppTransactionDetails.swift
//  Censo
//
//  Created by Ata Namvari on 2022-04-03.
//

import Foundation
import SwiftUI

struct EIP712EntryView: View {
    var data: EIP712TypedData
    var entry: EIP712Entry
    var body: some View {
        HStack(spacing: 10) {
            Text("\(entry.name):")
                .bold()
                .padding(.leading, 10)
            if (data.hasType(type: entry.type)) {
                Text(entry.type)
            } else {
                Text(entry.value.stringValue ?? "")
            }
            Spacer()
        }
        if (data.hasType(type: entry.type)) {
            VStack {
                Group {
                    ForEach(data.getEntriesForType(type: entry.type, from: entry.value), id: \.self) {
                        EIP712EntryView(data: data, entry: $0)
                    }
                }
            }
            .padding(.leading, 20)
        }
    }
}

struct DAppSignTypedDataDetails: View {
    var request: DAppRequest
    var ethSignTypedData: EthSignTypedData
    var wallet: WalletInfo
    var dAppInfo: DAppInfo

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
                Text("Data")
                    .font(.title2)
                    .bold()
                    .lineLimit(1)
                    .allowsTightening(true)
                    .minimumScaleFactor(0.25)
                    .foregroundColor(Color.black)
                    .padding(EdgeInsets(top: 15, leading: 20, bottom: 0, trailing: 20))
          
            if let structuredData = ethSignTypedData.structuredData() {
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 10) {
                        Text("Domain:")
                            .bold()
                            .padding(.leading, 10)
                        Text(structuredData.getDomainName() ?? "")
                        Spacer()
                    }
                    HStack(spacing: 10) {
                        Text("Contract:")
                            .bold()
                            .padding(.leading, 10)
                        Text(structuredData.getDomainVerifyingContract() ?? "")
                        Spacer()
                    }
                    Group {
                        ForEach(structuredData.getMessageEntries(), id: \.self) {
                            EIP712EntryView(data: structuredData, entry: $0)
                        }
                    }
                }
            } else {
                Text("Could not parse data: \(ethSignTypedData.eip712Data)")
            }
            
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
struct DAppSignTypedDataDetails_Previews: PreviewProvider {
    static var previews: some View {
        DAppSignTypedDataDetails(request: EthereumDAppRequest.sample, ethSignTypedData: .sample, wallet: .sample, dAppInfo: .sample)

        let timerPublisher = Timer.TimerPublisher(interval: 1, runLoop: .current, mode: .default).autoconnect()

        NavigationView {
            ApprovalRequestDetails(registeredDevice: RegisteredDevice(email: "test@test.com", deviceKey: .sample, encryptedRootSeed: Data(), publicKeys: PublicKeys(bitcoin: "0x01", ethereum: "0x02", offchain: "0x03")),
                user: .sample, request: .sample, timerPublisher: timerPublisher) {
                DAppSignTypedDataDetails(request: EthereumDAppRequest.sample, ethSignTypedData: .sample, wallet: .sample, dAppInfo: .sample)
            }
        }
    }
}

extension EthSignTypedData {
    static var sample: Self {
        EthSignTypedData(
            eip712Data: "{\"types\":{\"EIP712Domain\":[{\"name\":\"name\",\"type\":\"string\"},{\"name\":\"version\",\"type\":\"string\"},{\"name\":\"chainId\",\"type\":\"uint256\"},{\"name\":\"verifyingContract\",\"type\":\"address\"}],\"Person\":[{\"name\":\"name\",\"type\":\"string\"},{\"name\":\"wallet\",\"type\":\"address\"}],\"Mail\":[{\"name\":\"from\",\"type\":\"Person\"},{\"name\":\"to\",\"type\":\"Person\"},{\"name\":\"contents\",\"type\":\"string\"}]},\"primaryType\":\"Mail\",\"domain\":{\"name\":\"Ether Mail\",\"version\":\"1\",\"chainId\":1,\"verifyingContract\":\"0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC\"},\"message\":{\"from\":{\"name\":\"Cow\",\"wallet\":\"0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826\"},\"to\":{\"name\":\"Bob\",\"wallet\":\"0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB\"},\"contents\":\"Hello, Bob!\"}}",
            messageHash: "")
    }
}

#endif
