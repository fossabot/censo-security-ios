//
//  BitcoinClientModel.swift
//  Censo
//
//  Created by Ata Namvari on 2023-01-30.
//

import Foundation

struct BitcoinWalletCreation: Codable, Equatable  {
    var identifier: String
    var name: String
    var approvalPolicy: ApprovalPolicy
}

struct BitcoinWalletNameUpdate: Codable, Equatable  {
    var wallet: WalletInfo
    var newName: String
}

struct BitcoinTransaction: Codable, Equatable {
    let version: Int
    let txIns: [TransactionInput]
    let txOuts: [TransactionOutput]
    let totalFee: Int64
}

struct BitcoinSigningData: Codable, Equatable {
    let childKeyIndex: UInt32
    let transaction: BitcoinTransaction
}

struct BitcoinSymbolInfo: Codable, Equatable {
    let symbol: String
    let description: String
    let imageUrl: String?
}

struct BitcoinWithdrawalRequest: Codable, Equatable  {
    var wallet: WalletInfo
    var amount: Amount
    var symbolInfo: BitcoinSymbolInfo
    var fee: Amount
    var replacementFee: Amount?
    var destination: DestinationAddress
    var signingData: BitcoinSigningData
}


struct TransactionInput: Codable, Equatable {
    let txId: String
    let index: Int
    let amount: Int64
    let inputScriptHex: String
    let base64HashForSignature: String
}

struct TransactionOutput: Codable, Equatable {
    let index: Int
    let amount: Int64
    let pubKeyScriptHex: String
    let address: String
    let isChange: Bool
}

#if DEBUG
extension BitcoinWithdrawalRequest {
    static var sample: Self {
        BitcoinWithdrawalRequest(
            wallet: .sample,
            amount: .sample,
            symbolInfo: .sample,
            fee: .sample,
            replacementFee: nil,
            destination: .sample,
            signingData: .sample
        )
    }
}

extension BitcoinSymbolInfo {
    static var sample: Self {
        BitcoinSymbolInfo(
            symbol: "BTC", description: "Bitcoin", imageUrl: nil
        )
    }
}

extension BitcoinSigningData {
    static var sample: Self {
        BitcoinSigningData(childKeyIndex: 0, transaction: .sample)
    }
}

extension BitcoinTransaction {
    static var sample: Self {
        BitcoinTransaction(version: 1, txIns: [], txOuts: [], totalFee: 2)
    }
}
#endif
