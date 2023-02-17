//
//  WithdrawalRow.swift
//  Censo
//
//  Created by Ata Namvari on 2021-04-19.
//

import Foundation
import SwiftUI


struct WithdrawalRow: View {
    var requestType: ApprovalRequestType
    var withdrawal: WithdrawalRequest

    var body: some View {
        VStack {
            Text(requestType.header)
                .font(.title2)
                .bold()
                .lineLimit(1)
                .allowsTightening(true)
                .minimumScaleFactor(0.25)
                .padding(EdgeInsets(top: 15, leading: 20, bottom: 0, trailing: 20))
            
            if (withdrawal.replacementFee != nil) {
                Text("for sending \(withdrawal.amount.formattedAmount) \(withdrawal.symbol.symbol)")
                    .font(.caption)
                    .bold()
                    .lineLimit(1)
                    .allowsTightening(true)
                    .minimumScaleFactor(0.25)
                    .padding(EdgeInsets(top: 15, leading: 20, bottom: 0, trailing: 20))
                
            } else {
                if let usdEquivalent = withdrawal.amount.formattedUSDEquivalent {
                    Text("\(usdEquivalent) USD equivalent")
                        .font(.caption)
                        .foregroundColor(Color.Censo.primaryForeground.opacity(0.7))
                        .padding(EdgeInsets(top: 2, leading: 20, bottom: 0, trailing: 20))
                }
            }
            
            HStack(spacing: 0) {
                AccountDetail(name: withdrawal.wallet.name)
                    .padding(10)
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .roundedCell()
                
                Text("→")
                    .font(.body)
                    .frame(width: 20, height: 20)
                
                AccountDetail(name: withdrawal.destination.name)
                    .padding(10)
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .roundedCell()
            }
            .frame(maxWidth: .infinity)
            .padding(EdgeInsets(top: 20, leading: 14, bottom: 20, trailing: 14))
        }
    }
}

func formatUSDEquivalent(usdEquivalent: String?) -> String? {
    guard let amount = usdEquivalent, let decimalValue = Decimal(string: amount) else {
        return nil
    }
    
    return NumberFormatter.usdFormatter.string(from: NSDecimalNumber(decimal: decimalValue))
}

func formatAmount(amount: String) -> String {
    var split = amount.split(separator: ".").map { String($0) }
    
    guard let wholePart = Int(split.removeFirst()) else {
        return amount
    }
    
    let wholePartString = NumberFormatter.separatorFormatter.string(from: NSNumber(integerLiteral: wholePart)) ?? "0"
    
    split.insert(wholePartString, at: 0)
    
    return split.joined(separator: ".")
}
    
extension Amount {
    var formattedUSDEquivalent: String? {
        return formatUSDEquivalent(usdEquivalent: usdEquivalent)
    }

    var formattedAmount: String {
        return formatAmount(amount: value)
    }
}

extension NumberFormatter {
    static let usdFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        return formatter
    }()

    static let wholeUSDFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    static let separatorFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.groupingSeparator = ","
        formatter.usesGroupingSeparator = true
        formatter.groupingSize = 3
        return formatter
    }()
}

#if DEBUG
struct WithdrawalRow_Previews: PreviewProvider {
    static var previews: some View {
        WithdrawalRow(requestType: .ethereumWithdrawalRequest(.sample), withdrawal: EthereumWithdrawalRequest.sample)
            .preferredColorScheme(.light)
    }
}
#endif
