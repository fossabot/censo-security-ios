//
//  EthereumClientModel.swift
//  Censo
//
//  Created by Ata Namvari on 2023-01-30.
//

import Foundation

struct EthereumSigningData: Codable, Equatable  {
    var transaction: EvmTransaction
    
    enum CodingKeys: String, CodingKey {
        case type
        case transaction
    }
    
    init(transaction: EvmTransaction) {
        self.transaction = transaction
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.transaction = try container.decode(EvmTransaction.self, forKey: .transaction)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("ethereum", forKey: .type)
        try container.encode(transaction, forKey: .transaction)
    }
    
}

struct EthereumWalletCreation: Codable, Equatable  {
    var identifier: String
    var name: String
    var approvalPolicy: ApprovalPolicy
    var whitelistEnabled: BooleanSetting
    var dappsEnabled: BooleanSetting
    var fee: Amount
    var feeSymbolInfo: EvmSymbolInfo
}
    
struct EthereumWithdrawalRequest: Codable, Equatable  {
    var wallet: WalletInfo
    var amount: Amount
    var symbolInfo: EvmSymbolInfo
    var fee: Amount
    var feeSymbolInfo: EvmSymbolInfo
    var destination: DestinationAddress
    var signingData: EthereumSigningData
}

struct EthereumWalletNameUpdate: Codable, Equatable  {
    var wallet: WalletInfo
    var newName: String
    var signingData: EthereumSigningData
}

struct EthereumTransferPolicyUpdate: Codable, Equatable  {
    var wallet: WalletInfo
    var approvalPolicy: ApprovalPolicy
    var currentOnChainPolicy: OnChainPolicy
    var fee: Amount
    var feeSymbolInfo: EvmSymbolInfo
    var signingData: EthereumSigningData
}

struct EthereumWalletSettingsUpdate: Codable, Equatable  {
    enum Change: Equatable {
        case whitelistEnabled(Bool)
        case dappsEnabled(Bool)
    }

    var wallet: WalletInfo
    var currentGuardAddress: String
    var change: Change
    var signingData: EthereumSigningData

    enum CodingKeys: String, CodingKey {
        case wallet
        case currentGuardAddress
        case whitelistEnabled
        case dappsEnabled
        case signingData
    }

    init(wallet: WalletInfo, currentGuardAddress: String, change: Change, signingData: EthereumSigningData) {
        self.wallet = wallet
        self.currentGuardAddress = currentGuardAddress
        self.change = change
        self.signingData = signingData
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.wallet = try container.decode(WalletInfo.self, forKey: .wallet)
        self.signingData = try container.decode(EthereumSigningData.self, forKey: .signingData)
        self.currentGuardAddress = try container.decode(String.self, forKey: .currentGuardAddress)

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
        try container.encode(wallet, forKey: .wallet)
        try container.encode(currentGuardAddress, forKey: .currentGuardAddress)
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
    var wallet: WalletInfo
    var destinations: [DestinationAddress]
    var currentOnChainWhitelist: [String]
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

    var wallet: WalletInfo
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
        EthereumSigningData(transaction: .sample)
    }
}

#endif
