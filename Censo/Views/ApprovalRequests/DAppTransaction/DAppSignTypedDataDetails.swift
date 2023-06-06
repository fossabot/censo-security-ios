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
            if (data.hasType(type: entry.baseType())) {
                Text(entry.type)
            } else {
                Text(entry.value.stringValue ?? "")
            }
            Spacer()
        }
        if (data.hasType(type: entry.baseType())) {
            VStack {
                if (entry.isArray()) {
                    Group {
                        ForEach((entry.value.arrayValue ?? []).flatMap {
                            data.getEntriesForType(type: entry.baseType(), from: $0)
                        }, id: \.self) {
                            EIP712EntryView(data: data, entry: $0)
                        }
                    }
                } else {
                    Group {
                        ForEach(data.getEntriesForType(type: entry.type, from: entry.value), id: \.self) {
                            EIP712EntryView(data: data, entry: $0)
                        }
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

struct DAppSignTypedDataDetails_PreviewWithArray: PreviewProvider {
    static var previews: some View {
        DAppSignTypedDataDetails(request: EthereumDAppRequest.sample, ethSignTypedData: .sampleWithArray, wallet: .sample, dAppInfo: .sample)

        let timerPublisher = Timer.TimerPublisher(interval: 1, runLoop: .current, mode: .default).autoconnect()

        NavigationView {
            ApprovalRequestDetails(registeredDevice: RegisteredDevice(email: "test@test.com", deviceKey: .sample, encryptedRootSeed: Data(), publicKeys: PublicKeys(bitcoin: "0x01", ethereum: "0x02", offchain: "0x03")),
                user: .sample, request: .sample, timerPublisher: timerPublisher) {
                DAppSignTypedDataDetails(request: EthereumDAppRequest.sample, ethSignTypedData: .sampleWithArray, wallet: .sample, dAppInfo: .sample)
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
    static var sampleWithArray: Self {
        EthSignTypedData(eip712Data: "{\"types\":{\"MetaTransactionDataV2\":[{\"name\":\"signer\",\"type\":\"address\"},{\"name\":\"sender\",\"type\":\"address\"},{\"name\":\"expirationTimeSeconds\",\"type\":\"uint256\"},{\"name\":\"salt\",\"type\":\"uint256\"},{\"name\":\"callData\",\"type\":\"bytes\"},{\"name\":\"feeToken\",\"type\":\"address\"},{\"name\":\"fees\",\"type\":\"MetaTransactionFeeData[]\"}],\"MetaTransactionFeeData\":[{\"name\":\"recipient\",\"type\":\"address\"},{\"name\":\"amount\",\"type\":\"uint256\"}],\"EIP712Domain\":[{\"name\":\"name\",\"type\":\"string\"},{\"name\":\"version\",\"type\":\"string\"},{\"name\":\"chainId\",\"type\":\"uint256\"},{\"name\":\"verifyingContract\",\"type\":\"address\"}]},\"domain\":{\"name\":\"ZeroEx\",\"version\":\"1.0.0\",\"chainId\":\"1\",\"verifyingContract\":\"0xdef1c0ded9bec7f1a1670819833240f027b25eff\"},\"primaryType\":\"MetaTransactionDataV2\",\"message\":{\"signer\":\"0xa8120f2ca4b3495d460df02122e90833e928da86\",\"sender\":\"0x0000000000000000000000000000000000000000\",\"expirationTimeSeconds\":\"1685998373\",\"salt\":\"10172818397776878889035290569885733773193256001012696978400198892263007391591\",\"callData\":\"0x7a1eb1b9000000000000000000000000b50721bcf8d664c30412cfbc6cf7a15145234ad10000000000000000000000007d1afa7b718fb893db30a3abc0cfc608aacfebb000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000c5fda3e9049c92380000000000000000000000000000000000000000000000010a4000a7659e3358000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000c5fda3e9049c923800000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000042b50721bcf8d664c30412cfbc6cf7a15145234ad1000bb8c02aaa39b223fe8d0a0e5c4f27ead9083c756cc2000bb87d1afa7b718fb893db30a3abc0cfc608aacfebb0000000000000000000000000000000000000000000000000000000000000869584cd00000000000000000000000086003b044f70dac0abc80ac8957305b6370893ed0000000000000000000000000000000000000000000000cf7d732a78647e48cd\",\"feeToken\":\"0xb50721bcf8d664c30412cfbc6cf7a15145234ad1\",\"fees\":[{\"recipient\":\"0x38f5e5b4da37531a6e85161e337e0238bb27aa90\",\"amount\":\"17280505867230653594\"}]}}", messageHash: "")
    }
}

#endif
