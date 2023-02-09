//
//  BalanceAccountSettingsRow.swift
//  Censo
//
//  Created by Ata Namvari on 2022-05-03.
//

import Foundation
import SwiftUI


struct WalletSettingsRow: View {
    var requestType: ApprovalRequestType
    var update: WalletSettingsUpdate

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
struct WalletSettingsRow_Previews: PreviewProvider {
    static var previews: some View {
        WalletSettingsRow(
            requestType: .ethereumWalletSettingsUpdate(.sample),
            update: EthereumWalletSettingsUpdate.sample
        )
    }
}
#endif
