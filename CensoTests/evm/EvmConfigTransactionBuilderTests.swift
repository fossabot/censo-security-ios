//
//  EvmConfigTransactionBuilderTest.swift
//  CensoTests
//
//  Created by Brendan Flood on 2/1/23.
//

import XCTest
@testable import Censo

class EvmConfigTransactionBuilderTests: XCTestCase {
    
    private static let addresses = [
        "0x6e01af3913026660fcebb93f054345eCCd972252",
        "0x6e01af3913026660fcebb93f054345eCCd972253",
        "0x6e01af3913026660fcebb93f054345eCCd972254",
        "0x6e01af3913026660fcebb93f054345eCCd972255"
    ]
    private static let destinations = [
        EvmDestination(name: "", address: "0x6e01af3913026660fcebb93f054345eCCd972252"),
        EvmDestination(name: "", address: "0x6e01af3913026660fcebb93f054345eCCd972253"),
        EvmDestination(name: "", address: "0x6e01af3913026660fcebb93f054345eCCd972254"),
        EvmDestination(name: "", address: "0x6e01af3913026660fcebb93f054345eCCd972255")
    ]
    
    private static var nameHashes = destinations.map { $0.nameHash.toHexString() }

    private static var cleanAddresses = addresses.map { $0.data(using: .hexadecimal)!.toHexString() }
    
    private let vaultAddress = "0x6e01af3913026660fcebb93f054345eccd972260"
    private let walletAddress = "0x6e01af3913026660fcebb93f054345eccd972261"
    private let guardAddress = "0x6e01af3913026660fcebb93f054345eccd972262"
    private let evmTransaction = EvmTransaction(
        safeNonce: 10,
        chainId: 31337,
        vaultAddress: "0x6e01af3913026660fcebb93f054345eccd972260",
        contractAddresses: []
    )

    func testChangeGuard() throws {
        XCTAssertEqual(
            "468721a70000000000000000000000006e01af3913026660fcebb93f054345eccd9722610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024e19a9dd90000000000000000000000006e01af3913026660fcebb93f054345eccd97226200000000000000000000000000000000000000000000000000000000",
            EvmConfigTransactionBuilder.getSetGuardExecutionFromModuleData(
                walletAddress: walletAddress,
                guardAddress: guardAddress
            ).toHexString().lowercased()
        )
        XCTAssertEqual(
            "f6eb42d06a737180fca879e87d6963d6030c0d40d0fdd091a4dbc4a97def0775",
            try EvmConfigTransactionBuilder.getSetGuardExecutionFromModuleDataSafeHash(
                walletAddress: walletAddress,
                guardAddress: guardAddress,
                evmTransaction: evmTransaction
            ).toHexString().lowercased()
        )
    }
    
    func testAddressListChanges() throws {
        
        let addressesToAdd = [
            (EvmConfigTransactionBuilderTests.nameHashes[2] + EvmConfigTransactionBuilderTests.cleanAddresses[2]).data(using: .hexadecimal)!,
            (EvmConfigTransactionBuilderTests.nameHashes[3] + EvmConfigTransactionBuilderTests.cleanAddresses[3]).data(using: .hexadecimal)!,
        ]
        
        XCTAssertEqual(
            "468721a70000000000000000000000006e01af3913026660fcebb93f054345eccd97226100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000847aaea4f600000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000002e3b0c44298fc1c149afbf4c86e01af3913026660fcebb93f054345eccd972254e3b0c44298fc1c149afbf4c86e01af3913026660fcebb93f054345eccd97225500000000000000000000000000000000000000000000000000000000",
            EvmConfigTransactionBuilder.getUpdateWhitelistExecutionFromModuleData(
                walletAddress: walletAddress,
                addsOrRemoves: addressesToAdd
            ).toHexString().lowercased()
        )
        XCTAssertEqual(
            "7b93aed2b9c9b9028885fcaa0425748007cebacde75ee6df57f60314d683bf97",
            try EvmConfigTransactionBuilder.getUpdateWhitelistExecutionFromModuleDataSafeHash(
                walletAddress: walletAddress,
                addsOrRemoves: addressesToAdd,
                evmTransaction: evmTransaction
            ).toHexString().lowercased()
        )
    }
    
