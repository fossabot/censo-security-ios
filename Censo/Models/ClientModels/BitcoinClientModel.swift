//
//  BitcoinClientModel.swift
//  Censo
//
//  Created by Ata Namvari on 2023-01-30.
//

import Foundation

struct BitcoinWalletCreation: Codable, Equatable  {
    var accountSlot: UInt8
    var accountInfo: AccountInfo
    var approvalPolicy: ApprovalPolicy
    var whitelistEnabled: BooleanSetting
    var dappsEnabled: BooleanSetting
    var addressBookSlot: UInt8
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

struct BitcoinWithdrawalRequest: Codable, Equatable  {
    var account: AccountInfo
    var symbolAndAmountInfo: SymbolAndAmountInfo
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
            account: .sample,
            symbolAndAmountInfo: .sample,
            destination: .sample,
            signingData: .sample
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
