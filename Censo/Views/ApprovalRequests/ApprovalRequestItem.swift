//
//  ApprovalRequestItem.swift
//  Censo
//
//  Created by Ata Namvari on 2021-09-01.
//

import Foundation
import SwiftUI
import Combine
import Alamofire


struct ApprovalRequestItem: View {
    var deviceSigner: DeviceSigner
    var user: CensoApi.User
    var request: ApprovalRequest
    var onStatusChange: (() -> Void)?
    var timerPublisher: Publishers.Autoconnect<Timer.TimerPublisher>

    var body: some View {
        switch request.details {
        case .bitcoinWithdrawalRequest(let withdrawal as WithdrawalRequest),
             .ethereumWithdrawalRequest(let withdrawal as WithdrawalRequest):
            ApprovalRequestRow(deviceSigner: deviceSigner, user: user, request: request, timerPublisher: timerPublisher, onStatusChange: onStatusChange) {
                WithdrawalRow(requestType: request.details, withdrawal: withdrawal)
            } detail: {
                WithdrawalDetails(request: request, withdrawal: withdrawal)
            }
        case .bitcoinWalletCreation(let walletCreation as WalletCreation),
             .ethereumWalletCreation(let walletCreation as WalletCreation):
            ApprovalRequestRow(deviceSigner: deviceSigner, user: user, request: request, timerPublisher: timerPublisher, onStatusChange: onStatusChange) {
                WalletCreationRow(requestType: request.details, accountCreation: walletCreation)
            } detail: {
                WalletCreationDetails(request: request, accountCreation: walletCreation)
            }
        case .ethereumDAppTransactionRequest(let dAppTransactionRequest):
            ApprovalRequestRow(deviceSigner: deviceSigner, user: user, request: request, timerPublisher: timerPublisher, onStatusChange: onStatusChange) {
                DAppTransactionRow(requestType: request.details, transactionRequest: dAppTransactionRequest)
            } detail: {
                DAppTransactionDetails(request: request, transactionRequest: dAppTransactionRequest)
            }
        case .ethereumWalletNameUpdate(let walletNameUpdate): // 3
            ApprovalRequestRow(deviceSigner: deviceSigner, user: user, request: request, timerPublisher: timerPublisher, onStatusChange: onStatusChange) {
                BalanceAccountNameRow(requestType: request.details, update: walletNameUpdate)
            } detail: {
                BalanceAccountNameDetails(request: request, update: walletNameUpdate)
            }
//        case .ethereumTransferPolicyUpdate(let balanceAccountPolicyUpdate): // 2
//            ApprovalRequestRow(user: user, request: request, timerPublisher: timerPublisher, onStatusChange: onStatusChange) {
//                BalanceAccountPolicyRow(requestType: request.requestType, update: balanceAccountPolicyUpdate)
//            } detail: {
//                BalanceAccountPolicyDetails(request: request, update: balanceAccountPolicyUpdate, user: user)
//            }
        case .ethereumWalletSettingsUpdate(let walletSettingsUpdate): // 5
            ApprovalRequestRow(deviceSigner: deviceSigner, user: user, request: request, timerPublisher: timerPublisher, onStatusChange: onStatusChange) {
                BalanceAccountSettingsRow(requestType: request.details, update: walletSettingsUpdate)
            } detail: {
                BalanceAccountSettingsDetails(request: request, update: walletSettingsUpdate, user: user)
            }
        case .addressBookUpdate(let addressBookUpdate): // 4 - remove whitelist
            ApprovalRequestRow(deviceSigner: deviceSigner, user: user, request: request, timerPublisher: timerPublisher, onStatusChange: onStatusChange) {
                AddressBookUpdateRow(requestType: request.details, update: addressBookUpdate)
            } detail: {
                AddressBookUpdateDetails(request: request, update: addressBookUpdate)
            }
//        case .dAppBookUpdate(let dAppBookUpdate):
//            UnknownRequestRow(request: request, timerPublisher: timerPublisher)
//        case .ethereumWalletConfigPolicyUpdate(let walletConfigPolicyUpdate): // 1
//            ApprovalRequestRow(user: user, request: request, timerPublisher: timerPublisher, onStatusChange: onStatusChange) {
//                WalletConfigPolicyRow(requestType: request.requestType, update: walletConfigPolicyUpdate)
//            } detail: {
//                WalletConfigPolicyDetails(request: request, update: walletConfigPolicyUpdate)
//            }
//        case .solanaWrapConversionRequest(let wrapConversionRequest):
//            ApprovalRequestRow(user: user, request: request, timerPublisher: timerPublisher, onStatusChange: onStatusChange) {
//                WrapConversionRow(requestType: request.details, conversion: wrapConversionRequest)
//            } detail: {
//                WrapConversionDetail(request: request, conversion: wrapConversionRequest)
//            }
        case .ethereumWalletWhitelistUpdate(let walletWhitelistUpdate):
            ApprovalRequestRow(deviceSigner: deviceSigner, user: user, request: request, timerPublisher: timerPublisher, onStatusChange: onStatusChange) {
                BalanceAccountWhitelistRow(requestType: request.details, update: walletWhitelistUpdate)
            } detail: {
                BalanceAccountWhitelistDetails(request: request, update: walletWhitelistUpdate, user: user)
            }
        case .loginApproval(let login):
            ApprovalRequestRow(deviceSigner: deviceSigner, user: user, request: request, timerPublisher: timerPublisher, onStatusChange: onStatusChange) {
                LoginRow(requestType: request.details, login: login)
            } detail: {
                LoginDetails(requestType: request.details, login: login)
            }
        case .vaultInvitation(let acceptVaultInvitation):
            ApprovalRequestRow(deviceSigner: deviceSigner, user: user, request: request, timerPublisher: timerPublisher, onStatusChange: onStatusChange) {
                AcceptVaultInvitationRow(requestType: request.details, acceptVaultInvitation: acceptVaultInvitation)
            } detail: {
                AcceptVaultInvitationDetails(requestType: request.details, acceptVaultInvitation: acceptVaultInvitation)
            }
        case .passwordReset:
            ApprovalRequestRow(deviceSigner: deviceSigner, user: user, request: request, timerPublisher: timerPublisher, onStatusChange: onStatusChange) {
                PasswordResetRow(requestType: request.details, email: request.submitterEmail)
            } detail: {
                PasswordResetDetails(requestType: request.details)
            }
        default:
            UnknownRequestRow(request: request, timerPublisher: timerPublisher)
        }
    }
}

protocol WithdrawalRequest {
    var account: AccountInfo { get }
    var symbolAndAmountInfo: SymbolAndAmountInfo { get }
    var destination: DestinationAddress { get }
}

extension BitcoinWithdrawalRequest: WithdrawalRequest {}

extension EthereumWithdrawalRequest: WithdrawalRequest {}

protocol WalletCreation {
    var accountSlot: UInt8 { get }
    var accountInfo: AccountInfo { get }
    var approvalPolicy: ApprovalPolicy { get }
    var whitelistEnabled: BooleanSetting { get }
    var dappsEnabled: BooleanSetting { get }
    var addressBookSlot: UInt8 { get }
}

extension BitcoinWalletCreation: WalletCreation {}

extension EthereumWalletCreation: WalletCreation {}