    func testVaultPolicyChangeAddOwner() throws {
        let txs =  [SafeTx.addOwnerWithThreshold(EvmConfigTransactionBuilderTests.addresses[0], 2)]
        XCTAssertEqual(
            PolicyUpdateData.single("0d582f130000000000000000000000006e01af3913026660fcebb93f054345eccd9722520000000000000000000000000000000000000000000000000000000000000002".data(using: .hexadecimal)!),
            EvmConfigTransactionBuilder.getPolicyUpdateData(
                safeAddress: vaultAddress, txs: txs
            )
        )
        XCTAssertEqual(
            "24befecdd62a870d007522cdc00e757452dd07a23cdb987848ad85e602af073d",
            try EvmConfigTransactionBuilder.getVaultPolicyUpdateDataSafeHash(txs: txs, evmTransaction: evmTransaction).toHexString()
        )
    }
    
    func testVaultPolicyChangeRemoveOwner() throws {
        let txs =  [SafeTx.removeOwner(EvmConfigTransactionBuilderTests.addresses[0], EvmConfigTransactionBuilderTests.addresses[1], 2)]
        XCTAssertEqual(
            PolicyUpdateData.single("f8dc5dd90000000000000000000000006e01af3913026660fcebb93f054345eccd9722520000000000000000000000006e01af3913026660fcebb93f054345eccd9722530000000000000000000000000000000000000000000000000000000000000002".data(using: .hexadecimal)!),
            EvmConfigTransactionBuilder.getPolicyUpdateData(
                safeAddress: vaultAddress, txs: txs
            )
        )
        XCTAssertEqual(
            "046eb5adcfa5c851629e450f368acba9806c87e4d6408813eba7afc81a390368",
            try EvmConfigTransactionBuilder.getVaultPolicyUpdateDataSafeHash(txs: txs, evmTransaction: evmTransaction).toHexString()
        )
    }
    
    func testVaultPolicyChangeSwapOwner() throws {
        let txs =  [SafeTx.swapOwner(
            EvmConfigTransactionBuilderTests.addresses[0],
            EvmConfigTransactionBuilderTests.addresses[1],
            EvmConfigTransactionBuilderTests.addresses[2]
        )]
        XCTAssertEqual(
            PolicyUpdateData.single("e318b52b0000000000000000000000006e01af3913026660fcebb93f054345eccd9722520000000000000000000000006e01af3913026660fcebb93f054345eccd9722530000000000000000000000006e01af3913026660fcebb93f054345eccd972254".data(using: .hexadecimal)!),
            EvmConfigTransactionBuilder.getPolicyUpdateData(
                safeAddress: vaultAddress, txs: txs
            )
        )
        XCTAssertEqual(
            "209645fd1c01854cc1de79fa303547c08f24db5201ae0854d1b2e6d9c16004b3",
            try EvmConfigTransactionBuilder.getVaultPolicyUpdateDataSafeHash(txs: txs, evmTransaction: evmTransaction).toHexString()
        )
    }

    func testVaultPolicyChangeChangeThreshold() throws {
        let txs =  [SafeTx.changeThreshold(5)]
        XCTAssertEqual(
            PolicyUpdateData.single("694e80c30000000000000000000000000000000000000000000000000000000000000005".data(using: .hexadecimal)!),
            EvmConfigTransactionBuilder.getPolicyUpdateData(
                safeAddress: vaultAddress, txs: txs
            )
        )
        XCTAssertEqual(
            "0c49daaae601de5348ab37760f0de0affc0e4870069ad66e387d1aaead179ca4",
            try EvmConfigTransactionBuilder.getVaultPolicyUpdateDataSafeHash(txs: txs, evmTransaction: evmTransaction).toHexString()
        )
    }
    
