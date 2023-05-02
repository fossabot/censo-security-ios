//
//  ApprovalDispositionRequest+Signing.swift
//  Censo
//
//  Created by Ata Namvari on 2023-01-30.
//

import Foundation
import Moya
import CryptoKit

extension ApprovalDispositionRequest {
    func signatureInfos(using registeredDevice: RegisteredDevice, apiProvider: MoyaProvider<CensoApi.Target>) async throws -> [SignatureInfo] {
        switch disposition {
        case .Approve:
            switch request.details {
            case .loginApproval(let request):
                return try getLoginSignatureInfos(using: registeredDevice, request: request)
            case .passwordReset:
                return try getPasswordResetSignatureInfos(using: registeredDevice)
            case .ethereumWalletCreation,
                    .bitcoinWalletCreation,
                    .polygonWalletCreation,
                    .bitcoinWalletNameUpdate,
                    .vaultCreation,
                    .enableDevice,
                    .disableDevice,
                    .addressBookUpdate,
                    .orgNameUpdate,
                    .vaultUserRolesUpdate,
                    .suspendUser,
                    .restoreUser:
                return [try .offchain(getApprovalRequestDetailsSignature(using: registeredDevice, privateKeys: try registeredDevice.privateKeys()))]
                
            case .vaultPolicyUpdate(let signableRequest as MultichainSignable),
                    .vaultNameUpdate(let signableRequest as MultichainSignable),
                    .orgAdminPolicyUpdate(let signableRequest as MultichainSignable),
                    .enableRecoveryContract(let signableRequest as MultichainSignable):
                let privateKeys = try registeredDevice.privateKeys()
                var signatures: [SignatureInfo] = [
                    .offchain(try getApprovalRequestDetailsSignature(using: registeredDevice, privateKeys: privateKeys))
                ]
                
                for (chain, dataToSign) in try signableRequest.signableData() {
                    switch chain {
                    case Chain.ethereum:
                        signatures.append(
                            .ethereumWithOffchain(
                                EthereumSignatureWithOffchain(
                                    signature: try privateKeys.signature(for: dataToSign, chain: Chain.ethereum),
                                    offchainSignature: try getApprovalRequestDetailsSignature(using: registeredDevice, privateKeys: privateKeys)
                                )
                            )
                        )
                    case Chain.polygon:
                        signatures.append(
                            .polygonWithOffchain(
                                PolygonSignatureWithOffchain(
                                    signature: try privateKeys.signature(for: dataToSign, chain: Chain.ethereum),
                                    offchainSignature: try getApprovalRequestDetailsSignature(using: registeredDevice, privateKeys: privateKeys)
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
                let privateKeys = try registeredDevice.privateKeys()
                
                return [
                    .ethereumWithOffchain(
                        EthereumSignatureWithOffchain(
                            signature: try privateKeys.signature(for: try request.signableData(), chain: .ethereum),
                            offchainSignature: try getApprovalRequestDetailsSignature(using: registeredDevice, privateKeys: privateKeys)
                        )
                    )
                ]
                
            case .polygonWithdrawalRequest(let request as EvmSignable),
                    .polygonWalletNameUpdate(let request as EvmSignable),
                    .polygonWalletSettingsUpdate(let request as EvmSignable),
                    .polygonWalletWhitelistUpdate(let request as EvmSignable):
                let privateKeys = try registeredDevice.privateKeys()
                
                return [
                    .polygonWithOffchain(
                        PolygonSignatureWithOffchain(
                            signature: try privateKeys.signature(for: try request.signableData(), chain: .polygon),
                            offchainSignature: try getApprovalRequestDetailsSignature(using: registeredDevice, privateKeys: privateKeys)
                        )
                    )
                ]
                
            case .ethereumTransferPolicyUpdate(let details as EvmSignable):
                let privateKeys = try registeredDevice.privateKeys()
                
                return [
                    .ethereumWithOffchain(
                        EthereumSignatureWithOffchain(
                            signature: try privateKeys.signature(for: try details.signableData(), chain: .ethereum),
                            offchainSignature: try getApprovalRequestDetailsSignature(using: registeredDevice, privateKeys: privateKeys)
                        )
                    )
                ]
                
            case .polygonTransferPolicyUpdate(let details as EvmSignable):
                let privateKeys = try registeredDevice.privateKeys()
                
                return [
                    .polygonWithOffchain(
                        PolygonSignatureWithOffchain(
                            signature: try privateKeys.signature(for: try details.signableData(), chain: .polygon),
                            offchainSignature: try getApprovalRequestDetailsSignature(using: registeredDevice, privateKeys: privateKeys)
                        )
                    )
                ]
                
            case .bitcoinWithdrawalRequest(let request as BitcoinSignable):
                let dataArrayToSign = try request.signableDataList()
                let derivationPath = DerivationNode.notHardened(request.signingData.childKeyIndex)
                let privateKeys = try registeredDevice.privateKeys()
                
                return [
                    .bitcoinWithOffchain(
                        BitcoinSignaturesWithOffchain(
                            signatures: try dataArrayToSign.map { data in
                                try privateKeys.signature(for: data, chain: .bitcoin, derivationPath: derivationPath)
                            },
                            offchainSignature: try getApprovalRequestDetailsSignature(using: registeredDevice, privateKeys: privateKeys)
                        )
                    )
                ]
            case .ethereumDAppTransactionRequest(_):
                return []
            }
        case .Deny:
            switch request.details {
            case .loginApproval(let request):
                return try getLoginSignatureInfos(using: registeredDevice, request: request)
            case .passwordReset:
                return try getPasswordResetSignatureInfos(using: registeredDevice)
            default:
                return [try .offchain(getApprovalRequestDetailsSignature(using: registeredDevice, privateKeys: try registeredDevice.privateKeys()))]
            }
        }
    }
    
    private func getLoginSignatureInfos(using registeredDevice: RegisteredDevice, request: LoginApproval) throws -> [SignatureInfo] {
        let dataToSign = "{\"token\":\"\(request.jwtToken)\",\"disposition\":\"\(disposition)\"}".data(using: .utf8)!
        return [
            .offchain(
                OffChainSignature(
                    signature: try registeredDevice.deviceSignature(for: dataToSign).base64EncodedString(),
                    signedData: dataToSign.base64EncodedString()
                )
            )
        ]
    }
    
    private func getPasswordResetSignatureInfos(using registeredDevice: RegisteredDevice) throws -> [SignatureInfo] {
        let dataToSign = "{\"guid\":\"\(request.id)\",\"disposition\":\"\(disposition)\"}".data(using: .utf8)!
        return [
            .offchain(
                OffChainSignature(
                    signature: try registeredDevice.deviceSignature(for: dataToSign).base64EncodedString(),
                    signedData: dataToSign.base64EncodedString()
                )
            )
        ]
    }
    
    private func getApprovalRequestDetailsSignature(using registeredDevice: RegisteredDevice, privateKeys: PrivateKeys) throws -> OffChainSignature {
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
