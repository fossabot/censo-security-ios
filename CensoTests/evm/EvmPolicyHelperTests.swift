//
//  EvmPolicyHelperTest.swift
//  CensoTests
//
//  Created by Brendan Flood on 2/2/23.
//

import XCTest
@testable import Censo

class EvmPolicyHelperTests: XCTestCase {
    
    
    func testAddOwners() throws {
        let startingPolicy = Policy(owners: ["owner-1", "owner-2"], threshold: 1)
        for (targetOwners, expected) in  [
            (["owner-3"], ["owner-3"]),
            (["owner-4", "owner-3", "owner-1"], ["owner-3", "owner-4"]),
            (["owner-1"], []),
            (["owner-1", "owner-2"], [])] {
            XCTAssertEqual(startingPolicy.addedOwners(Policy(owners: targetOwners, threshold: 1)), expected)
        }
    }
    
    func testRemoveOwners() throws {
        let startingPolicy = Policy(owners: ["owner-2", "owner-1"], threshold: 1)
        for (targetOwners, expected) in  [
            (["owner-2"], ["owner-1"]),
            (["owner-3"], ["owner-1", "owner-2"]),
            (["owner-3", "owner-1"], ["owner-2"])] {
            XCTAssertEqual(startingPolicy.removedOwners(Policy(owners: targetOwners, threshold: 1)), expected)
        }
    }
    
    
    func testSafeTransactions() throws {
        let startingPolicy = Policy(owners: ["owner-1", "owner-2"], threshold: 1)
        for (targetPolicy, expected) in [
            (
                Policy(owners: ["owner-1", "owner-2"], threshold: 1),
                []
            ),
            (
                Policy(owners: ["owner-1"], threshold: 1),
                [
                    SafeTx.removeOwner("owner-1", "owner-2", 1)
                ]
            ),
            (
                Policy(owners: ["owner-2"], threshold: 1),
                [
                    SafeTx.removeOwner(EvmTransactionUtil.sentinelAddress, "owner-1", 1)
                ]
            ),
            (
                Policy(owners: ["owner-1", "owner-3"], threshold: 1),
                [
                    SafeTx.swapOwner("owner-1", "owner-2", "owner-3")
                ]
            ),
            (
                Policy(owners: ["owner-3", "owner-2"], threshold: 1),
                [
                    SafeTx.swapOwner(EvmTransactionUtil.sentinelAddress, "owner-1", "owner-3")
                ]
            ),
            (
                Policy(owners: ["owner-3", "owner-4"], threshold: 1),
                [
                    SafeTx.swapOwner(EvmTransactionUtil.sentinelAddress, "owner-1", "owner-3"),
                    SafeTx.swapOwner("owner-3", "owner-2", "owner-4")
                ]
            ),
            (
                Policy(owners: ["owner-3", "owner-4"], threshold: 2),
                [
                    SafeTx.swapOwner(EvmTransactionUtil.sentinelAddress, "owner-1", "owner-3"),
                    SafeTx.swapOwner("owner-3", "owner-2", "owner-4"),
                    SafeTx.changeThreshold(2)
                ]
            ),
            (
                Policy(owners: ["owner-1", "owner-3", "owner-4"], threshold: 2),
                [
                    SafeTx.swapOwner("owner-1", "owner-2", "owner-3"),
                    SafeTx.addOwnerWithThreshold("owner-4", 2)
                ]
            ),
        ] {
            let (transactions, endingPolicy) = startingPolicy.safeTransactions(targetPolicy)
            XCTAssertEqual(transactions, expected)
            assertPolicyMatches(startingPolicy: startingPolicy, targetPolicy: targetPolicy, transactions: transactions, endingPolicy: endingPolicy)
        }
    }
    
    func testSafeTransactionsRandom() throws {
        let allOwners = ["owner-1", "owner-2", "owner-3", "owner-4", "owner-5", "owner-6", "owner-7", "owner-8", "owner-9", "owner-10"]
        
        for _ in 0...100 {
            let startCount = Int.random(in: 1...allOwners.count)
            let startingThreshold = Int.random(in: 1...startCount)
            let startingPolicy = Policy(owners: allOwners.shuffled().prefix(startCount).map{ $0 }, threshold: startingThreshold)
            let endingCount = Int.random(in: 1...allOwners.count)
            let endingThreshold = Int.random(in: 1...endingCount)
            let endingPolicy = Policy(owners: allOwners.shuffled().prefix(endingCount).map{ $0 }, threshold: endingThreshold)
            let (transactions, computedEndingPolicy) = startingPolicy.safeTransactions(endingPolicy)
            assertPolicyMatches(startingPolicy: startingPolicy, targetPolicy: endingPolicy, transactions: transactions, endingPolicy: computedEndingPolicy)
        }
    }
    
    private func assertPolicyMatches(startingPolicy: Policy, targetPolicy: Policy, transactions: [SafeTx], endingPolicy: Policy) {
        XCTAssertEqual(Set(endingPolicy.owners), Set(targetPolicy.owners))
        XCTAssertEqual(endingPolicy.threshold, targetPolicy.threshold)
        // recompute ending policy from transactions
        var policy = Policy(owners: startingPolicy.owners, threshold: startingPolicy.threshold)
        for transaction in transactions {
            policy = policy.applyTransaction(transaction)
        }
        XCTAssertEqual(policy.owners, endingPolicy.owners)
        XCTAssertEqual(policy.threshold, endingPolicy.threshold)
    }
}

