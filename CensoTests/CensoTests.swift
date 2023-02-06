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
            case .ethereumWithdrawalRequest(let request as EthereumSignable),
                 .ethereumWalletNameUpdate(let request as EthereumSignable),
                 .ethereumWalletSettingsUpdate(let request as EthereumSignable),
                 .ethereumTransferPolicyUpdate(let request as EthereumSignable),
                 .ethereumWalletWhitelistUpdate(let request as EthereumSignable):
                
                XCTAssertEqual(
                    try request.signableData().toHexString(),
                    testCase.hash
                )
            case .vaultPolicyUpdate(let request as MultichainSignable):
                let signatures = try request.signableData()
                XCTAssertEqual(signatures.count, 1)
                XCTAssertEqual(signatures[0].0, Chain.ethereum)
                XCTAssertEqual(signatures[0].1.toHexString(), testCase.hash)
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
