//
//  SolanaApprovalRequestType+Language.swift
//  Strike
//
//  Created by Ata Namvari on 2022-05-18.
//

import Foundation
import SwiftUI

extension SolanaApprovalRequestType {
    var header: String {
        switch self {
        case .withdrawalRequest(let request):
            if (request.symbolAndAmountInfo.replacementFee == nil) {
                return "Send \(request.symbolAndAmountInfo.formattedAmount) \(request.symbolAndAmountInfo.symbolInfo.symbol)"
            } else {
                return "Bump Fee"
            }
        case .unknown:
            return "Unknown"
        case .conversionRequest(let request):
            return "Convert \(request.symbolAndAmountInfo.formattedAmount) \(request.symbolAndAmountInfo.symbolInfo.symbol)"
        case .wrapConversionRequest(let request):
            return "Swap \(request.symbolAndAmountInfo.formattedAmount) \(request.symbolAndAmountInfo.symbolInfo.symbol)"
        case .signersUpdate(let update) where update.slotUpdateType == .Clear:
            return "Remove User"
        case .signersUpdate:
            return "Add User"
        case .walletCreation(let walletCreation) where walletCreation.accountInfo.accountType == .BalanceAccount:
            return "Add \(walletCreation.accountInfo.chain?.rawValue.capitalized ?? "Solana") Wallet"
        case .walletCreation:
            return "Add Wallet"
        case .balanceAccountNameUpdate:
            return "Rename"
        case .balanceAccountPolicyUpdate:
            return "Update Transfer Approvals"
        case .balanceAccountSettingsUpdate(let update) where update.change == .dappsEnabled(false):
            return "Disable dApp Access"
        case .balanceAccountSettingsUpdate(let update) where update.change == .dappsEnabled(true):
            return "Enable dApp Access"
        case .balanceAccountSettingsUpdate(let update) where update.change == .whitelistEnabled(false):
            return "Disable Whitelist"
        case .balanceAccountSettingsUpdate(let update):
            return "Enable Whitelist"
        case .balanceAccountAddressWhitelistUpdate(let update):
            return "Edit Whitelist Addresses"
        case .addressBookUpdate(let update) where update.change == .add:
            return "Add Address"
        case .addressBookUpdate(let update):
            return "Remove Address"
        case .dAppBookUpdate:
            return "Replace dApp Book"
        case .walletConfigPolicyUpdate:
            return "Update Administration Policy"
        case .dAppTransactionRequest:
            return "Execute dApp Transaction"
        case .signData:
            return "Sign Data"
        case .loginApproval:
            return "Log In"
        case .acceptVaultInvitation:
            return "Accept Invitation"
        case .passwordReset:
            return "Password Reset"
        }
    }
    
    var header2: String? {
        switch self {
        case .balanceAccountSettingsUpdate(let update):
            return update.account.name.toWalletName()
        case .balanceAccountPolicyUpdate(let update):
            return update.accountInfo.name.toWalletName()
        case .balanceAccountAddressWhitelistUpdate(let update):
            return update.accountInfo.name.toWalletName()
        case .balanceAccountNameUpdate(let update):
            return "\(update.accountInfo.name.toWalletName()) → \(update.newAccountName.toWalletName())"
        case .withdrawalRequest(let request):
            if (request.symbolAndAmountInfo.replacementFee == nil) {
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
        case .withdrawalRequest(let request):
            if (request.symbolAndAmountInfo.replacementFee == nil) {
                return request.symbolAndAmountInfo.formattedUSDEquivalent.flatMap {
                    "\($0) USD equivalent"
                }
            } else {
                return nil
            }
        case .conversionRequest(let request):
            return request.symbolAndAmountInfo.formattedUSDEquivalent.flatMap {
                "\($0) USD equivalent"
            }
        case .wrapConversionRequest(let request):
            return request.symbolAndAmountInfo.formattedUSDEquivalent.flatMap {
                "\($0) USD equivalent"
            }
        default:
            return nil
        }
    }
}
