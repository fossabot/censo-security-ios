//
//  BalanceAccountNameRow.swift
//  Censo
//
//  Created by Ata Namvari on 2022-05-03.
//

import Foundation
import SwiftUI


struct WalletNameRow: View {
    var requestType: ApprovalRequestType
    var update: EthereumWalletNameUpdate

    var body: some View {
        VStack(spacing: 8) {
            Text(requestType.header)
                .font(.title2)
                .bold()
                .lineLimit(1)
                .allowsTightening(true)
                .minimumScaleFactor(0.25)
                .foregroundColor(Color.white)
                .padding(EdgeInsets(top: 15, leading: 20, bottom: 0, trailing: 20))

            Text("\(update.wallet.name.toWalletName()) → \(update.newName.toWalletName())")
                .font(.title3)
                .lineLimit(1)
                .allowsTightening(true)
                .foregroundColor(Color.white.opacity(0.8))
                .padding(EdgeInsets(top: 2, leading: 20, bottom: 20, trailing: 20))
        }
    }
}

#if DEBUG
struct WalletNameRow_Previews: PreviewProvider {
    static var previews: some View {
        WalletNameRow(requestType: .ethereumWalletNameUpdate(.sample), update: EthereumWalletNameUpdate.sample)
    }
}

extension EthereumWalletNameUpdate {
    static var sample: Self {
        EthereumWalletNameUpdate(wallet: .sample, newName: "My Wallet", signingData: .sample)
    }
}
#endif
