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
             .ethereumWithdrawalRequest(let withdrawal as WithdrawalRequest),
             .polygonWithdrawalRequest(let withdrawal as WithdrawalRequest):
            ApprovalRequestRow(deviceSigner: deviceSigner, user: user, request: request, timerPublisher: timerPublisher, onStatusChange: onStatusChange) {
                WithdrawalRow(requestType: request.details, withdrawal: withdrawal)
            } detail: {
                WithdrawalDetails(request: request, withdrawal: withdrawal)
            }
        case .bitcoinWalletCreation(let walletCreation as WalletCreation),
             .ethereumWalletCreation(let walletCreation as WalletCreation),
             .polygonWalletCreation(let walletCreation as WalletCreation):
            ApprovalRequestRow(deviceSigner: deviceSigner, user: user, request: request, timerPublisher: timerPublisher, onStatusChange: onStatusChange) {
                WalletCreationRow(requestType: request.details, walletCreation: walletCreation)
            } detail: {
                WalletCreationDetails(request: request, walletCreation: walletCreation)
            }
        case .ethereumDAppTransactionRequest(let dAppTransactionRequest):
            ApprovalRequestRow(deviceSigner: deviceSigner, user: user, request: request, timerPublisher: timerPublisher, onStatusChange: onStatusChange) {
                DAppTransactionRow(requestType: request.details, transactionRequest: dAppTransactionRequest)
            } detail: {
                DAppTransactionDetails(request: request, transactionRequest: dAppTransactionRequest)
            }
        case .ethereumWalletNameUpdate(let walletNameUpdate as WalletNameUpdate),
                .polygonWalletNameUpdate(let walletNameUpdate as WalletNameUpdate):
            ApprovalRequestRow(deviceSigner: deviceSigner, user: user, request: request, timerPublisher: timerPublisher, onStatusChange: onStatusChange) {
                WalletNameRow(requestType: request.details, update: walletNameUpdate)
            } detail: {
                WalletNameDetails(request: request, update: walletNameUpdate)
            }
        case .ethereumTransferPolicyUpdate(let walletTransferPolicyUpdate as TransferPolicyUpdate),
             .polygonTransferPolicyUpdate(let walletTransferPolicyUpdate as TransferPolicyUpdate): // 2
            ApprovalRequestRow(deviceSigner: deviceSigner, user: user, request: request, timerPublisher: timerPublisher, onStatusChange: onStatusChange) {
                WalletTransferPolicyRow(requestType: request.details, update: walletTransferPolicyUpdate)
            } detail: {
                WalletTransferPolicyDetails(request: request, update: walletTransferPolicyUpdate, user: user)
            }
        case .ethereumWalletSettingsUpdate(let walletSettingsUpdate as WalletSettingsUpdate),
             .polygonWalletSettingsUpdate(let walletSettingsUpdate as WalletSettingsUpdate): // 5
            ApprovalRequestRow(deviceSigner: deviceSigner, user: user, request: request, timerPublisher: timerPublisher, onStatusChange: onStatusChange) {
                WalletSettingsRow(requestType: request.details, update: walletSettingsUpdate)
            } detail: {
                WalletSettingsDetails(request: request, update: walletSettingsUpdate, user: user)
            }
        case .addressBookUpdate(let addressBookUpdate): // 4 - remove whitelist
            ApprovalRequestRow(deviceSigner: deviceSigner, user: user, request: request, timerPublisher: timerPublisher, onStatusChange: onStatusChange) {
                AddressBookUpdateRow(requestType: request.details, update: addressBookUpdate)
            } detail: {
                AddressBookUpdateDetails(request: request, update: addressBookUpdate)
            }
        case .vaultPolicyUpdate(let vaultPolicyUpdate): // 1
            ApprovalRequestRow(deviceSigner: deviceSigner, user: user, request: request, timerPublisher: timerPublisher, onStatusChange: onStatusChange) {
                VaultConfigPolicyRow(requestType: request.details, update: vaultPolicyUpdate)
            } detail: {
                VaultConfigPolicyDetails(request: request, update: vaultPolicyUpdate)
            }
        case .ethereumWalletWhitelistUpdate(let walletWhitelistUpdate as WalletWhitelistUpdate),
             .polygonWalletWhitelistUpdate(let walletWhitelistUpdate as WalletWhitelistUpdate):
            ApprovalRequestRow(deviceSigner: deviceSigner, user: user, request: request, timerPublisher: timerPublisher, onStatusChange: onStatusChange) {
                WalletWhitelistRow(requestType: request.details, update: walletWhitelistUpdate)
            } detail: {
                WalletWhitelistDetails(request: request, update: walletWhitelistUpdate, user: user)
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

protocol SymbolInfo {
    var symbol: String { get }
    var description: String { get }
    var imageUrl: String? { get }
    var nftMetadata: NftMetadata? { get }
}

extension BitcoinSymbolInfo: SymbolInfo {
    var nftMetadata: NftMetadata? {
        return nil
    }
}

extension EvmSymbolInfo: SymbolInfo {}

// withdrawal
protocol WithdrawalRequest {
    var wallet: WalletInfo { get }
    var amount: Amount { get }
    var symbol: SymbolInfo { get }
    var fee: Amount { get }
    var feeSymbol: String { get }
    var replacementFee: Amount? { get }
    var showFeeInUsd: Bool { get }
    var destination: DestinationAddress { get }
}

extension BitcoinWithdrawalRequest: WithdrawalRequest {
    var symbol: SymbolInfo {
        return symbolInfo as SymbolInfo
    }
    var feeSymbol: String {
        return symbolInfo.symbol
    }
    var showFeeInUsd: Bool {
        return false
    }
}

extension EthereumWithdrawalRequest: WithdrawalRequest {
    var replacementFee: Amount? {
        return nil
    }
    
    var symbol: SymbolInfo {
        return symbolInfo as SymbolInfo
    }
    
    var feeSymbol: String {
        return feeSymbolInfo.symbol
    }
    
    var showFeeInUsd: Bool {
        return true
    }
}

extension PolygonWithdrawalRequest: WithdrawalRequest {
    var replacementFee: Amount? {
        return nil
    }
    
    var symbol: SymbolInfo {
        return symbolInfo as SymbolInfo
    }
    
    var feeSymbol: String {
        return feeSymbolInfo.symbol
    }
    
    var showFeeInUsd: Bool {
        return true
    }
}

protocol WalletCreation {
    var name: String { get }
    var approvalPolicy: ApprovalPolicy { get }
    var feeAmount: Amount? { get }
}

extension BitcoinWalletCreation: WalletCreation {
    var feeAmount: Amount? {
        return nil
    }
}

extension EthereumWalletCreation: WalletCreation {
    var feeAmount: Amount? {
        return fee
    }
}

extension PolygonWalletCreation: WalletCreation {
    var feeAmount: Amount? {
        return fee
    }
}

protocol WalletNameUpdate {
    var wallet: WalletInfo { get }
    var newName: String { get }
}

extension EthereumWalletNameUpdate: WalletNameUpdate {}
extension PolygonWalletNameUpdate: WalletNameUpdate {}

protocol WalletSettingsUpdate {
    var wallet: WalletInfo { get }
    var change: Change { get }
    var fee: Amount { get }
}

extension EthereumWalletSettingsUpdate: WalletSettingsUpdate {}
extension PolygonWalletSettingsUpdate: WalletSettingsUpdate {}


protocol WalletWhitelistUpdate {
    var wallet: WalletInfo { get }
    var destinations: [DestinationAddress] { get }
    var fee: Amount { get }
}

extension EthereumWalletWhitelistUpdate: WalletWhitelistUpdate {}
extension PolygonWalletWhitelistUpdate: WalletWhitelistUpdate {}

protocol TransferPolicyUpdate {
    var wallet: WalletInfo { get }
    var approvalPolicy: ApprovalPolicy { get }
    var fee: Amount { get }
}

extension EthereumTransferPolicyUpdate: TransferPolicyUpdate {}
extension PolygonTransferPolicyUpdate: TransferPolicyUpdate {}
