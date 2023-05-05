//
//  PolgygonClientModel.swift
//  Censo
//
//  Created by Brendan Flood on 2/8/23.
//

import Foundation

struct PolygonSigningData: Codable, Equatable  {
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
        try container.encode("polygon", forKey: .type)
        try container.encode(transaction, forKey: .transaction)
    }
    
}

struct PolygonWalletCreation: Codable, Equatable  {
    var identifier: String
    var name: String
    var approvalPolicy: ApprovalPolicy
    var whitelistEnabled: BooleanSetting
    var dappsEnabled: BooleanSetting
    var fee: Amount
    var feeSymbolInfo: EvmSymbolInfo
}
    
struct PolygonWithdrawalRequest: Codable, Equatable  {
    var wallet: WalletInfo
    var amount: Amount
    var symbolInfo: EvmSymbolInfo
    var fee: Amount
    var feeSymbolInfo: EvmSymbolInfo
    var destination: DestinationAddress
    var signingData: PolygonSigningData
}

struct PolygonWalletNameUpdate: Codable, Equatable  {
    var wallet: WalletInfo
    var newName: String
    var fee: Amount
    var feeSymbolInfo: EvmSymbolInfo
    var signingData: PolygonSigningData
}

struct PolygonTransferPolicyUpdate: Codable, Equatable  {
    var wallet: WalletInfo
    var approvalPolicy: ApprovalPolicy
    var currentOnChainPolicy: OnChainPolicy
    var fee: Amount
    var feeSymbolInfo: EvmSymbolInfo
    var signingData: PolygonSigningData
}

struct PolygonWalletSettingsUpdate: Codable, Equatable  {

    var wallet: WalletInfo
    var currentGuardAddress: String
    var change: Change
    var signingData: PolygonSigningData
    var fee: Amount
    var feeSymbolInfo: EvmSymbolInfo

    enum CodingKeys: String, CodingKey {
        case wallet
        case currentGuardAddress
        case whitelistEnabled
        case dappsEnabled
        case signingData
        case fee
        case feeSymbolInfo
    }

    init(wallet: WalletInfo, currentGuardAddress: String, change: Change, signingData: PolygonSigningData, fee: Amount, feeSymbolInfo: EvmSymbolInfo) {
        self.wallet = wallet
        self.currentGuardAddress = currentGuardAddress
        self.change = change
        self.signingData = signingData
        self.fee = fee
        self.feeSymbolInfo = feeSymbolInfo
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.wallet = try container.decode(WalletInfo.self, forKey: .wallet)
        self.signingData = try container.decode(PolygonSigningData.self, forKey: .signingData)
        self.currentGuardAddress = try container.decode(String.self, forKey: .currentGuardAddress)
        self.fee = try container.decode(Amount.self, forKey: .fee)
        self.feeSymbolInfo = try container.decode(EvmSymbolInfo.self, forKey: .feeSymbolInfo)

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
        try container.encode(fee, forKey: .fee)
        try container.encode(feeSymbolInfo, forKey: .feeSymbolInfo)

        switch change {
        case .whitelistEnabled(let bool):
            try container.encode(bool ? BooleanSetting.On : .Off, forKey: .whitelistEnabled)
        case .dappsEnabled(let bool):
            try container.encode(bool ? BooleanSetting.On : .Off, forKey: .dappsEnabled)
        }
    }
}

struct PolygonWalletWhitelistUpdate: Codable, Equatable  {
    var wallet: WalletInfo
    var destinations: [DestinationAddress]
    var currentOnChainWhitelist: [String]
    var signingData: PolygonSigningData
    var fee: Amount
    var feeSymbolInfo: EvmSymbolInfo
}

struct PolygonDAppRequest: Codable, Equatable {
    var wallet: WalletInfo
    var fee: Amount
    var feeSymbolInfo: EvmSymbolInfo
    var dappInfo: DAppInfo
    var dappParams: DAppParams
    var signingData: PolygonSigningData
}

#if DEBUG

extension PolygonSigningData {
    static var sample: Self {
        PolygonSigningData(transaction: .sample)
    }
}

#endif
