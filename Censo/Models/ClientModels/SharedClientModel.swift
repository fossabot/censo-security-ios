//
//  SharedClientModel.swift
//  Censo
//
//  Created by Ata Namvari on 2022-03-07.
//

import Foundation

enum ApprovalDisposition: String, Codable {
    case Approve
    case Deny
}

enum BooleanSetting: String, Codable {
    case Off
    case On
    
    func toSolanaProgramValue() -> UInt8 {
        switch self {
        case .Off:
            return 0
        case .On:
            return 1
        }
    }
}

enum Chain: String, Codable {
    case bitcoin = "bitcoin"
    case ethereum = "ethereum"
    case censo = "censo"
}

enum LogoType: String, Codable {
    case png = "png"
    case jpeg = "jpeg"
    case svg = "svg"
    case ico = "ico"
}

enum AddressBookChange {
    case add
    case remove
}

struct AddressBookEntry: Codable, Equatable {
    var chain: Chain
    var name: String
    var address: String
}

struct AddressBookUpdate: Equatable {
    var change: AddressBookChange
    var entry: AddressBookEntry
}

struct DestinationAddress: Codable, Equatable {
    let name: String
    let subName: String?
    let address: String
    let tag: String?
}

enum AccountType: String, Codable {
    case BalanceAccount = "BalanceAccount"
    case StakeAccount = "StakeAccount"
}

struct SymbolInfo: Codable, Equatable {
    let symbol: String
    let symbolDescription: String
    let tokenMintAddress: String?
    let imageUrl: String?
    let nftMetadata: NftMetadata?
}

struct SymbolAndAmountInfo: Codable, Equatable {
    let symbolInfo: SymbolInfo
    let amount: String
    let nativeAmount: String?
    let usdEquivalent: String?
    let fee: Fee?
    let replacementFee: Fee?
}

struct Fee: Codable, Equatable {
    let symbolInfo: SymbolInfo
    let amount: String
    let usdEquivalent: String?
}

struct AccountInfo: Codable, Equatable {
    let name: String
    let identifier: String
    let accountType: AccountType
    let address: String
    let chain: Chain
}

struct SignerInfo: Codable, Equatable {
    let publicKey: String
    let name: String
    let email: String
    let nameHashIsEmpty: Bool
}

struct ApprovalPolicy: Codable, Equatable {
    let approvalsRequired: UInt8
    let approvalTimeout: UInt64
    let approvers: [SignerInfo]
}

struct WhitelistUpdate: Codable, Equatable {
    let account: AccountInfo
    let destinationsToAdd: [DestinationAddress]
    let destinationsToRemove: [DestinationAddress]
}

struct NftMetadata: Codable, Equatable {
    let name: String
}

struct VaultPolicyUpdate: Codable, Equatable  {
    var approvalPolicy: ApprovalPolicy
}

struct LoginApproval: Codable, Equatable  {
    var jwtToken: String
    var email: String
    var name: String
}

struct AcceptVaultInvitation: Codable, Equatable  {
    var vaultGuid: String
    var vaultName: String
}

// TODO: This may not be needed
struct PasswordReset: Codable, Equatable  {}

#if DEBUG
extension ApprovalRequest {
    static var sample: Self {
        ApprovalRequest(
            id: "id",
            submitterName: "John Q",
            submitterEmail: "johnq@gmail.com",
            submitDate: Date(),
            approvalTimeoutInSeconds: 40000,
            numberOfDispositionsRequired: 3,
            numberOfApprovalsReceived: 1,
            numberOfDeniesReceived: 1,
            vaultName: "Test Vault",
            initiationOnly: false,
            details: .bitcoinWithdrawalRequest(.sample)
        )
    }

    static var sample2: Self {
        ApprovalRequest(
            id: "id",
            submitterName: "John Q",
            submitterEmail: "johnq@gmail.com",
            submitDate: Date(),
            approvalTimeoutInSeconds: 40000,
            numberOfDispositionsRequired: 3,
            numberOfApprovalsReceived: 1,
            numberOfDeniesReceived: 1,
            vaultName: "Test Vault",
            initiationOnly: false,
            details: .bitcoinWithdrawalRequest(.sample)
        )
    }
    
    static var feeBump: Self {
        ApprovalRequest(
            id: "id",
            submitterName: "John Q",
            submitterEmail: "johnq@gmail.com",
            submitDate: Date(),
            approvalTimeoutInSeconds: 40000,
            numberOfDispositionsRequired: 3,
            numberOfApprovalsReceived: 1,
            numberOfDeniesReceived: 1,
            vaultName: "Test Vault",
            initiationOnly: false,
            details: .bitcoinWithdrawalRequest(.sample)
        )
    }
}

extension DestinationAddress {
    static var sample: Self {
        DestinationAddress(
            name: "Dest",
            subName: "Sub",
            address: "32853987g87h",
            tag: nil
        )
    }
}

extension AccountInfo {
    static var sample: Self {
        AccountInfo(
            name: "Main",
            identifier: "identifier",
            accountType: AccountType.BalanceAccount,
            address: "83746gfd8bj7",
            chain: .ethereum
        )
    }
}

extension SymbolAndAmountInfo {
    static var sample: Self {
        SymbolAndAmountInfo(
            symbolInfo: .sample,
            amount: "234325.000564",
            nativeAmount: "234325.00056400",
            usdEquivalent: "2353453",
            fee: Fee(
                symbolInfo: .sample,
                amount: "0.0000123",
                usdEquivalent: "10.12"
            ),
            replacementFee: nil
        )
    }
    
    static var feeBump: Self {
        SymbolAndAmountInfo(
            symbolInfo: .sample,
            amount: "234325.000564",
            nativeAmount: "234325.00056400",
            usdEquivalent: "2353453",
            fee: Fee(
                symbolInfo: .sample,
                amount: "0.0000123",
                usdEquivalent: "10.12"
            ),
            replacementFee: Fee(
                symbolInfo: .sample,
                amount: "0.0000246",
                usdEquivalent: "20.24"
            )
        )
    }
}

extension SymbolInfo {
    static var sample: Self {
        SymbolInfo(
            symbol: "BTC",
            symbolDescription: "Bitcoin",
            tokenMintAddress: "28548397fdsf",
            imageUrl: nil,
            nftMetadata: nil
        )
    }
}

#endif
