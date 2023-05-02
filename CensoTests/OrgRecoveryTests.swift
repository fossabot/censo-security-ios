//
//  OrgRecoveryTests.swift
//  CensoTests
//
//  Created by Brendan Flood on 5/1/23.
//

import XCTest
@testable import Censo
import CryptoKit
import BIP39

class OrgRecoveryTests: XCTestCase {
    
    let singleChangeRequest = "{\"deviceKey\":\"Rsoiwa7Te1UKqhb4rkCvad94LF2DWP73dAhCEhcGtD7KxGp7Ldyu7uG1be8W9jGRugkSX11VhLwNFUkd3sxWbw5w\",\"chainKeys\":[{\"key\":\"xpub6F7vQRQK5uzkU9VmcuMyg2s3rb1eBRq8LBQFbfsLgP1UB6pw5MbYnhxsGAfXgLXzWkxEZ2iize523UN5t7ptsJHc5X6oZCDjCuyQYQRczK2\",\"chain\":\"bitcoin\"},{\"key\":\"QbXeE69QrL4AP6BhDvWq1y9WXdd2SsW2JCbFViS7ofMaYbuSRrKhjcaQZPCU6cJdDPb8HLeZbq3CML6HVaZ4CF8U\",\"chain\":\"ethereum\"},{\"key\":\"SJHmXxa1NDADNZV7hPayQ8DiBjaXmTacJ72eQVD1pPiEWRUtPDYghu3M3TChKDqByhrEKkKubUe1cfPBzgWYsqvv\",\"chain\":\"offchain\"}],\"recoveryTxs\":[{\"chain\":\"ethereum\",\"recoveryContractAddress\":\"0x7ab922404511f866efcf2dbfeb8e31d098ac52be\",\"orgVaultSafeAddress\":\"0x98342c7ef2a33226a06c59c5238b2e1db07ec20e\",\"oldOwnerAddress\":\"0xa0ecfee0dd249e76aaab0d91ac6e6b39c547e89d\",\"newOwnerAddress\":\"0xe72687c0fd1dfdb93501fe7559e9ad6c4f638424\",\"txs\":[{\"type\":\"OrgVaultSwapOwner\",\"prev\":\"0x0000000000000000000000000000000000000001\"}]},{\"chain\":\"polygon\",\"recoveryContractAddress\":\"0x7ab922404511f866efcf2dbfeb8e31d098ac52be\",\"orgVaultSafeAddress\":\"0x98342c7ef2a33226a06c59c5238b2e1db07ec20e\",\"oldOwnerAddress\":\"0xa0ecfee0dd249e76aaab0d91ac6e6b39c547e89d\",\"newOwnerAddress\":\"0xe72687c0fd1dfdb93501fe7559e9ad6c4f638424\",\"txs\":[{\"type\":\"OrgVaultSwapOwner\",\"prev\":\"0x0000000000000000000000000000000000000001\"}]}],\"signingData\":[{\"type\":\"ethereum\",\"transaction\":{\"safeNonce\":1,\"chainId\":31337,\"vaultAddress\":null,\"orgVaultAddress\":null,\"contractAddresses\":[]}},{\"type\":\"polygon\",\"transaction\":{\"safeNonce\":1,\"chainId\":31337,\"vaultAddress\":null,\"orgVaultAddress\":null,\"contractAddresses\":[]}}]}\n"
    
