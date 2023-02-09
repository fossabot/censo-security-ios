//
//  CensoTests.swift
//  CensoTests
//
//  Created by Donald Ness on 12/23/20.
//

import XCTest
@testable import Censo
import CryptoKit

struct TestCase: Codable {
    var request: String
    var hash: String? = nil
    var hashes: [String]? = nil
}

struct TestCases: Codable {
    var testCases: [TestCase]
}

class CensoTests: XCTestCase {
    
    func testBitcoinSignable() throws {
        for testCase in getTestCases(resource: "bitcoin-test-cases") {
            let request: ApprovalRequest = Mock.decodeJsonType(data: testCase.request.data(using: .utf8)!)
            switch request.details {
            case .bitcoinWithdrawalRequest(let request as BitcoinSignable):
                XCTAssertEqual(
                    try request.signableDataList().map { $0.toHexString() },
                    testCase.hashes
                )
            default:
                XCTFail("Invalid request type")
            }
        }
    }
    
    func testEthereumSignable() throws {
        for testCase in getTestCases(resource: "ethereum-test-cases") {
            let request: ApprovalRequest = Mock.decodeJsonType(data: testCase.request.data(using: .utf8)!)
            switch request.details {
            case .ethereumWithdrawalRequest(let request as EvmSignable),
                 .ethereumWalletNameUpdate(let request as EvmSignable),
                 .ethereumWalletSettingsUpdate(let request as EvmSignable),
                 .ethereumTransferPolicyUpdate(let request as EvmSignable),
                 .ethereumWalletWhitelistUpdate(let request as EvmSignable),
                 .polygonWithdrawalRequest(let request as EvmSignable),
                 .polygonWalletNameUpdate(let request as EvmSignable),
                 .polygonWalletSettingsUpdate(let request as EvmSignable),
                 .polygonTransferPolicyUpdate(let request as EvmSignable),
                 .polygonWalletWhitelistUpdate(let request as EvmSignable):
                
                XCTAssertEqual(
                    try request.signableData().toHexString(),
                    testCase.hash
                )
            case .vaultPolicyUpdate(let request as MultichainSignable):
                let signatures = try request.signableData()
                XCTAssertEqual(signatures.count, 2)
                XCTAssertEqual(signatures[0].0, Chain.ethereum)
                XCTAssertEqual(signatures[0].1.toHexString(), testCase.hash)
                XCTAssertEqual(signatures[1].0, Chain.polygon)
                XCTAssertEqual(signatures[1].1.toHexString(), testCase.hash)
            default:
                XCTFail("Invalid request type")
            }
        }
    }
    
    func testOffchainSignable() throws {
        for testCase in getTestCases(resource: "offchain-test-cases") {
            let request: ApprovalRequest = Mock.decodeJsonType(data: testCase.request.data(using: .utf8)!)
            switch request.details {
            case .ethereumWalletCreation,
                 .bitcoinWalletCreation,
                 .polygonWalletCreation,
                 .addressBookUpdate,
                 .vaultPolicyUpdate:
                XCTAssertEqual(request.details,
                               Mock.decodeJsonType(data: try JSONEncoder().encode(request.details)))
            default:
                XCTFail("Invalid request type")
            }
        }
    }
    
    private func getTestCases(resource: String) -> [TestCase] {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: resource, withExtension: "json") else {
            XCTFail("Missing file: \(resource).json")
            return []
        }
        let decoder = JSONDecoder()
        return try! decoder.decode(TestCases.self, from: try Data(contentsOf: url)).testCases
    }
}
