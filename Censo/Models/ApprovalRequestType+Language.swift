//
//  ApprovalRequestType+Language.swift
//  Censo
//
//  Created by Ata Namvari on 2022-05-18.
//

import Foundation
import SwiftUI

extension ApprovalRequestType {
    var header: String {
        switch self {
        case .ethereumWithdrawalRequest(let request as WithdrawalRequest),
             .bitcoinWithdrawalRequest(let request as WithdrawalRequest):
            if (request.replacementFee == nil) {
                return "Send \(request.amount.formattedAmount) \(request.symbol.symbol)"
            } else {
                return "Bump Fee"
            }
        case .ethereumWalletCreation:
            return "Add Ethereum Wallet"
        case .bitcoinWalletCreation:
            return "Add Bitcoin Wallet"
        case .ethereumWalletNameUpdate:
            return "Rename"
        case .ethereumWalletSettingsUpdate(let update) where update.change == .dappsEnabled(false):
            return "Disable dApp Access"
        case .ethereumWalletSettingsUpdate(let update) where update.change == .dappsEnabled(true):
            return "Enable dApp Access"
        case .ethereumWalletSettingsUpdate(let update) where update.change == .whitelistEnabled(false):
            return "Disable Whitelist"
        case .ethereumWalletSettingsUpdate:
            return "Enable Whitelist"
        case .ethereumWalletWhitelistUpdate:
            return "Edit Whitelist Addresses"
        case .addressBookUpdate(let update) where update.change == .add:
            return "Add Address"
        case .addressBookUpdate:
            return "Remove Address"
        case .ethereumDAppTransactionRequest:
            return "Execute dApp Transaction"
        case .loginApproval:
            return "Log In"
        case .vaultInvitation:
            return "Accept Invitation"
        case .passwordReset:
            return "Password Reset"
        case .ethereumTransferPolicyUpdate:
            return "Update Transfer Approvals"
        case .vaultPolicyUpdate:
            return "Update Vault Policy"
        }
    }
    
    var header2: String? {
        switch self {
        case .ethereumWalletSettingsUpdate(let update):
            return update.wallet.name.toWalletName()
        case .ethereumWalletWhitelistUpdate(let update):
            return update.wallet.name.toWalletName()
        case .ethereumWalletNameUpdate(let update):
            return "\(update.wallet.name.toWalletName()) → \(update.newName.toWalletName())"
        case .ethereumWithdrawalRequest(let request as WithdrawalRequest),
             .bitcoinWithdrawalRequest(let request as WithdrawalRequest):
            if (request.replacementFee == nil) {
                return nil
            } else {
                return "for sending"
            }
        default:
            return nil
        }
    }

    var subHeader: String? {
        switch self {
        case .ethereumWithdrawalRequest(let request as WithdrawalRequest),
             .bitcoinWithdrawalRequest(let request as WithdrawalRequest):
            if (request.replacementFee == nil) {
                return request.amount.formattedUSDEquivalent.flatMap {
                    "\($0) USD equivalent"
                }
            } else {
                return nil
            }
        default:
            return nil
        }
    }
}
