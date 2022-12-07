//
//  BitcoinSignable.swift
//  Censo
//
//  Created by Ata Namvari on 2023-01-19.
//

import Foundation

protocol BitcoinSignable {
    var signingData: BitcoinSigningData { get }

    func signableDataList() throws -> [Data]
}

extension BitcoinSignable {
    func signableDataList() throws -> [Data] {
        signingData.transaction.txIns.compactMap { tInput in
            Data(base64Encoded: tInput.base64HashForSignature)
        }
    }
}

extension BitcoinWithdrawalRequest: BitcoinSignable {}
