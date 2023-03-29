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
        case .ethereumWalletNameUpdate(let nameUpdate as NameUpdate),
             .polygonWalletNameUpdate(let nameUpdate as NameUpdate),
             .bitcoinWalletNameUpdate(let nameUpdate as NameUpdate),
             .vaultNameUpdate(let nameUpdate as NameUpdate),
             .orgNameUpdate(let nameUpdate as NameUpdate):
            ApprovalRequestRow(deviceSigner: deviceSigner, user: user, request: request, timerPublisher: timerPublisher, onStatusChange: onStatusChange) {
                NameUpdateRow(requestType: request.details, update: nameUpdate)
            } detail: {
                NameUpdateDetails(request: request, update: nameUpdate)
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
        case .addDevice(let addDevice):
            ApprovalRequestRow(deviceSigner: deviceSigner, user: user, request: request, timerPublisher: timerPublisher, onStatusChange: onStatusChange) {
                AddDeviceRow(requestType: request.details, addDevice: addDevice)
            } detail: {
                AddDeviceDetails(request: request, addDevice: addDevice)
            }
        case .vaultPolicyUpdate(let vaultPolicyUpdate): // 1
            ApprovalRequestRow(deviceSigner: deviceSigner, user: user, request: request, timerPublisher: timerPublisher, onStatusChange: onStatusChange) {
                VaultConfigPolicyRow(requestType: request.details, update: vaultPolicyUpdate)
            } detail: {
                VaultConfigPolicyDetails(request: request, update: vaultPolicyUpdate)
            }
        case .vaultCreation(let vaultCreation): // 1
            ApprovalRequestRow(deviceSigner: deviceSigner, user: user, request: request, timerPublisher: timerPublisher, onStatusChange: onStatusChange) {
                VaultCreationRow(requestType: request.details, vaultCreation: vaultCreation)
            } detail: {
                VaultCreationDetails(request: request, vaultCreation: vaultCreation)
            }
        case .orgAdminPolicyUpdate(let orgAdminPolicyUpdate): // 1
            ApprovalRequestRow(deviceSigner: deviceSigner, user: user, request: request, timerPublisher: timerPublisher, onStatusChange: onStatusChange) {
                OrgAdminPolicyRow(requestType: request.details, update: orgAdminPolicyUpdate)
            } detail: {
                OrgAdminPolicyDetails(request: request, update: orgAdminPolicyUpdate)
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
        case .passwordReset:
            ApprovalRequestRow(deviceSigner: deviceSigner, user: user, request: request, timerPublisher: timerPublisher, onStatusChange: onStatusChange) {
                PasswordResetRow(requestType: request.details, email: request.submitterEmail)
            } detail: {
                PasswordResetDetails(requestType: request.details)
            }
        case .vaultUserRolesUpdate(let update):
            ApprovalRequestRow(deviceSigner: deviceSigner, user: user, request: request, timerPublisher: timerPublisher, onStatusChange: onStatusChange) {
                VaultUserRolesUpdateRow(requestType: request.details, update: update)
            } detail: {
                VaultUserRolesUpdateDetails(request: request, update: update)
            }
        case .suspendUser(let suspendUser):
            ApprovalRequestRow(deviceSigner: deviceSigner, user: user, request: request, timerPublisher: timerPublisher, onStatusChange: onStatusChange) {
                SuspendUserRow(requestType: request.details, suspendUser: suspendUser)
            } detail: {
                UserDetails(request: request, user: suspendUser as UserInfo)
            }
        case .restoreUser(let restoreUser):
            ApprovalRequestRow(deviceSigner: deviceSigner, user: user, request: request, timerPublisher: timerPublisher, onStatusChange: onStatusChange) {
                RestoreUserRow(requestType: request.details, restoreUser: restoreUser)
            } detail: {
                UserDetails(request: request, user: restoreUser as UserInfo)
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

protocol NameUpdate {
    var oldDisplayName: String { get }
    var newDisplayName: String { get }
    var chainFees: [ChainFee] { get }
}

extension VaultNameUpdate: NameUpdate {
    var oldDisplayName: String {
        oldName.toVaultName()
    }
    var newDisplayName: String {
        newName.toVaultName()
    }
}

extension EthereumWalletNameUpdate: NameUpdate {
    var oldDisplayName: String {
        wallet.name.toWalletName()
    }
    var newDisplayName: String {
        newName.toWalletName()
    }
    var chainFees: [ChainFee] {
        [ChainFee(chain: Chain.ethereum, fee: fee, feeSymbolInfo: feeSymbolInfo)]
    }
}

extension PolygonWalletNameUpdate: NameUpdate {
    var oldDisplayName: String {
        wallet.name.toWalletName()
    }
    var newDisplayName: String {
        newName.toWalletName()
    }
    var chainFees: [ChainFee] {
        [ChainFee(chain: Chain.ethereum, fee: fee, feeSymbolInfo: feeSymbolInfo)]
    }
}

extension BitcoinWalletNameUpdate: NameUpdate {
    var oldDisplayName: String {
        wallet.name.toWalletName()
    }
    var newDisplayName: String {
        newName.toWalletName()
    }
    var chainFees: [ChainFee] {
        []
    }
}

extension OrgNameUpdate: NameUpdate {
    var oldDisplayName: String {
        oldName
    }
    var newDisplayName: String {
        newName
    }
    var chainFees: [ChainFee] {
        []
    }
}

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

protocol UserInfo {
    var name: String { get }
    var email: String { get }
    var jpegThumbnail: String? { get }
}

extension SuspendUser: UserInfo { }
extension RestoreUser: UserInfo { }