    func testVaultPolicyChangeMultiSend() throws {
        let txs =  [
            SafeTx.addOwnerWithThreshold(EvmConfigTransactionBuilderTests.addresses[0], 2),
            SafeTx.removeOwner(EvmConfigTransactionBuilderTests.addresses[0], EvmConfigTransactionBuilderTests.addresses[1], 2)
        ]
        XCTAssertEqual(
            PolicyUpdateData.multisend("8d80ff0a00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000152006e01af3913026660fcebb93f054345eccd972260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000440d582f130000000000000000000000006e01af3913026660fcebb93f054345eccd9722520000000000000000000000000000000000000000000000000000000000000002006e01af3913026660fcebb93f054345eccd97226000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000064f8dc5dd90000000000000000000000006e01af3913026660fcebb93f054345eccd9722520000000000000000000000006e01af3913026660fcebb93f054345eccd97225300000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000".data(using: .hexadecimal)!),
            EvmConfigTransactionBuilder.getPolicyUpdateData(
                safeAddress: vaultAddress, txs: txs
            )
        )
        XCTAssertEqual(
            "04ef6db23f440eecbe4d5e47947677b160758b730821bf4adb98acecd17b3d1d",
            try EvmConfigTransactionBuilder.getVaultPolicyUpdateDataSafeHash(txs: txs, evmTransaction: evmTransaction).toHexString()
        )
    }

    func testWalletPolicyChangeAddOwner() throws {
        let txs =  [SafeTx.addOwnerWithThreshold(EvmConfigTransactionBuilderTests.addresses[0], 2)]
        XCTAssertEqual(
            "468721a70000000000000000000000006e01af3913026660fcebb93f054345eccd97226100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000440d582f130000000000000000000000006e01af3913026660fcebb93f054345eccd972252000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000",
            EvmConfigTransactionBuilder.getPolicyUpdateExecutionFromModuleData(
                safeAddress: walletAddress,
                txs: txs
            ).toHexString()
        )
        XCTAssertEqual(
            "b5818ccdbbd8ea23d2af5d345b4c968d6565ed216349b64818fc977f8d0f66e9",
            try EvmConfigTransactionBuilder.getPolicyUpdateExecutionFromModuleDataSafeHash(
                verifyingContract: evmTransaction.vaultAddress,
                safeAddress: walletAddress,
                txs: txs,
                evmTransaction: evmTransaction
            ).toHexString()
        )
    }
    
    func testWalletPolicyChangeRemoveOwner() throws {
        let txs =  [SafeTx.removeOwner(EvmConfigTransactionBuilderTests.addresses[0], EvmConfigTransactionBuilderTests.addresses[1], 2)]
        XCTAssertEqual(
            "468721a70000000000000000000000006e01af3913026660fcebb93f054345eccd9722610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000064f8dc5dd90000000000000000000000006e01af3913026660fcebb93f054345eccd9722520000000000000000000000006e01af3913026660fcebb93f054345eccd972253000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000",
            EvmConfigTransactionBuilder.getPolicyUpdateExecutionFromModuleData(
                safeAddress: walletAddress,
                txs: txs
            ).toHexString()
        )
        XCTAssertEqual(
            "c6e2dd950ce4f5da473e2b303136d00097b95287a9f9c26e7c0f89a5c2e0d017",
            try EvmConfigTransactionBuilder.getPolicyUpdateExecutionFromModuleDataSafeHash(
                verifyingContract: evmTransaction.vaultAddress,
                safeAddress: walletAddress,
                txs: txs,
                evmTransaction: evmTransaction
            ).toHexString()
        )
    }
    
