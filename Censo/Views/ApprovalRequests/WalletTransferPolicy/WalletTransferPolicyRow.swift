//
//  BalanceAccountPolicyRow.swift
//  Censo
//
//  Created by Ata Namvari on 2022-05-03.
//

import Foundation
import SwiftUI


struct WalletTransferPolicyRow: View {
    var requestType: ApprovalRequestType
    var update: TransferPolicyUpdate

    var body: some View {
        VStack(spacing: 8) {
            Text(requestType.header)
                .font(.title2)
                .bold()
                .lineLimit(1)
                .allowsTightening(true)
                .minimumScaleFactor(0.25)
                .padding(EdgeInsets(top: 15, leading: 20, bottom: 0, trailing: 20))

            Text(update.wallet.name.toWalletName())
                .font(.title3)
                .foregroundColor(Color.Censo.primaryForeground.opacity(0.7))
                .padding(EdgeInsets(top: 2, leading: 20, bottom: 20, trailing: 20))
        }
    }
}

#if DEBUG
struct WalletTransferPolicyRow_Previews: PreviewProvider {
    static var previews: some View {
        WalletTransferPolicyRow(requestType: .ethereumTransferPolicyUpdate(.sample), update: EthereumTransferPolicyUpdate.sample)
            .preferredColorScheme(.light)
    }
}

extension EthereumTransferPolicyUpdate {
    static var sample: Self {
        EthereumTransferPolicyUpdate(
            wallet: .sample,
            approvalPolicy: .sample,
            currentOnChainPolicy: .sample,
            fee: .sample,
            feeSymbolInfo: .sample,
            signingData: .sample
        )
    }
}

extension ApprovalPolicy {
    static var sample: Self {
        ApprovalPolicy(approvalsRequired: 3, approvalTimeout: 4000, approvers: [])
    }
}
#endif
