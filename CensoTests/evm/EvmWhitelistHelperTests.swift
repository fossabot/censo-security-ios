//
//  EvmWhitelistHelperTest.swift
//  CensoTests
//
//  Created by Brendan Flood on 2/1/23.
//

import XCTest
@testable import Censo

class EvmWhitelistHelperTests: XCTestCase {
    
    private static let addresses = [
        "0x6e01af3913026660fcebb93f054345eCCd972252",
        "0x6e01af3913026660fcebb93f054345eCCd972253",
        "0x6e01af3913026660fcebb93f054345eCCd972254",
        "0x6e01af3913026660fcebb93f054345eCCd972255"
    ]
    private static let destinations = [
        EvmDestination(name: "aa", address: "0x6e01af3913026660fcebb93f054345eccd972252"),
        EvmDestination(name: "bb", address: "0x6e01af3913026660fcebb93f054345eccd972253"),
        EvmDestination(name: "cc", address: "0x6e01af3913026660fcebb93f054345eccd972254"),
        EvmDestination(name: "dd", address: "0x6e01af3913026660fcebb93f054345eccd972255")
    ]
    
    private static var nameHashes = destinations.map { $0.nameHash.toHexString() }

    private static var cleanAddresses = addresses.map { $0.data(using: .hexadecimal)!.toHexString() }

    func testNameHash() throws {
        let destination = EvmDestination(name: "hello world", address: "0x6e01af3913026660fcebb93f054345eccd972252")
        XCTAssertEqual(destination.nameHash.toHexString(), "b94d27b9934d3e08a52e52d7")
        XCTAssertEqual(destination.nameHashAndAddress.toHexString(), "b94d27b9934d3e08a52e52d76e01af3913026660fcebb93f054345eccd972252")
    }
    
    func testSingleAddressAdded() throws {
        XCTAssertEqual(
            try EvmWhitelistHelper(addresses: EvmWhitelistHelperTests.addresses.prefix(3).map { $0 }, targetDests: EvmWhitelistHelperTests.destinations).allChanges(),
            [
                EvmWhitelistHelperTests.nameHashes[3] + EvmWhitelistHelperTests.cleanAddresses[3]
            ]
        )
    }
    
    func testMultipleAddressesAdded() throws {
        XCTAssertEqual(
            try EvmWhitelistHelper(addresses: EvmWhitelistHelperTests.addresses.prefix(2).map { $0 }, targetDests: EvmWhitelistHelperTests.destinations).allChanges(),
            [
                EvmWhitelistHelperTests.nameHashes[2] + EvmWhitelistHelperTests.cleanAddresses[2],
                EvmWhitelistHelperTests.nameHashes[3] + EvmWhitelistHelperTests.cleanAddresses[3]
            ]
        )
    }
    
    func testAddressRemoved() throws {
        XCTAssertEqual(
            try EvmWhitelistHelper(addresses: EvmWhitelistHelperTests.addresses, targetDests: EvmWhitelistHelperTests.destinations.prefix(3).map { $0 }).allChanges(),
            [
                "000000000000000000000001" + EvmWhitelistHelperTests.cleanAddresses[2]
            ]
        )
    }
    
    func testMultipleContiguousAddressesRemoved() throws {
        XCTAssertEqual(
            try EvmWhitelistHelper(addresses: EvmWhitelistHelperTests.addresses, targetDests: EvmWhitelistHelperTests.destinations.prefix(2).map { $0 }).allChanges(),
            [
                "000000000000000000000002" + EvmWhitelistHelperTests.cleanAddresses[1]
            ]
        )
    }
    
    func testMultipleNonContiguousAddressesRemoved() throws {
        XCTAssertEqual(
            try EvmWhitelistHelper(addresses: EvmWhitelistHelperTests.addresses, targetDests: [EvmWhitelistHelperTests.destinations[1]]).allChanges(),
            [
                "000000000000000000000001" + EvmTransactionUtil.sentinelAddress,
                "000000000000000000000002" + EvmWhitelistHelperTests.cleanAddresses[1]
            ]
        )
    }
    
    func testAddsAndRemoves() throws {
        XCTAssertEqual(
            try EvmWhitelistHelper(addresses: EvmWhitelistHelperTests.addresses.prefix(3).map { $0 },
                               targetDests: [EvmWhitelistHelperTests.destinations[1], EvmWhitelistHelperTests.destinations[2], EvmWhitelistHelperTests.destinations[3]]).allChanges(),
            [
                "000000000000000000000001" + EvmTransactionUtil.sentinelAddress,
                EvmWhitelistHelperTests.nameHashes[3] + EvmWhitelistHelperTests.cleanAddresses[3]
            ]
        )
    }
    
}

