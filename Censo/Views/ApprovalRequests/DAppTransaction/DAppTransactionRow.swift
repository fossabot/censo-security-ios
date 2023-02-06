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
    var transactionRequest: EthereumDAppTransactionRequest

    var body: some View {
        VStack(spacing: 8) {
            Text(requestType.header)
                .font(.title2.bold())
                .lineLimit(1)
                .allowsTightening(true)
                .minimumScaleFactor(0.25)
                .foregroundColor(Color.white)
                .padding(EdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20))

            ForEach(0..<transactionRequest.balanceChanges.count, id: \.self) { i in
                let balanceChange = transactionRequest.balanceChanges[i]

                VStack {
                    Text(balanceChange.symbolInfo.symbol)
                        .font(.title2)
                        .bold()
                        .lineLimit(1)
                        .allowsTightening(true)
                        .minimumScaleFactor(0.25)
                        .foregroundColor(Color.white)
                        .padding(EdgeInsets(top: 15, leading: 20, bottom: 0, trailing: 20))

                    Text(balanceChange.amount)
                        .font(Font.subheadline)
                        .foregroundColor(balanceChange.isNegative ? Color.red : Color.green)

                    if let usdEquivalent = balanceChange.formattedUSDEquivalent {
                        Text(usdEquivalent)
                            .font(.caption)
                            .foregroundColor(Color.white.opacity(0.5))
                            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    }

                    HStack(spacing: 0) {
                        AccountDetail(name: transactionRequest.dappInfo.name)
                            .padding(10)
                            .frame(maxWidth: .infinity, maxHeight: 40)
                            .roundedCell()

                        Text(balanceChange.isNegative ? "←" : "→")
                            .font(.body)
                            .foregroundColor(Color.white)
                            .frame(width: 20, height: 20)

                        AccountDetail(name: transactionRequest.wallet.name)
                            .padding(10)
                            .frame(maxWidth: .infinity, maxHeight: 40)
                            .roundedCell()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(EdgeInsets(top: 5, leading: 14, bottom: 5, trailing: 14))
                }
            }
            .padding([.bottom], 15)
        }
    }
}

extension EthereumDAppTransactionRequest.SymbolAndAmountInfo {
    var formattedUSDEquivalent: String? {
        guard let amount = usdEquivalent, let decimalValue = Decimal(string: amount) else {
            return nil
        }

        return "$\(NumberFormatter.usdFormatter.string(from: NSDecimalNumber(decimal: decimalValue)) ?? "0")"
    }

    var formattedAmount: String {
        var split = amount.split(separator: ".").map { String($0) }

        guard let wholePart = Int(split.removeFirst()) else {
            return amount
        }

        let wholePartString = NumberFormatter.separatorFormatter.string(from: NSNumber(integerLiteral: wholePart)) ?? "0"

        split.insert(wholePartString, at: 0)

        return split.joined(separator: ".")
    }

    var isNegative: Bool {
        amount.first == "-"
    }
}

#if DEBUG
struct DapTransactionRow_Previews: PreviewProvider {
    static var previews: some View {
        DAppTransactionRow(requestType: .ethereumDAppTransactionRequest(.sample), transactionRequest: EthereumDAppTransactionRequest.sample)
    }
}

extension EthereumDAppTransactionRequest {
    static var sample: Self {
        EthereumDAppTransactionRequest(wallet: .sample, dappInfo: .sample, balanceChanges: [.sample, .sample], signingData: .sample)
    }
}

extension EthereumDAppTransactionRequest.SymbolAndAmountInfo {
    static var sample: Self {
        EthereumDAppTransactionRequest.SymbolAndAmountInfo(symbolInfo: .sample, amount: "12.3", usdEquivalent: "1.23")
    }
}

extension EthereumDAppTransactionRequest.SymbolAndAmountInfo.SymbolInfo {
    static var sample: Self {
        EthereumDAppTransactionRequest.SymbolAndAmountInfo.SymbolInfo(symbol: "SOL", symbolDescription: "Solana")
    }
}

extension DAppInfo {
    static var sample: Self {
        DAppInfo(address: "dgfdg3tregdfg", name: "Sample DApp")
    }
}

#endif
