//
//  AccountCreationRow.swift
//  Censo
//
//  Created by Ata Namvari on 2022-03-23.
//

import Foundation
import SwiftUI

struct WalletCreationRow: View {
    var requestType: ApprovalRequestType
    var accountCreation: WalletCreation

    var body: some View {
        VStack(spacing: 8) {
            Text(requestType.header)
                .font(.title2.bold())
                .lineLimit(1)
                .allowsTightening(true)
                .minimumScaleFactor(0.25)
                .foregroundColor(Color.white)
                .padding(EdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20))

            Text(accountCreation.accountInfo.name.toWalletName())
                .font(.title3)
                .foregroundColor(Color.white.opacity(0.8))
                .padding(EdgeInsets(top: 2, leading: 20, bottom: 20, trailing: 20))
        }
    }
}

extension AccountType: CustomStringConvertible {
    var description: String {
        switch self {
        case .BalanceAccount:
            return "Wallet"
        case .StakeAccount:
            return "Stake Wallet"
        }
    }
}

#if DEBUG
struct WalletCreationRow_Previews: PreviewProvider {
    static var previews: some View {
        WalletCreationRow(requestType: .ethereumWalletCreation(.sample), accountCreation: EthereumWalletCreation.sample)
    }
}

extension EthereumWalletCreation {
    static var sample: Self {
        EthereumWalletCreation(accountSlot: 1, accountInfo: AccountInfo(name: "Rainbows", identifier: "dffdg", accountType: .BalanceAccount, address: "", chain: .ethereum), approvalPolicy: ApprovalPolicy(approvalsRequired: 3, approvalTimeout: 4000000, approvers: [SignerInfo(publicKey: "dsfgsfdg4534gf4", name: "John Q", email: "johnny@crypto.com", nameHashIsEmpty: false)]), whitelistEnabled: .On, dappsEnabled: .On, addressBookSlot: 4)
    }
}

#endif
