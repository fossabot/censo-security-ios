//
//  DAppTransactionDetails.swift
//  Censo
//
//  Created by Ata Namvari on 2022-04-03.
//

import Foundation
import SwiftUI

struct DAppTransactionDetails: View {
    var request: DAppRequest
    var ethSendTransaction: EthSendTransaction
    var wallet: WalletInfo
    var dAppInfo: DAppInfo

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            switch ethSendTransaction.simulationResult {
            case .success(let success):
                SimulationBalanceChangesView(wallet: wallet, dAppInfo: dAppInfo, balanceChanges: success.balanceChanges, tokenAllowances: success.tokenAllowances)
            case .failure(let failure):
                VStack {
                    Text("Simulation failed: \(failure.reason)")
                        .font(.title2)
                        .foregroundColor(Color.black)
                }
                .padding([.bottom], 20)
            case nil:
                VStack {
                    Text("No simulation results available")
                        .font(.title2)
                        .foregroundColor(Color.black)
                }
                .padding([.bottom], 20)
            }

            Spacer()
                .frame(height: 10)
            
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

struct SimulationBalanceChangesView: View {
    var wallet: WalletInfo
    var dAppInfo: DAppInfo
    var balanceChanges: [EvmSimulatedChange]
    var tokenAllowances: [EvmTokenAllowance]
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            ForEach(0..<balanceChanges.count, id: \.self) { i in
                let balanceChange = balanceChanges[i]
                
                DAppRequestChangeDetail(
                    title: "\(balanceChange.amount.isNegative ? "Send" : "Receive") \(balanceChange.symbolInfo.displayName)",
                    amount: balanceChange.amount.absoluteValue,
                    usdAmount: balanceChange.amount.formattedUSDEquivalent,
                    walletName: wallet.name,
                    dAppName: dAppInfo.name,
                    directionIsForward: balanceChange.amount.isNegative
                )
            }
            .padding([.bottom], 20)

            ForEach(0..<tokenAllowances.count, id: \.self) { i in
                let tokenAllowance = tokenAllowances[i]

                DAppRequestChangeDetail(
                    title: "\(tokenAllowance.allowanceType == .Revoke ? "Revoke" : "Allow") use of \(tokenAllowance.symbolInfo.displayName)",
                    amount: tokenAllowance.displayAmount,
                    usdAmount: tokenAllowance.allowanceType == .Limited ? tokenAllowance.allowedAmount.formattedUSDEquivalent : nil,
                    walletName: wallet.name,
                    dAppName: dAppInfo.name,
                    directionIsForward: true
                )
            }

        }
    }

    struct DAppRequestChangeDetail: View {
        var title: String
        var amount: String?
        var usdAmount: String?
        var walletName: String
        var dAppName: String
        var directionIsForward: Bool

        var body: some View {
            VStack {
                Text(title)
                    .font(.title2)
                    .bold()
                    .lineLimit(1)
                    .allowsTightening(true)
                    .minimumScaleFactor(0.25)
                    .foregroundColor(Color.black)
                    .padding(EdgeInsets(top: 15, leading: 20, bottom: 0, trailing: 20))

                if let amount = amount {
                    Text(amount)
                        .font(Font.subheadline)
                }

                if let usdEquivalent = usdAmount {
                    Text("\(usdEquivalent) USD Equivalent")
                        .font(.caption)
                        .foregroundColor(Color.black.opacity(0.5))
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                }

                HStack(spacing: 0) {
                    AccountDetail(name: walletName)
                        .padding(10)
                        .frame(maxWidth: .infinity, maxHeight: 40)
                        .roundedCell(background: .Censo.primaryBackground)

                    Text(directionIsForward ? "→" : "←")
                        .font(.body)
                        .foregroundColor(Color.black)
                        .frame(width: 20, height: 20)

                    AccountDetail(name: dAppName)
                        .padding(10)
                        .frame(maxWidth: .infinity, maxHeight: 40)
                        .roundedCell(background: .Censo.primaryBackground)
                }
                .frame(maxWidth: .infinity)
                .padding(EdgeInsets(top: 5, leading: 14, bottom: 5, trailing: 14))
            }
        }
    }
}

extension EvmTokenAllowance {
    var displayAmount: String? {
        switch self.allowanceType {
        case .Limited:
            return allowedAmount.value
        case .Unlimited:
            return "Unlimited"
        case .Revoke:
            return nil
        }
    }
}

extension EvmSymbolInfo {
    var displayName: String {
        symbol.split(separator: ":").first.flatMap { String($0) } ?? symbol
    }
}

