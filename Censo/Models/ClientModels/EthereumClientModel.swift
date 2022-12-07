//
//  EthereumClientModel.swift
//  Censo
//
//  Created by Ata Namvari on 2023-01-30.
//

import Foundation

struct EthereumWalletCreation: Codable, Equatable  {
    var accountSlot: UInt8
    var accountInfo: AccountInfo
    var approvalPolicy: ApprovalPolicy
    var whitelistEnabled: BooleanSetting
    var dappsEnabled: BooleanSetting
    var addressBookSlot: UInt8
}

struct EthereumAddressBookEntry: Codable, Equatable {
    var name: String
    var address: String
}

struct EthTokenInfo: Codable, Equatable {
    let tokenMintAddress: String
    let tokenType: EthTokenType
}

enum EthTokenType: Codable, Equatable {
    case erc20
    case erc721(tokenId: String)
    case erc1155(tokenId: String)
}

struct EthereumTransaction: Codable, Equatable {
    let safeNonce: UInt64
    let chainId: UInt64
}

struct EthereumSigningData: Codable, Equatable {
    let transaction: EthereumTransaction
}

struct EthereumWithdrawalRequest: Codable, Equatable  {
    var account: AccountInfo
    var symbolAndAmountInfo: SymbolAndAmountInfo
    var tokenInfo: EthTokenInfo? // TODO: Backend may or may not provide this conveniently - ask Anton
    var destination: DestinationAddress
    var signingData: EthereumSigningData
}

struct EthereumWalletNameUpdate: Codable, Equatable  {
    var account: AccountInfo
    var newAccountName: String
    var signingData: EthereumSigningData
}

struct EthereumTransferPolicyUpdate: Codable, Equatable  {
    var account: AccountInfo
    var approvalPolicy: ApprovalPolicy
    var signingData: EthereumSigningData
}

struct EthereumWalletSettingsUpdate: Codable, Equatable  {
    enum Change: Equatable {
        case whitelistEnabled(Bool)
        case dappsEnabled(Bool)
    }

    var account: AccountInfo
    var change: Change
    var signingData: EthereumSigningData

    enum CodingKeys: String, CodingKey {
        case account
        case whitelistEnabled
        case dappsEnabled
        case signingData
    }

    init(account: AccountInfo, change: Change, signingData: EthereumSigningData) {
        self.account = account
        self.change = change
        self.signingData = signingData
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.account = try container.decode(AccountInfo.self, forKey: .account)
        self.signingData = try container.decode(EthereumSigningData.self, forKey: .signingData)

        let whitelistEnabled = try container.decode(BooleanSetting?.self, forKey: .whitelistEnabled)
        let dappsEnabled = try container.decode(BooleanSetting?.self, forKey: .dappsEnabled)

        if let whitelistEnabled = whitelistEnabled, dappsEnabled == nil {
            self.change = .whitelistEnabled(whitelistEnabled == .On)
        } else if let dappsEnabled = dappsEnabled, whitelistEnabled == nil {
            self.change = .dappsEnabled(dappsEnabled == .On)
        } else {
            throw DecodingError.dataCorruptedError(forKey: .whitelistEnabled, in: container, debugDescription: "Only one setting should be changed")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(account, forKey: .account)
        try container.encode(signingData, forKey: .signingData)

        switch change {
        case .whitelistEnabled(let bool):
            try container.encode(bool ? BooleanSetting.On : .Off, forKey: .whitelistEnabled)
        case .dappsEnabled(let bool):
            try container.encode(bool ? BooleanSetting.On : .Off, forKey: .dappsEnabled)
        }
    }
}

struct EthereumWalletWhitelistUpdate: Codable, Equatable  {
    var account: AccountInfo
    var destinations: [DestinationAddress]
    var signingData: EthereumSigningData
}

struct EthereumDAppTransactionRequest: Codable, Equatable  {
    struct SymbolAndAmountInfo: Codable, Equatable {
        struct SymbolInfo: Codable, Equatable {
            let symbol: String
            let symbolDescription: String
        }

        let symbolInfo: SymbolInfo
        let amount: String
        let usdEquivalent: String?
    }

    var account: AccountInfo
    var dappInfo: DAppInfo
    var balanceChanges: [SymbolAndAmountInfo]
    var signingData: EthereumSigningData
}

struct DAppInfo: Codable, Equatable {
    let address: String
    let name: String
}

#if DEBUG
extension EthereumSigningData {
    static var sample: Self {
        EthereumSigningData(transaction: EthereumTransaction(safeNonce: 0, chainId: 1))
    }
}
#endif
