//
//  BalanceAccountWhitelistRow.swift
//  Censo
//
//  Created by Ata Namvari on 2022-05-24.
//

import Foundation
import SwiftUI


struct WalletWhitelistRow: View {
    var requestType: ApprovalRequestType
    var update: EthereumWalletWhitelistUpdate

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
            
            Text(update.wallet.name.toWalletName())
                .font(.title3)
                .foregroundColor(Color.white.opacity(0.8))
                .padding(EdgeInsets(top: 2, leading: 20, bottom: 20, trailing: 20))
        }
    }
}

#if DEBUG
struct WalletWhitelistRow_Previews: PreviewProvider {
    static var previews: some View {
        WalletWhitelistRow(requestType: .ethereumWalletWhitelistUpdate(.sample), update: .sample)
    }
}

extension EthereumWalletWhitelistUpdate {
    static var sample: Self {
        EthereumWalletWhitelistUpdate(
            wallet: .sample,
            destinations: [.sample, .sample],
            currentOnChainWhitelist: [],
            signingData: .sample)
    }
}
#endif