    let multipleChangesRequest = "{\"deviceKey\":\"S6Mw6aRhrmBYJ4RgExdspTbHAbSMBWpgRZ3zDrrJ1ZVBvk1fsAy8t8Ug4kJ4ZopTajzMzXmvkF2oDEEkC4j38WJK\",\"chainKeys\":[{\"key\":\"xpub6F2ev2cCX8LkbLfnRPtriabFHYSBJCwSoUSTmTTN5Dsoc5qZXL3kB59uzr45aRjfqczKXFZQRpJvqfa2fCyohExy5m8SVRhGMgtJyJyeqSU\",\"chain\":\"bitcoin\"},{\"key\":\"QcfJhL7k4725ygLnfQECfDG6RepH4PCGgHTif22Es1TMmig3TVgbjQNYGepVba5ENnaQnAwkdhYiQ8grDHXfe5Ue\",\"chain\":\"ethereum\"},{\"key\":\"N8ATWFKzYcayUWxbkkqBKK4Gzfhy6i3d8L2LZZ181Xpr1Kmha9TGeEExndAakes2tbot6Bvioefat7y8hA4NnY4D\",\"chain\":\"offchain\"}],\"recoveryTxs\":[{\"chain\":\"ethereum\",\"recoveryContractAddress\":\"0x7ab922404511f866efcf2dbfeb8e31d098ac52be\",\"orgVaultSafeAddress\":\"0x98342c7ef2a33226a06c59c5238b2e1db07ec20e\",\"oldOwnerAddress\":\"0x856b96d540c16c851b76405920742143fe33016b\",\"newOwnerAddress\":\"0xb98ae9ac60883f68064bd40aa74982ba9db1ec14\",\"txs\":[{\"type\":\"OrgVaultSwapOwner\",\"prev\":\"0x0000000000000000000000000000000000000001\"},{\"type\":\"VaultSwapOwner\",\"prev\":\"0xcc64cd16d077ff897101f5fc38138a2abc58f0e1\",\"vaultSafeAddress\":\"0x82a0a0ef63130b67d40092934ba39ae4e064b475\"},{\"type\":\"WalletSwapOwner\",\"prev\":\"0xcc64cd16d077ff897101f5fc38138a2abc58f0e1\",\"vaultSafeAddress\":\"0x82a0a0ef63130b67d40092934ba39ae4e064b475\",\"walletSafeAddress\":\"0xcb1d6517bb2d4dd8df60b790d0c23417670ada1e\"}]},{\"chain\":\"polygon\",\"recoveryContractAddress\":\"0x7ab922404511f866efcf2dbfeb8e31d098ac52be\",\"orgVaultSafeAddress\":\"0x98342c7ef2a33226a06c59c5238b2e1db07ec20e\",\"oldOwnerAddress\":\"0x856b96d540c16c851b76405920742143fe33016b\",\"newOwnerAddress\":\"0xb98ae9ac60883f68064bd40aa74982ba9db1ec14\",\"txs\":[{\"type\":\"OrgVaultSwapOwner\",\"prev\":\"0x0000000000000000000000000000000000000001\"},{\"type\":\"VaultSwapOwner\",\"prev\":\"0xcc64cd16d077ff897101f5fc38138a2abc58f0e1\",\"vaultSafeAddress\":\"0x82a0a0ef63130b67d40092934ba39ae4e064b475\"},{\"type\":\"WalletSwapOwner\",\"prev\":\"0xcc64cd16d077ff897101f5fc38138a2abc58f0e1\",\"vaultSafeAddress\":\"0x82a0a0ef63130b67d40092934ba39ae4e064b475\",\"walletSafeAddress\":\"0x0c7c08a72af16f8dcef70bfc4df01ac4153fbfdc\"}]}],\"signingData\":[{\"type\":\"ethereum\",\"transaction\":{\"safeNonce\":0,\"chainId\":31337,\"vaultAddress\":null,\"orgVaultAddress\":null,\"contractAddresses\":[]}},{\"type\":\"polygon\",\"transaction\":{\"safeNonce\":0,\"chainId\":31337,\"vaultAddress\":null,\"orgVaultAddress\":null,\"contractAddresses\":[]}}]}\n"

    
    func testSingleChangeRecoveryTx() throws {

        let orgRecoveryRequest: OrgAdminRecoveryRequest = Mock.decodeJsonType(data: singleChangeRequest.data(using: .utf8)!)
        let recoveryAppSigningRequest = try orgRecoveryRequest.toRecoveryAppSigningRequest()
        XCTAssertEqual(
            "cb8a7e65872c8594abfdbe1ca5e0ab5df5f98258b6b9f35a44e535426f33a0bb",
            Data(base64Encoded: recoveryAppSigningRequest.items.first(where: {$0.chain == Chain.ethereum})!.dataToSign)!.toHexString()
        )
        XCTAssertEqual(
            "cb8a7e65872c8594abfdbe1ca5e0ab5df5f98258b6b9f35a44e535426f33a0bb",
            Data(base64Encoded: recoveryAppSigningRequest.items.first(where: {$0.chain == Chain.polygon})!.dataToSign)!.toHexString()
        )
        XCTAssertEqual(
            Data(SHA256.hash(data: try JSONEncoder().encode(orgRecoveryRequest))).toHexString(),
            Data(base64Encoded: recoveryAppSigningRequest.items.first(where: {$0.chain == Chain.offchain})!.dataToSign)!.toHexString()
        )
    }
    
    func testMultipleChangesRecoveryTx() throws {

        let orgRecoveryRequest: OrgAdminRecoveryRequest = Mock.decodeJsonType(data: multipleChangesRequest.data(using: .utf8)!)
        let recoveryAppSigningRequest = try orgRecoveryRequest.toRecoveryAppSigningRequest()
        XCTAssertEqual(
            "334ca7d1168e12b626a827def790a75b79fb08bfa311ab571f955db6c8a1fc72",
            Data(base64Encoded: recoveryAppSigningRequest.items.first(where: {$0.chain == Chain.ethereum})!.dataToSign)!.toHexString()
        )
        XCTAssertEqual(
            "40fae325732650391653f60720ad2a11363ca9e6a95d72878c503784e0ace340",
            Data(base64Encoded: recoveryAppSigningRequest.items.first(where: {$0.chain == Chain.polygon})!.dataToSign)!.toHexString()
        )
        XCTAssertEqual(
            Data(SHA256.hash(data: try JSONEncoder().encode(orgRecoveryRequest))).toHexString(),
            Data(base64Encoded: recoveryAppSigningRequest.items.first(where: {$0.chain == Chain.offchain})!.dataToSign)!.toHexString()
        )
        
    }
    