#if DEBUG
struct DAppTransactionDetails_Previews: PreviewProvider {
    static var previews: some View {
        DAppTransactionDetails(request: EthereumDAppRequest.sample, ethSendTransaction: .sampleSimSuccessNoChanges, wallet: .sample, dAppInfo: .sample)
        DAppTransactionDetails(request: EthereumDAppRequest.sample, ethSendTransaction: .sampleNoSimResults, wallet: .sample, dAppInfo: .sample)
        DAppTransactionDetails(request: EthereumDAppRequest.sample, ethSendTransaction: .sampleSimSuccess, wallet: .sample, dAppInfo: .sample)
        DAppTransactionDetails(request: EthereumDAppRequest.sample, ethSendTransaction: .sampleSimFailure, wallet: .sample, dAppInfo: .sample)

        let timerPublisher = Timer.TimerPublisher(interval: 1, runLoop: .current, mode: .default).autoconnect()

        NavigationView {
            ApprovalRequestDetails(registeredDevice: RegisteredDevice(email: "test@test.com", deviceKey: .sample, encryptedRootSeed: Data(), publicKeys: PublicKeys(bitcoin: "0x01", ethereum: "0x02", offchain: "0x03")), user: .sample, request: .sample, timerPublisher: timerPublisher) {
                DAppTransactionDetails(request: EthereumDAppRequest.sample, ethSendTransaction: .sampleNoSimResults, wallet: .sample, dAppInfo: .sample)
            }
        }
        NavigationView {
            ApprovalRequestDetails(registeredDevice: RegisteredDevice(email: "test@test.com", deviceKey: .sample, encryptedRootSeed: Data(), publicKeys: PublicKeys(bitcoin: "0x01", ethereum: "0x02", offchain: "0x03")), user: .sample, request: .sample, timerPublisher: timerPublisher) {
                DAppTransactionDetails(request: EthereumDAppRequest.sample, ethSendTransaction: .sampleSimSuccess, wallet: .sample, dAppInfo: .sample)
            }
        }
        NavigationView {
            ApprovalRequestDetails(registeredDevice: RegisteredDevice(email: "test@test.com", deviceKey: .sample, encryptedRootSeed: Data(), publicKeys: PublicKeys(bitcoin: "0x01", ethereum: "0x02", offchain: "0x03")), user: .sample, request: .sample, timerPublisher: timerPublisher) {
                DAppTransactionDetails(request: EthereumDAppRequest.sample, ethSendTransaction: .sampleSimFailure, wallet: .sample, dAppInfo: .sample)
            }
        }
    }
}

extension EthSendTransaction {
    static var sampleSimSuccess: Self {
        EthSendTransaction(
            simulationResult: .success(
                EvmSimulationResultSuccess(
                    balanceChanges: [
                        EvmSimulatedChange(
                            amount: Amount(value: "1.23", nativeValue: "1.23000", usdEquivalent: "2.34"),
                            symbolInfo: EvmSymbolInfo(symbol: "PEPE", description: "Pepe Token", tokenInfo: nil, imageUrl: nil, nftMetadata: nil)
                        ),
                        EvmSimulatedChange(amount: Amount(value: "-1.23", nativeValue: "-1.23000", usdEquivalent: "2.34"), symbolInfo: .sample)
                    ],
                    tokenAllowances: [
                        .init(symbolInfo: .sample, allowedAddress: "gfdgdf7g767g", allowedAmount: .sample, allowanceType: .Unlimited)
                    ]
                )
            ),
            transaction: EvmTransactionParams(from: "0x01010101", to: "0x02020202", value: "0x", data: "0x")
        )
    }
    
    static var sampleSimSuccessNoChanges: Self {
        EthSendTransaction(
            simulationResult: .success(
                EvmSimulationResultSuccess(balanceChanges: [], tokenAllowances: [EvmTokenAllowance(symbolInfo: EvmSymbolInfo(symbol: "USDC", description: "USD Coin", tokenInfo: nil, imageUrl: nil, nftMetadata: nil), allowedAddress: "allowed-address", allowedAmount: Amount(value: "12345678910111213141516.000000", nativeValue: "12345678910111213141516.000000", usdEquivalent: "12345678910111213141516.00"), allowanceType: TokenAllowanceType.Limited)])),
            transaction: EvmTransactionParams(from: "0x54b6d88c500c9859314b7e3a4e05767160503b77", to: "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48", value: "0x0", data: "0x095ea7b3000000000000000000000000000000000022d473030f116ddee9f6b43ac78ba3ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff")
        )
    }
    
    static var sampleSimFailure: Self {
        EthSendTransaction(
            simulationResult: .failure(
                EvmSimulationResultFailure(
                    reason: "execution reverted"
                )
            ),
            transaction: EvmTransactionParams(from: "0x01010101", to: "0x02020202", value: "0x", data: "0x")
        )
    }
    
    static var sampleNoSimResults: Self {
        EthSendTransaction(
            simulationResult: nil,
            transaction: EvmTransactionParams(from: "0x01010101", to: "0x02020202", value: "0x", data: "0x")
        )
    }
}
#endif