    func testWalletPolicyChangeSwapOwner() throws {
        let txs =  [SafeTx.swapOwner(
            EvmConfigTransactionBuilderTests.addresses[0],
            EvmConfigTransactionBuilderTests.addresses[1],
            EvmConfigTransactionBuilderTests.addresses[2]
        )]
        XCTAssertEqual(
            "468721a70000000000000000000000006e01af3913026660fcebb93f054345eccd9722610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000064e318b52b0000000000000000000000006e01af3913026660fcebb93f054345eccd9722520000000000000000000000006e01af3913026660fcebb93f054345eccd9722530000000000000000000000006e01af3913026660fcebb93f054345eccd97225400000000000000000000000000000000000000000000000000000000",
            EvmConfigTransactionBuilder.getPolicyUpdateExecutionFromModuleData(
                safeAddress: walletAddress,
                txs: txs
            ).toHexString()
        )
        XCTAssertEqual(
            "b2520eb52a950da57d80cb2ddc0f47bb7a5a545c2f6ad30669063823407f1318",
            try EvmConfigTransactionBuilder.getPolicyUpdateExecutionFromModuleDataSafeHash(
                verifyingContract: evmTransaction.vaultAddress,
                safeAddress: walletAddress,
                txs: txs,
                evmTransaction: evmTransaction
            ).toHexString()
        )
    }

    func testWalletPolicyChangeChangeThreshold() throws {
        let txs =  [SafeTx.changeThreshold(5)]
        XCTAssertEqual(
            "468721a70000000000000000000000006e01af3913026660fcebb93f054345eccd9722610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024694e80c3000000000000000000000000000000000000000000000000000000000000000500000000000000000000000000000000000000000000000000000000",
            EvmConfigTransactionBuilder.getPolicyUpdateExecutionFromModuleData(
                safeAddress: walletAddress,
                txs: txs
            ).toHexString()
        )
        XCTAssertEqual(
            "a9ff0670e3923384a0ec571acaa7cbdfa664dff96463a9f33b88f41ce3055999",
            try EvmConfigTransactionBuilder.getPolicyUpdateExecutionFromModuleDataSafeHash(
                verifyingContract: evmTransaction.vaultAddress,
                safeAddress: walletAddress,
                txs: txs,
                evmTransaction: evmTransaction
            ).toHexString()
        )
    }
    
    func testWallettPolicyChangeMultiSend() throws {
        let txs =  [
            SafeTx.addOwnerWithThreshold(EvmConfigTransactionBuilderTests.addresses[0], 2),
            SafeTx.removeOwner(EvmConfigTransactionBuilderTests.addresses[0], EvmConfigTransactionBuilderTests.addresses[1], 2)
        ]
        XCTAssertEqual(
            "468721a700000000000000000000000040a2accbd92bca938b02010e17a5b8929b49130d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000001a48d80ff0a00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000152006e01af3913026660fcebb93f054345eccd972261000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000440d582f130000000000000000000000006e01af3913026660fcebb93f054345eccd9722520000000000000000000000000000000000000000000000000000000000000002006e01af3913026660fcebb93f054345eccd97226100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000064f8dc5dd90000000000000000000000006e01af3913026660fcebb93f054345eccd9722520000000000000000000000006e01af3913026660fcebb93f054345eccd9722530000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
            EvmConfigTransactionBuilder.getPolicyUpdateExecutionFromModuleData(
                safeAddress: walletAddress,
                txs: txs
            ).toHexString()
        )
        XCTAssertEqual(
            "ef3d0fbdefa12a1460200dbf73ea20fc64150f13029153759e593319f993799e",
            try EvmConfigTransactionBuilder.getPolicyUpdateExecutionFromModuleDataSafeHash(
                verifyingContract: evmTransaction.vaultAddress,
                safeAddress: walletAddress,
                txs: txs,
                evmTransaction: evmTransaction
            ).toHexString()
        )
    }
    
    func testEvmAddressFromBase58PublicKey() throws {
        let base58Key = "N1LxhcQXi7qc72GGFMcEuiDfe7FUmL3uZCM1g65JX5FmGpssFBCTPQxbkoDaqkFixULu7vvL7C1AENMVaoXduHej"
        XCTAssertEqual(
            "0xf13ca8941aaf77c11ef8414c573023ce273ff5be",
            EvmTransactionUtil.getEthereumAddressFromBase58(base58Key: base58Key)
        )
    }


    
    
}