    func testRecoveryAppFlow() throws {
        let seedPhrase = "whip spatial call cream base decorate tobacco life below lobster arena movie cat fix buffalo vibrant victory jungle category picnic way raise hazard exact"
        let recoveryAppKey = try Secp256k1HierarchicalKey.fromRootSeed(
            rootSeed: try Mnemonic(phrase: seedPhrase.components(separatedBy: " ")).seed,
            derivationPath: Secp256k1HierarchicalKey.ethereumDerivationPath
        )
        
        // take recovery request from brooklyn and convert to request to recovery app
        // (the stringified recoveryAppSigningRequest would be encoded in QR code)
        let myOrgRecoveryRequest: OrgAdminRecoveryRequest = Mock.decodeJsonType(data: multipleChangesRequest.data(using: .utf8)!)
        let recoveryAppSigningRequest = try myOrgRecoveryRequest.toRecoveryAppSigningRequest()
        
        // simulate the recovery app signing it
        let recoveryAppSigningResponse = RecoveryAppSigningResponse(
            recoveryAddress: recoveryAppKey.getEthereumAddress(),
            items: try recoveryAppSigningRequest.items.map({
                RecoverySignatureItem(
                    chain: $0.chain,
                    signature: try recoveryAppKey.signData(message: Data(base64Encoded: $0.dataToSign)!).base64EncodedString()
                )
            })
        )
        
        // convert the recovery app signing response, to the signatures request to send to brooklyn
        // and verify signatures
        let orgAdminRecoverySignaturesRequest = try OrgAdminRecoverySignaturesRequest.fromRecoveryAppSigningResponse(
            myOrgAdminRecoveryRequest: myOrgRecoveryRequest,
            recoveryAppSigningResponse: recoveryAppSigningResponse
        )
        
        XCTAssertEqual(orgAdminRecoverySignaturesRequest.recoveryAddress, "0xD96fA11F6f86b648011dcD8cf047458932b043Df")
        
        XCTAssertTrue(
            try recoveryAppKey.verifySignature(
                Data(base64Encoded: getSignature(orgAdminRecoverySignaturesRequest.signatures.filter({
                    switch $0 {
                    case .ethereum:
                        return true
                    default:
                        return false
                    }
                    
                })[0]))!,
                message: Data(base64Encoded: recoveryAppSigningRequest.items.first(where: { $0.chain == Chain.ethereum })!.dataToSign)!
            )
        )
        
        XCTAssertTrue(
            try recoveryAppKey.verifySignature(
                Data(base64Encoded: getSignature(orgAdminRecoverySignaturesRequest.signatures.filter({
                    switch $0 {
                    case .polygon:
                        return true
                    default:
                        return false
                    }
                    
                })[0]))!,
                message: Data(base64Encoded: recoveryAppSigningRequest.items.first(where: { $0.chain == Chain.polygon })!.dataToSign)!
            )
        )
        
        let offchainSignature = orgAdminRecoverySignaturesRequest.signatures.filter({
            switch $0 {
            case .offchain:
                return true
            default:
                return false
            }
            
        })[0]
        
        XCTAssertTrue(
            try recoveryAppKey.verifySignature(
                Data(base64Encoded: getSignature(offchainSignature))!,
                message: Data(base64Encoded: recoveryAppSigningRequest.items.first(where: { $0.chain == Chain.offchain })!.dataToSign)!
            )
        )
        
        XCTAssertEqual(
            Data(SHA256.hash(data: Data(base64Encoded: getDataToSign(offchainSignature))!)).base64EncodedString(),
            recoveryAppSigningRequest.items.first(where: { $0.chain == Chain.offchain })?.dataToSign
        )

    }
    
    private func getSignature(_ recoverySignature: RecoverySignature) -> String {
        switch recoverySignature {
        case .ethereum(let signature):
            return signature
        case .polygon(let signature):
            return signature
        case .offchain(let signature, _):
            return signature
        }
    }
    
    private func getDataToSign(_ recoverySignature: RecoverySignature) -> String {
        switch recoverySignature {
        case .offchain(_, let dataToSign):
            return dataToSign
        default:
            return ""
        }
    }
}

