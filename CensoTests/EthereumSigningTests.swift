//
//  EthereumSigningTests.swift
//  StrikeTests
//
//  Created by Benjamin Holzman on 11/23/22.
//

import XCTest
@testable import Censo

class EthereumSigningTests: XCTestCase {

    func testDomainHash() throws {
        XCTAssertEqual(
            "0x3914f2cd675546d440c95ea0be3263f035e2f742ff979aa5c735e5aa0a3c9c15".data(using: .hexadecimal),
            domainHash(chainId: 31337, verifyingContract: "0x7ff2590186b29e2dd24f2ed1bf3af1e7594903f1")
        )
    }
    
    func testWithdrawalMessageHash() throws {
        XCTAssertEqual(
            "0xfaad6a88a4270c471b5d4cbeaf4659e869e8a7c86c18b766433ead579aaec25f".data(using: .hexadecimal),
            withdrawalMessageHash(
                destinationAddress: "0x587827b6138d916f0914812ed9c48178cd978e52",
                amount: Bignum(number: "1000000000000000000", withBase: 10),
                data: Data(count: 0),
                nonce: UInt64(0)
            )
        )
    }
}
