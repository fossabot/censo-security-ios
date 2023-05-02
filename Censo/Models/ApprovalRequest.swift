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
    case passwordReset(PasswordReset)

    case bitcoinWithdrawalRequest(BitcoinWithdrawalRequest)
    case ethereumWithdrawalRequest(EthereumWithdrawalRequest)
    case polygonWithdrawalRequest(PolygonWithdrawalRequest)

    case bitcoinWalletCreation(BitcoinWalletCreation)
    case ethereumWalletCreation(EthereumWalletCreation)
    case polygonWalletCreation(PolygonWalletCreation)

    case ethereumWalletNameUpdate(EthereumWalletNameUpdate)
    case bitcoinWalletNameUpdate(BitcoinWalletNameUpdate)
    case polygonWalletNameUpdate(PolygonWalletNameUpdate)

    case ethereumTransferPolicyUpdate(EthereumTransferPolicyUpdate)
    case polygonTransferPolicyUpdate(PolygonTransferPolicyUpdate)

    case ethereumWalletSettingsUpdate(EthereumWalletSettingsUpdate)
    case polygonWalletSettingsUpdate(PolygonWalletSettingsUpdate)

    case ethereumWalletWhitelistUpdate(EthereumWalletWhitelistUpdate)
    case polygonWalletWhitelistUpdate(PolygonWalletWhitelistUpdate)

    case addressBookUpdate(AddressBookUpdate)

    case vaultPolicyUpdate(VaultPolicyUpdate)
    case vaultCreation(VaultCreation)
    case vaultNameUpdate(VaultNameUpdate)
    
    case orgAdminPolicyUpdate(OrgAdminPolicyUpdate)
    case orgNameUpdate(OrgNameUpdate)
    case vaultUserRolesUpdate(VaultUserRolesUpdate)
    case suspendUser(SuspendUser)
    case restoreUser(RestoreUser)
    case enableRecoveryContract(EnableRecoveryContract)

    case enableDevice(EnableDevice)
    case disableDevice(DisableDevice)

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
        case "PasswordReset":
            self = .passwordReset(try PasswordReset(from: decoder))
        case "BitcoinWithdrawalRequest":
            self = .bitcoinWithdrawalRequest(try BitcoinWithdrawalRequest(from: decoder))
        case "EthereumWithdrawalRequest":
            self = .ethereumWithdrawalRequest(try EthereumWithdrawalRequest(from: decoder))
        case "PolygonWithdrawalRequest":
            self = .polygonWithdrawalRequest(try PolygonWithdrawalRequest(from: decoder))
        case "BitcoinWalletCreation":
            self = .bitcoinWalletCreation(try BitcoinWalletCreation(from: decoder))
        case "BitcoinWalletNameUpdate":
            self = .bitcoinWalletNameUpdate(try BitcoinWalletNameUpdate(from: decoder))
        case "EthereumWalletCreation":
            self = .ethereumWalletCreation(try EthereumWalletCreation(from: decoder))
        case "PolygonWalletCreation":
            self = .polygonWalletCreation(try PolygonWalletCreation(from: decoder))
        case "EthereumWalletNameUpdate":
            self = .ethereumWalletNameUpdate(try EthereumWalletNameUpdate(from: decoder))
        case "PolygonWalletNameUpdate":
            self = .polygonWalletNameUpdate(try PolygonWalletNameUpdate(from: decoder))
        case "EthereumWalletSettingsUpdate":
            self = .ethereumWalletSettingsUpdate(try EthereumWalletSettingsUpdate(from: decoder))
        case "PolygonWalletSettingsUpdate":
            self = .polygonWalletSettingsUpdate(try PolygonWalletSettingsUpdate(from: decoder))
        case "EthereumWalletWhitelistUpdate":
            self = .ethereumWalletWhitelistUpdate(try EthereumWalletWhitelistUpdate(from: decoder))
        case "PolygonWalletWhitelistUpdate":
            self = .polygonWalletWhitelistUpdate(try PolygonWalletWhitelistUpdate(from: decoder))
        case "EthereumTransferPolicyUpdate":
            self = .ethereumTransferPolicyUpdate(try EthereumTransferPolicyUpdate(from: decoder))
        case "PolygonTransferPolicyUpdate":
            self = .polygonTransferPolicyUpdate(try PolygonTransferPolicyUpdate(from: decoder))
        case "CreateAddressBookEntry":
            let entry = try AddressBookEntry(from: decoder)
            self = .addressBookUpdate(AddressBookUpdate(change: .add, entry: entry))
        case "DeleteAddressBookEntry":
            let entry = try AddressBookEntry(from: decoder)
            self = .addressBookUpdate(AddressBookUpdate(change: .remove, entry: entry))
        case "VaultPolicyUpdate":
            self = .vaultPolicyUpdate(try VaultPolicyUpdate(from: decoder))
        case "VaultCreation":
            self = .vaultCreation(try VaultCreation(from: decoder))
        case "VaultNameUpdate":
            self = .vaultNameUpdate(try VaultNameUpdate(from: decoder))
        case "OrgAdminPolicyUpdate":
            self = .orgAdminPolicyUpdate(try OrgAdminPolicyUpdate(from: decoder))
        case "OrgNameUpdate":
            self = .orgNameUpdate(try OrgNameUpdate(from: decoder))
        case "VaultUserRolesUpdate":
            self = .vaultUserRolesUpdate(try VaultUserRolesUpdate(from: decoder))
        case "EnableDevice":
            self = .enableDevice(try EnableDevice(from: decoder))
        case "DisableDevice":
            self = .disableDevice(try DisableDevice(from: decoder))
        case "SuspendUser":
            self = .suspendUser(try SuspendUser(from: decoder))
        case "RestoreUser":
            self = .restoreUser(try RestoreUser(from: decoder))
        case "EnableRecoveryContract":
            self = .enableRecoveryContract(try EnableRecoveryContract(from: decoder))
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
        case .passwordReset(let passwordReset):
            try container.encode("PasswordReset", forKey: .type)
            try passwordReset.encode(to: encoder)
        case .bitcoinWithdrawalRequest(let withdrawalRequest):
            try container.encode("BitcoinWithdrawalRequest", forKey: .type)
            try withdrawalRequest.encode(to: encoder)
        case .ethereumWithdrawalRequest(let withdrawalRequest):
            try container.encode("EthereumWithdrawalRequest", forKey: .type)
            try withdrawalRequest.encode(to: encoder)
        case .polygonWithdrawalRequest(let withdrawalRequest):
            try container.encode("PolygonWithdrawalRequest", forKey: .type)
            try withdrawalRequest.encode(to: encoder)
        case .bitcoinWalletCreation(let walletCreation):
            try container.encode("BitcoinWalletCreation", forKey: .type)
            try walletCreation.encode(to: encoder)
        case .bitcoinWalletNameUpdate(let walletNameUpdate):
            try container.encode("BitcoinWalletNameUpdate", forKey: .type)
            try walletNameUpdate.encode(to: encoder)
        case .ethereumWalletCreation(let walletCreation):
            try container.encode("EthereumWalletCreation", forKey: .type)
            try walletCreation.encode(to: encoder)
        case .polygonWalletCreation(let walletCreation):
            try container.encode("PolygonWalletCreation", forKey: .type)
            try walletCreation.encode(to: encoder)
        case .ethereumWalletNameUpdate(let walletNameUpdate):
            try container.encode("EthereumWalletNameUpdate", forKey: .type)
            try walletNameUpdate.encode(to: encoder)
        case .polygonWalletNameUpdate(let walletNameUpdate):
            try container.encode("PolygonWalletNameUpdate", forKey: .type)
            try walletNameUpdate.encode(to: encoder)
        case .ethereumTransferPolicyUpdate(let transferPolicyUpdate):
            try container.encode("EthereumTransferPolicyUpdate", forKey: .type)
            try transferPolicyUpdate.encode(to: encoder)
        case .polygonTransferPolicyUpdate(let transferPolicyUpdate):
            try container.encode("PolygonTransferPolicyUpdate", forKey: .type)
            try transferPolicyUpdate.encode(to: encoder)
        case .ethereumWalletSettingsUpdate(let walletSettingsUpdate):
            try container.encode("EthereumWalletSettingsUpdate", forKey: .type)
            try walletSettingsUpdate.encode(to: encoder)
        case .polygonWalletSettingsUpdate(let walletSettingsUpdate):
            try container.encode("PolygonWalletSettingsUpdate", forKey: .type)
            try walletSettingsUpdate.encode(to: encoder)
        case .ethereumWalletWhitelistUpdate(let walletWhitelistUpdate):
            try container.encode("EthereumWalletWhitelistUpdate", forKey: .type)
            try walletWhitelistUpdate.encode(to: encoder)
        case .polygonWalletWhitelistUpdate(let walletWhitelistUpdate):
            try container.encode("PolygonWalletWhitelistUpdate", forKey: .type)
            try walletWhitelistUpdate.encode(to: encoder)
        case .addressBookUpdate(let addressBookUpdate) where addressBookUpdate.change == .add:
            try container.encode("CreateAddressBookEntry", forKey: .type)
            try addressBookUpdate.entry.encode(to: encoder)
        case .addressBookUpdate(let addressBookUpdate):
            try container.encode("DeleteAddressBookEntry", forKey: .type)
            try addressBookUpdate.entry.encode(to: encoder)
        case .vaultPolicyUpdate(let vaultPolicyUpdate):
            try container.encode("VaultPolicyUpdate", forKey: .type)
            try vaultPolicyUpdate.encode(to: encoder)
        case .vaultCreation(let vaultCreation):
            try container.encode("VaultCreation", forKey: .type)
            try vaultCreation.encode(to: encoder)
        case .vaultNameUpdate(let vaultNameUpdate):
            try container.encode("VaultNameUpdate", forKey: .type)
            try vaultNameUpdate.encode(to: encoder)
        case .orgAdminPolicyUpdate(let orgAdminPolicyUpdate):
            try container.encode("OrgAdminPolicyUpdate", forKey: .type)
            try orgAdminPolicyUpdate.encode(to: encoder)
        case .orgNameUpdate(let orgNameUpdate):
            try container.encode("OrgNameUpdate", forKey: .type)
            try orgNameUpdate.encode(to: encoder)
        case .vaultUserRolesUpdate(let update):
            try container.encode("VaultUserRolesUpdate", forKey: .type)
            try update.encode(to: encoder)
        case .enableDevice(let enableDevice):
            try container.encode("EnableDevice", forKey: .type)
            try enableDevice.encode(to: encoder)
        case .disableDevice(let disableDevice):
            try container.encode("DisableDevice", forKey: .type)
            try disableDevice.encode(to: encoder)
        case .ethereumDAppTransactionRequest(let dAppTransactionRequest):
            try container.encode("EthereumDAppTransactionRequest", forKey: .type)
            try dAppTransactionRequest.encode(to: encoder)
        case .suspendUser(let suspendUser):
            try container.encode("SuspendUser", forKey: .type)
            try suspendUser.encode(to: encoder)
        case .restoreUser(let restoreUser):
            try container.encode("RestoreUser", forKey: .type)
            try restoreUser.encode(to: encoder)
        case .enableRecoveryContract(let enableRecoveryContract):
            try container.encode("EnableRecoveryContract", forKey: .type)
            try enableRecoveryContract.encode(to: encoder)
        }
    }
}
