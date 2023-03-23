//
//  EthereumSigningTests.swift
//  StrikeTests
//
//  Created by Benjamin Holzman on 11/23/22.
//

import XCTest
@testable import Censo

class EvmTransferTransactionBuilderTests: XCTestCase {
    private let destinationAddress = "0x6e01af3913026660fcebb93f054345eccd972260"
    private let walletAddress = "0x6e01af3913026660fcebb93f054345eccd972261"
    private let ercContractAddress = "0x6e01af3913026660fcebb93f054345eccd972262"
    private let evmTransaction = EvmTransaction(
        safeNonce: 10,
        chainId: 31337
    )

    func testDomainHash() throws {
        XCTAssertEqual(
            "0x3914f2cd675546d440c95ea0be3263f035e2f742ff979aa5c735e5aa0a3c9c15".data(using: .hexadecimal),
            EvmTransactionUtil.domainHash(chainId: 31337, verifyingContract: "0x7ff2590186b29e2dd24f2ed1bf3af1e7594903f1")
        )
    }

    func testWithdrawalMessageHash() throws {
        XCTAssertEqual(
            "c280488ce25c155982200b6a2e814baf2bf0b96d161d011a712610988cabdc68",
            EvmTransferTransactionBuilder.withdrawalMessageHash(
                chainId: 31337,
                walletAddress: "0x587827b6138d916f0914812ed9c48178cd978e53",
                destinationAddress: "0x587827b6138d916f0914812ed9c48178cd978e52",
                amount: Bignum(number: "1000000000000000000", withBase: 10),
                data: Data(count: 0),
                nonce: UInt64(0)
            ).toHexString()
        )
    }

    func testEthWithdrawal() throws {
        XCTAssertEqual(
            "08e6494cf271ad5b84fe65ea12977e97b4a1c7eedaea6ff1b605c49969d3f2d8",
            try EvmTransferTransactionBuilder.withdrawalSafeHash(
                evmTokenInfo: nil,
                amount: Amount(value: "2.0", nativeValue: "2.000000000000000000", usdEquivalent: "0"),
                walletAddress: walletAddress,
                destinationAddress: destinationAddress,
                evmTransaction: evmTransaction
            ).toHexString()
        )
    }

    func testErc20Withdrawal() throws {
        XCTAssertEqual(
            "493b5d08bbf55da864e296e3bcf9fc9392955b483efb63710ceb516639c50655",
            try EvmTransferTransactionBuilder.withdrawalSafeHash(
                evmTokenInfo: EvmTokenInfo.erc20(contractAddress: ercContractAddress),
                amount: Amount(value: "2.0", nativeValue: "2.00000000", usdEquivalent: "0"),
                walletAddress: walletAddress,
                destinationAddress: destinationAddress,
                evmTransaction: evmTransaction
            ).toHexString()
        )
    }

    func testErc721Withdrawal() throws {
        XCTAssertEqual(
            "3ae878370ea34c6b72e53ac7efdba9d2ab25b69f16111846efcedf4611e93f43",
            try EvmTransferTransactionBuilder.withdrawalSafeHash(
                evmTokenInfo: EvmTokenInfo.erc721(contractAddress: ercContractAddress, tokenId: "11223344556677889900"),
                amount: Amount(value: "1", nativeValue: "1", usdEquivalent: "0"),
                walletAddress: walletAddress,
                destinationAddress: destinationAddress,
                evmTransaction: evmTransaction
            ).toHexString()
        )
    }

    func testErc1155Withdrawal() throws {
        XCTAssertEqual(
            "03bcc85e250d18e4cc72e5e0bd1bdf8f11b0ac0dafaa0357d7db53687f80f924",
            try EvmTransferTransactionBuilder.withdrawalSafeHash(
                evmTokenInfo: EvmTokenInfo.erc1155(contractAddress: ercContractAddress, tokenId: "11223344556677889900"),
                amount: Amount(value: "2", nativeValue: "2", usdEquivalent: "0"),
                walletAddress: walletAddress,
                destinationAddress: destinationAddress,
                evmTransaction: evmTransaction
            ).toHexString()
        )
    }
}

