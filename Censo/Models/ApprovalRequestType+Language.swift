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
             .polygonWithdrawalRequest(let request as WithdrawalRequest),
             .bitcoinWithdrawalRequest(let request as WithdrawalRequest):
            if (request.replacementFee == nil) {
                return "Send \(request.amount.formattedAmount) \(request.symbol.symbol)"
            } else {
                return "Bump Fee"
            }
        case .ethereumWalletCreation:
            return "Add Ethereum Wallet"
        case .polygonWalletCreation:
            return "Add Polygon Wallet"
        case .bitcoinWalletCreation:
            return "Add Bitcoin Wallet"
        case .ethereumWalletNameUpdate:
            return "Rename Ethereum Wallet"
        case .polygonWalletNameUpdate:
            return "Rename Polygon Wallet"
        case .bitcoinWalletNameUpdate:
            return "Rename Bitcoin Wallet"
        case .ethereumWalletSettingsUpdate(let update as WalletSettingsUpdate) where update.change == .dappsEnabled(false),
             .polygonWalletSettingsUpdate(let update as WalletSettingsUpdate) where update.change == .dappsEnabled(false):
            return "Disable dApp Access"
        case .ethereumWalletSettingsUpdate(let update as WalletSettingsUpdate) where update.change == .dappsEnabled(true),
             .polygonWalletSettingsUpdate(let update as WalletSettingsUpdate) where update.change == .dappsEnabled(true):
            return "Enable dApp Access"
        case .ethereumWalletSettingsUpdate(let update as WalletSettingsUpdate) where update.change == .whitelistEnabled(false),
             .polygonWalletSettingsUpdate(let update as WalletSettingsUpdate) where update.change == .whitelistEnabled(false):
            return "Disable Whitelist"
        case .ethereumWalletSettingsUpdate,
             .polygonWalletSettingsUpdate:
            return "Enable Whitelist"
        case .ethereumWalletWhitelistUpdate,
             .polygonWalletWhitelistUpdate:
            return "Edit Whitelist Addresses"
        case .addressBookUpdate(let update) where update.change == .add:
            return "Add Address"
        case .addressBookUpdate:
            return "Remove Address"
        case .ethereumDAppTransactionRequest:
            return "Execute dApp Transaction"
        case .loginApproval:
            return "Log In"
        case .passwordReset:
            return "Password Reset"
        case .ethereumTransferPolicyUpdate,
             .polygonTransferPolicyUpdate:
            return "Update Transfer Approvals"
        case .vaultPolicyUpdate:
            return "Update Vault Policy"
        case .vaultNameUpdate:
            return "Rename Vault"
        case .vaultCreation:
            return "Create Vault"
        case .orgAdminPolicyUpdate:
            return "Update Org Policy"
        case .addDevice:
            return "Add New Device"
        }
    }
    
    var header2: String? {
        switch self {
        case .ethereumWalletSettingsUpdate(let update as WalletSettingsUpdate),
             .polygonWalletSettingsUpdate(let update as WalletSettingsUpdate):
            return update.wallet.name.toWalletName()
        case .ethereumWalletWhitelistUpdate(let update as WalletWhitelistUpdate),
             .polygonWalletWhitelistUpdate(let update as WalletWhitelistUpdate):
            return update.wallet.name.toWalletName()
        case .ethereumWalletNameUpdate(let update as NameUpdate),
             .polygonWalletNameUpdate(let update as NameUpdate),
             .vaultNameUpdate(let update as NameUpdate):
            return "\(update.oldDisplayName) → \(update.newDisplayName)"
        case .ethereumWithdrawalRequest(let request as WithdrawalRequest),
             .polygonWithdrawalRequest(let request as WithdrawalRequest),
             .bitcoinWithdrawalRequest(let request as WithdrawalRequest):
            if (request.replacementFee == nil) {
                return nil
            } else {
                return "for sending"
            }
        case .vaultPolicyUpdate(let request):
            return request.vaultName.toVaultName()
        case .vaultCreation(let request):
            return request.name.toVaultName()
        default:
            return nil
        }
    }

    var subHeader: String? {
        switch self {
        case .ethereumWithdrawalRequest(let request as WithdrawalRequest),
             .polygonWithdrawalRequest(let request as WithdrawalRequest),
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
