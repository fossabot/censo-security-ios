//
//  RecoverySignable.swift
//  Censo
//
//  Created by Brendan Flood on 5/1/23.
//

import Foundation
import CryptoKit

extension OrgAdminRecoveryRequest {
    private func getSafeHash(chain: Chain, evmTransaction: EvmTransaction) throws -> String {
        guard let adminRecoveryTxs = recoveryTxs.first(where: {$0.chain == chain} ) else {
            throw EvmConfigError.missingChain
        }
        return EvmRecoveryTransactionBuilder.getRecoveryContractExecutionFromModuleDataSafeHash(adminRecoveryTxs: adminRecoveryTxs, evmTransaction: evmTransaction).base64EncodedString()
    }
    
    func toJsonString() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
    func toRecoveryAppSigningRequest() throws -> RecoveryAppSigningRequest {
        let jsonData = try JSONEncoder().encode(self)
        return RecoveryAppSigningRequest(
            items: try signingData.map {
                switch $0 {
                case .ethereum(let signingData):
                    return SignableRecoveryItem(chain: Chain.ethereum, dataToSign: try getSafeHash(chain: Chain.ethereum, evmTransaction: signingData.transaction))
                case .polygon(let signingData):
                    return SignableRecoveryItem(chain: Chain.polygon, dataToSign: try getSafeHash(chain: Chain.polygon, evmTransaction: signingData.transaction))
                }
            } + [SignableRecoveryItem(chain: Chain.offchain, dataToSign: Data(SHA256.hash(data: jsonData)).base64EncodedString())]
        )
    }
}
