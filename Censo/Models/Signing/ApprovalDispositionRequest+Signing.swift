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
    func signatureInfos(using deviceSigner: DeviceSigner, apiProvider: MoyaProvider<CensoApi.Target>) async throws -> [SignatureInfo] {
        switch disposition {
        case .Approve:
            switch request.details {
            case .loginApproval(let request):
                return try getLoginSignatureInfos(using: deviceSigner, request: request)
            case .passwordReset:
                return try getPasswordResetSignatureInfos(using: deviceSigner)
            case .ethereumWalletCreation,
                    .bitcoinWalletCreation,
                    .polygonWalletCreation,
                    .bitcoinWalletNameUpdate,
                    .vaultCreation,
                    .addDevice,
                    .removeDevice,
                    .addressBookUpdate,
                    .orgNameUpdate,
                    .vaultUserRolesUpdate,
                    .suspendUser,
                    .restoreUser:
                return [try .offchain(getApprovalRequestDetailsSignature(using: deviceSigner, privateKeys: try deviceSigner.privateKeys()))]
                
            case .vaultPolicyUpdate(let signableRequest as MultichainSignable),
                    .vaultNameUpdate(let signableRequest as MultichainSignable),
                    .orgAdminPolicyUpdate(let signableRequest as MultichainSignable),
                    .enableRecoveryContract(let signableRequest as MultichainSignable):
                let privateKeys = try deviceSigner.privateKeys()
                var signatures: [SignatureInfo] = [
                    .offchain(try getApprovalRequestDetailsSignature(using: deviceSigner, privateKeys: privateKeys))
                ]
                
                for (chain, dataToSign) in try signableRequest.signableData() {
                    switch chain {
                    case Chain.ethereum:
                        signatures.append(
                            .ethereumWithOffchain(
                                EthereumSignatureWithOffchain(
                                    signature: try privateKeys.signature(for: dataToSign, chain: Chain.ethereum),
                                    offchainSignature: try getApprovalRequestDetailsSignature(using: deviceSigner, privateKeys: privateKeys)
                                )
                            )
                        )
                    case Chain.polygon:
                        signatures.append(
                            .polygonWithOffchain(
                                PolygonSignatureWithOffchain(
                                    signature: try privateKeys.signature(for: dataToSign, chain: Chain.ethereum),
                                    offchainSignature: try getApprovalRequestDetailsSignature(using: deviceSigner, privateKeys: privateKeys)
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
                    .ethereumWithOffchain(
                        EthereumSignatureWithOffchain(
                            signature: try privateKeys.signature(for: try request.signableData(), chain: .ethereum),
                            offchainSignature: try getApprovalRequestDetailsSignature(using: deviceSigner, privateKeys: privateKeys)
                        )
                    )
                ]
                
            case .polygonWithdrawalRequest(let request as EvmSignable),
                    .polygonWalletNameUpdate(let request as EvmSignable),
                    .polygonWalletSettingsUpdate(let request as EvmSignable),
                    .polygonWalletWhitelistUpdate(let request as EvmSignable):
                let privateKeys = try deviceSigner.privateKeys()
                
                return [
                    .polygonWithOffchain(
                        PolygonSignatureWithOffchain(
                            signature: try privateKeys.signature(for: try request.signableData(), chain: .polygon),
                            offchainSignature: try getApprovalRequestDetailsSignature(using: deviceSigner, privateKeys: privateKeys)
                        )
                    )
                ]
                
            case .ethereumTransferPolicyUpdate(let details as EvmSignable):
                let privateKeys = try deviceSigner.privateKeys()
                
                return [
                    .ethereumWithOffchain(
                        EthereumSignatureWithOffchain(
                            signature: try privateKeys.signature(for: try details.signableData(), chain: .ethereum),
                            offchainSignature: try getApprovalRequestDetailsSignature(using: deviceSigner, privateKeys: privateKeys)
                        )
                    )
                ]
                
            case .polygonTransferPolicyUpdate(let details as EvmSignable):
                let privateKeys = try deviceSigner.privateKeys()
                
                return [
                    .polygonWithOffchain(
                        PolygonSignatureWithOffchain(
                            signature: try privateKeys.signature(for: try details.signableData(), chain: .polygon),
                            offchainSignature: try getApprovalRequestDetailsSignature(using: deviceSigner, privateKeys: privateKeys)
                        )
                    )
                ]
                
            case .bitcoinWithdrawalRequest(let request as BitcoinSignable):
                let dataArrayToSign = try request.signableDataList()
                let derivationPath = DerivationNode.notHardened(request.signingData.childKeyIndex)
                let privateKeys = try deviceSigner.privateKeys()
                
                return [
                    .bitcoinWithOffchain(
                        BitcoinSignaturesWithOffchain(
                            signatures: try dataArrayToSign.map { data in
                                try privateKeys.signature(for: data, chain: .bitcoin, derivationPath: derivationPath)
                            },
                            offchainSignature: try getApprovalRequestDetailsSignature(using: deviceSigner, privateKeys: privateKeys)
                        )
                    )
                ]
            case .ethereumDAppTransactionRequest(_):
                return []
            }
        case .Deny:
            switch request.details {
            case .loginApproval(let request):
                return try getLoginSignatureInfos(using: deviceSigner, request: request)
            case .passwordReset:
                return try getPasswordResetSignatureInfos(using: deviceSigner)
            default:
                return [try .offchain(getApprovalRequestDetailsSignature(using: deviceSigner, privateKeys: try deviceSigner.privateKeys()))]
            }
        }
    }
    
    private func getLoginSignatureInfos(using deviceSigner: DeviceSigner, request: LoginApproval) throws -> [SignatureInfo] {
        let dataToSign = "{\"token\":\"\(request.jwtToken)\",\"disposition\":\"\(disposition)\"}".data(using: .utf8)!
        return [
            .offchain(
                OffChainSignature(
                    signature: try deviceSigner.deviceSignature(for: dataToSign).base64EncodedString(),
                    signedData: dataToSign.base64EncodedString()
                )
            )
        ]
    }
    
    private func getPasswordResetSignatureInfos(using deviceSigner: DeviceSigner) throws -> [SignatureInfo] {
        let dataToSign = "{\"guid\":\"\(request.id)\",\"disposition\":\"\(disposition)\"}".data(using: .utf8)!
        return [
            .offchain(
                OffChainSignature(
                    signature: try deviceSigner.deviceSignature(for: dataToSign).base64EncodedString(),
                    signedData: dataToSign.base64EncodedString()
                )
            )
        ]
    }
    
    private func getApprovalRequestDetailsSignature(using deviceSigner: DeviceSigner, privateKeys: PrivateKeys) throws -> OffChainSignature {
        let jsonData = try JSONEncoder().encode(ApprovalRequestDetailsWithDisposition(
            approvalRequestDetails: request.details,
            disposition: disposition
        ))
        return OffChainSignature(
            signature: try privateKeys.signature(for: Data(SHA256.hash(data: jsonData)), chain: Chain.offchain),
            signedData: jsonData.base64EncodedString()
        )
    }
}

struct ApprovalRequestDetailsWithDisposition: Codable, Equatable  {
    let approvalRequestDetails: ApprovalRequestType
    let disposition: ApprovalDisposition
}

extension CensoApi.ApprovalDispositionPayload {
    init(dispositionRequest: ApprovalDispositionRequest, deviceSigner: DeviceSigner, apiProvider: MoyaProvider<CensoApi.Target>) async throws {
        self.approvalDisposition = dispositionRequest.disposition
        self.requestID = dispositionRequest.request.id
        self.signatures = try await dispositionRequest.signatureInfos(using: deviceSigner, apiProvider: apiProvider)
    }
}
