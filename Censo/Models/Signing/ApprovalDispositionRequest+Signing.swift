//
//  ApprovalDispositionRequest+Signing.swift
//  Censo
//
//  Created by Ata Namvari on 2023-01-30.
//

import Foundation
import Moya
import CryptoKit

struct DeviceSigner {
    private var deviceKey: DeviceKey
    private var encryptedRootSeed: Data

    init(deviceKey: DeviceKey, encryptedRootSeed: Data) {
        self.deviceKey = deviceKey
        self.encryptedRootSeed = encryptedRootSeed
    }

    func deviceSignature(for data: Data) throws -> Data {
        try deviceKey.signature(for: data)
    }

    func privateKeys() throws -> PrivateKeys {
        let rootSeed = try deviceKey.decrypt(data: encryptedRootSeed)
        return try PrivateKeys(rootSeed: rootSeed.bytes)
    }

    func devicePublicKey() throws -> String {
        try deviceKey.publicExternalRepresentation().base58String
    }
}

extension ApprovalDispositionRequest {
    func signatureInfos(using deviceSigner: DeviceSigner, apiProvider: MoyaProvider<CensoApi.Target>) async throws -> [SignatureInfo]  {
        switch request.details {
        case .loginApproval(let request):
            let dataToSign = request.jwtToken.data(using: .utf8)!

            return [
                .offchain(
                    OffChainSignature(
                        signature: try deviceSigner.deviceSignature(for: dataToSign).base64EncodedString(),
                        signedData: dataToSign.base64EncodedString()
                    )
                )
            ]
        case .passwordReset:
            let dataToSign = request.id.data(using: .utf8)!

            return [
                .offchain(
                    OffChainSignature(
                        signature: try deviceSigner.deviceSignature(for: dataToSign).base64EncodedString(),
                        signedData: dataToSign.base64EncodedString()
                    )
                )
            ]
        case .ethereumWalletCreation,
             .bitcoinWalletCreation,
             .polygonWalletCreation,
             .bitcoinWalletNameUpdate,
             .vaultCreation,
             .addDevice,
             .addressBookUpdate,
             .orgNameUpdate,
             .vaultUserRolesUpdate:
            let detailsJSONData = try JSONEncoder().encode(request.details)
            let privateKeys = try deviceSigner.privateKeys()

            return [
                .offchain(
                    OffChainSignature(
                        signature: try privateKeys.signature(for: Data(SHA256.hash(data: detailsJSONData)), chain: Chain.offchain),
                        signedData: detailsJSONData.base64EncodedString()
                    )
                )
            ]
            
        case .vaultPolicyUpdate(let signableRequest as MultichainSignable),
             .vaultNameUpdate(let signableRequest as MultichainSignable),
             .orgAdminPolicyUpdate(let signableRequest as MultichainSignable):
            let privateKeys = try deviceSigner.privateKeys()
            let detailsJSONData = try JSONEncoder().encode(request.details)
            var signatures: [SignatureInfo] = [
                .offchain(
                    OffChainSignature(
                        signature: try privateKeys.signature(for: Data(SHA256.hash(data: detailsJSONData)), chain: Chain.offchain),
                        signedData: detailsJSONData.base64EncodedString()
                    )
                )
            ]
                        
            for (chain, dataToSign) in try signableRequest.signableData() {
                switch chain {
                case Chain.ethereum:
                    signatures.append(
                        .ethereum(
                            EthereumSignature(
                                signature: try privateKeys.signature(for: dataToSign, chain: Chain.ethereum)
                            )
                        )
                     )
                case Chain.polygon:
                    signatures.append(
                        .polygon(
                            PolygonSignature(
                                signature: try privateKeys.signature(for: dataToSign, chain: Chain.ethereum)
                            )
                        )
                     )
                default:
                    break
                }
            }
            return signatures
            
        case .ethereumWithdrawalRequest(let request as EvmSignable),
             .ethereumWalletNameUpdate(let request as EvmSignable),
             .ethereumWalletSettingsUpdate(let request as EvmSignable),
             .ethereumWalletWhitelistUpdate(let request as EvmSignable):
            let privateKeys = try deviceSigner.privateKeys()

            return [
                .ethereum(
                    EthereumSignature(
                        signature: try privateKeys.signature(for: try request.signableData(), chain: .ethereum)
                    )
                )
            ]
        
        case .polygonWithdrawalRequest(let request as EvmSignable),
             .polygonWalletNameUpdate(let request as EvmSignable),
             .polygonWalletSettingsUpdate(let request as EvmSignable),
             .polygonWalletWhitelistUpdate(let request as EvmSignable):
            let privateKeys = try deviceSigner.privateKeys()

            return [
                .polygon(
                    PolygonSignature(
                        signature: try privateKeys.signature(for: try request.signableData(), chain: .polygon)
                    )
                )
            ]
            
        case .ethereumTransferPolicyUpdate(let details as EvmSignable):
            let privateKeys = try deviceSigner.privateKeys()
            let detailsJSONData = try JSONEncoder().encode(request.details)

            return [
                .ethereumWithOffchain(
                    EthereumSignatureWithOffchain(
                        signature: try privateKeys.signature(for: try details.signableData(), chain: .ethereum),
                        offchainSignature: OffChainSignature(
                            signature: try privateKeys.signature(for: Data(SHA256.hash(data: detailsJSONData)), chain: Chain.offchain),
                            signedData: detailsJSONData.base64EncodedString()
                        )
                    )
                )
            ]
            
        case .polygonTransferPolicyUpdate(let details as EvmSignable):
            let privateKeys = try deviceSigner.privateKeys()
            let detailsJSONData = try JSONEncoder().encode(request.details)

            return [
                .polygonWithOffchain(
                    PolygonSignatureWithOffchain(
                        signature: try privateKeys.signature(for: try details.signableData(), chain: .polygon),
                        offchainSignature: OffChainSignature(
                            signature: try privateKeys.signature(for: Data(SHA256.hash(data: detailsJSONData)), chain: Chain.offchain),
                            signedData: detailsJSONData.base64EncodedString()
                        )
                    )
                )
            ]
            
        case .bitcoinWithdrawalRequest(let request as BitcoinSignable):
            let dataArrayToSign = try request.signableDataList()
            let derivationPath = DerivationNode.notHardened(request.signingData.childKeyIndex)
            let privateKeys = try deviceSigner.privateKeys()

            return [
                .bitcoin(
                    BitcoinSignatures(
                        signatures: try dataArrayToSign.map { data in
                            try privateKeys.signature(for: data, chain: .bitcoin, derivationPath: derivationPath)
                        }
                    )
                )
            ]
        case .ethereumDAppTransactionRequest(_):
            return []
        }
    }
}

extension CensoApi.ApprovalDispositionPayload {
    init(dispositionRequest: ApprovalDispositionRequest, deviceSigner: DeviceSigner, apiProvider: MoyaProvider<CensoApi.Target>) async throws {
        self.approvalDisposition = dispositionRequest.disposition
        self.requestID = dispositionRequest.request.id
        self.signatures = try await dispositionRequest.signatureInfos(using: deviceSigner, apiProvider: apiProvider)
    }
}
