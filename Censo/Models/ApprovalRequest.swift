//
//  ApprovalRequest.swift
//  Censo
//
//  Created by Ata Namvari on 2023-01-12.
//

import Foundation

struct ApprovalRequest: Codable, Equatable {
    let id: String
    let submitterName: String
    let submitterEmail: String
    let submitDate: Date
    let approvalTimeoutInSeconds: Int?
    let numberOfDispositionsRequired: Int
    let numberOfApprovalsReceived: Int
    let numberOfDeniesReceived: Int
    let vaultName: String?
    let initiationOnly: Bool
    let details: ApprovalRequestType
}

enum ApprovalRequestType: Codable, Equatable {
    case loginApproval(LoginApproval)
    case vaultInvitation(AcceptVaultInvitation)
    case passwordReset(PasswordReset)

    case bitcoinWithdrawalRequest(BitcoinWithdrawalRequest)
    case ethereumWithdrawalRequest(EthereumWithdrawalRequest)

    case bitcoinWalletCreation(BitcoinWalletCreation)
    case ethereumWalletCreation(EthereumWalletCreation)

    case ethereumWalletNameUpdate(EthereumWalletNameUpdate)

    case ethereumTransferPolicyUpdate(EthereumTransferPolicyUpdate)

    case ethereumWalletSettingsUpdate(EthereumWalletSettingsUpdate)

    case ethereumWalletWhitelistUpdate(EthereumWalletWhitelistUpdate)

    case addressBookUpdate(AddressBookUpdate)

    case vaultPolicyUpdate(VaultPolicyUpdate)

    case ethereumDAppTransactionRequest(EthereumDAppTransactionRequest)

    enum ApprovalTypeCodingKeys: String, CodingKey {
        case type
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ApprovalTypeCodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "Login":
            self = .loginApproval(try LoginApproval(from: decoder))
        case "VaultInvitation":
            self = .vaultInvitation(try AcceptVaultInvitation(from: decoder))
        case "PasswordReset":
            self = .passwordReset(try PasswordReset(from: decoder))
        case "BitcoinWithdrawalRequest":
            self = .bitcoinWithdrawalRequest(try BitcoinWithdrawalRequest(from: decoder))
        case "EthereumWithdrawalRequest":
            self = .ethereumWithdrawalRequest(try EthereumWithdrawalRequest(from: decoder))
        case "BitcoinWalletCreation":
            self = .bitcoinWalletCreation(try BitcoinWalletCreation(from: decoder))
        case "EthereumWalletCreation":
            self = .ethereumWalletCreation(try EthereumWalletCreation(from: decoder))
        case "EthereumWalletNameUpdate":
            self = .ethereumWalletNameUpdate(try EthereumWalletNameUpdate(from: decoder))
        case "EthereumWalletSettingsUpdate":
            self = .ethereumWalletSettingsUpdate(try EthereumWalletSettingsUpdate(from: decoder))
        case "EthereumWalletWhitelistUpdate":
            self = .ethereumWalletWhitelistUpdate(try EthereumWalletWhitelistUpdate(from: decoder))
        case "EthereumTransferPolicyUpdate":
            self = .ethereumTransferPolicyUpdate(try EthereumTransferPolicyUpdate(from: decoder))
        case "CreateAddressBookEntry":
            let entry = try AddressBookEntry(from: decoder)
            self = .addressBookUpdate(AddressBookUpdate(change: .add, entry: entry))
        case "DeleteAddressBookEntry":
            let entry = try AddressBookEntry(from: decoder)
            self = .addressBookUpdate(AddressBookUpdate(change: .remove, entry: entry))
        case "VaultPolicyUpdate":
            self = .vaultPolicyUpdate(try VaultPolicyUpdate(from: decoder))
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid Approval Type")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ApprovalTypeCodingKeys.self)
        switch self {
        case .loginApproval(let loginApproval):
            try container.encode("Login", forKey: .type)
            try loginApproval.encode(to: encoder)
        case .vaultInvitation(let acceptVaultInvitation):
            try container.encode("VaultInvitation", forKey: .type)
            try acceptVaultInvitation.encode(to: encoder)
        case .passwordReset(let passwordReset):
            try container.encode("PasswordReset", forKey: .type)
            try passwordReset.encode(to: encoder)
        case .bitcoinWithdrawalRequest(let withdrawalRequest):
            try container.encode("BitcoinWithdrawalRequest", forKey: .type)
            try withdrawalRequest.encode(to: encoder)
        case .ethereumWithdrawalRequest(let withdrawalRequest):
            try container.encode("EthereumWithdrawalRequest", forKey: .type)
            try withdrawalRequest.encode(to: encoder)
        case .bitcoinWalletCreation(let walletCreation):
            try container.encode("BitcoinWalletCreation", forKey: .type)
            try walletCreation.encode(to: encoder)
        case .ethereumWalletCreation(let walletCreation):
            try container.encode("EthereumWalletCreation", forKey: .type)
            try walletCreation.encode(to: encoder)
        case .ethereumWalletNameUpdate(let balanceAccountNameUpdate):
            try container.encode("EthereumWalletNameUpdate", forKey: .type)
            try balanceAccountNameUpdate.encode(to: encoder)
        case .ethereumTransferPolicyUpdate(let balanceAccountPolicyUpdate):
            try container.encode("EthereumTransferPolicyUpdate", forKey: .type)
            try balanceAccountPolicyUpdate.encode(to: encoder)
        case .ethereumWalletSettingsUpdate(let balanceAccountSettingsUpdate):
            try container.encode("EthereumWalletSettingsUpdate", forKey: .type)
            try balanceAccountSettingsUpdate.encode(to: encoder)
        case .ethereumWalletWhitelistUpdate(let balanceAccountAddressWhitelistUpdate):
            try container.encode("EthereumWalletWhitelistUpdate", forKey: .type)
            try balanceAccountAddressWhitelistUpdate.encode(to: encoder)
        case .addressBookUpdate(let addressBookUpdate) where addressBookUpdate.change == .add:
            try container.encode("CreateAddressBookEntry", forKey: .type)
            try addressBookUpdate.entry.encode(to: encoder)
        case .addressBookUpdate(let addressBookUpdate):
            try container.encode("DeleteAddressBookEntry", forKey: .type)
            try addressBookUpdate.entry.encode(to: encoder)
        case .vaultPolicyUpdate(let vaultPolicyUpdate):
            try container.encode("VaultPolicyUpdate", forKey: .type)
            try vaultPolicyUpdate.encode(to: encoder)
        case .ethereumDAppTransactionRequest(let dAppTransactionRequest):
            try container.encode("EthereumDAppTransactionRequest", forKey: .type)
            try dAppTransactionRequest.encode(to: encoder)
        }
    }
}
