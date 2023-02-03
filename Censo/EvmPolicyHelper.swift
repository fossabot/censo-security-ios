//
//  EvmConfigTransactionHelper.swift
//  Censo
//
//  Created by Brendan Flood on 2/1/23.
//

import Foundation

enum SafeTx: Equatable{
    case swapOwner(String, String, String)
    case addOwnerWithThreshold(String, Int)
    case removeOwner(String, String, Int)
    case changeThreshold(Int)
}

struct Policy {
    let owners: [String]
    let threshold: Int
    
    init(owners: [String], threshold: Int) throws {
        self.owners = owners
        self.threshold = threshold
        
        try assertPolicy(Set(owners).count == owners.count, "duplicate owners")
        try assertPolicy(owners.count >= 1, "owners must be >= 1")
        try assertPolicy(threshold >= 1, "threshold must be >= 1")
        try assertPolicy(threshold <= owners.count, "threshold \(threshold) must be <= count \(owners.count)")
    }
    
    private func assertPolicy(_ assertion: Bool, _ msg: String) throws {
        if !assertion {
            throw EvmConfigError.invalidPolicy(msg)
        }
    }
    
    func addedOwners(_ targetPolicy: Policy) -> [String] {
        return Set(targetPolicy.owners).subtracting(Set(owners)).sorted().map({$0})
    }

    func removedOwners(_ targetPolicy: Policy) -> [String] {
        return Set(owners).subtracting(Set(targetPolicy.owners)).sorted().map({$0})
    }
    
    private func prevOwner(_ owner: String) throws -> String {
        var prev: String? = nil
        for o in owners {
            if (o == owner) {
                return prev ?? EvmTransactionUtil.sentinelAddress
            }
            prev = o
        }
        throw EvmConfigError.invalidPolicy("prev not found for \(owner)")
    }
    
    func applyTransaction(_ tx: SafeTx) throws -> Policy {
        var currentOwners = owners.map { $0 }
        var currentThreshold = threshold
        switch tx {
        case .swapOwner(let prev, let old, let new):
            let ownerIndex = currentOwners.firstIndex(of: old)
            try assertPolicy(ownerIndex != nil, "ownerIndex is nil")
            try assertPolicy(prev == (ownerIndex == 0 ? EvmTransactionUtil.sentinelAddress : currentOwners[ownerIndex! - 1]), "invalid preb calculation")
            currentOwners[ownerIndex!] = new
        case .addOwnerWithThreshold(let owner, let threshold):
            currentOwners.insert(owner, at: 0)
            try assertPolicy(threshold >= 1, "threshold must be >= 1")
            try assertPolicy(threshold <= currentOwners.count, "threshold \(threshold) must be <= count \(currentOwners.count)")
            currentThreshold = threshold
        case .removeOwner(let prev, let owner, let threshold):
            let ownerIndex = currentOwners.firstIndex(of: owner)
            try assertPolicy(ownerIndex != nil, "ownerIndex is nil")
            try assertPolicy(prev == (ownerIndex == 0 ? EvmTransactionUtil.sentinelAddress : currentOwners[ownerIndex! - 1]), "invalid preb calculation")
            currentOwners.remove(at: ownerIndex!)
            try assertPolicy(threshold >= 1, "threshold must be > 1")
            try assertPolicy(threshold <= currentOwners.count, "threshold \(threshold) must be <= count \(currentOwners.count)")
            currentThreshold = threshold
        case .changeThreshold(let threshold):
            currentThreshold = threshold
        }
        return try Policy(owners: currentOwners, threshold: currentThreshold)
    }
    
    func safeTransactions(_ targetPolicy: Policy) throws -> ([SafeTx], Policy) {
        let toAdd = addedOwners(targetPolicy)
        let toRemove = removedOwners(targetPolicy)
        let numSwaps = min(toAdd.count, toRemove.count)
        var transactions: [SafeTx] = []
        var currentPolicy = try Policy(owners: owners, threshold: threshold)
        
        for i in 0..<numSwaps {
            let tx = try SafeTx.swapOwner(currentPolicy.prevOwner(toRemove[i]), toRemove[i], toAdd[i])
            currentPolicy = try currentPolicy.applyTransaction(tx)
            transactions.append(tx)
        }
        let numAdds = toAdd.count - numSwaps
        let numRemoves = toRemove.count - numSwaps
        
        for i in numSwaps..<toAdd.count {
            let tx = SafeTx.addOwnerWithThreshold(toAdd[i], threshold)
            currentPolicy = try currentPolicy.applyTransaction(tx)
            transactions.append(tx)
        }
        
        for i in numSwaps..<toRemove.count {
            let tx = try SafeTx.removeOwner(currentPolicy.prevOwner(toRemove[i]), toRemove[i], max(1, threshold - (1 + i - numSwaps)))
            currentPolicy = try currentPolicy.applyTransaction(tx)
            transactions.append(tx)
        }
        if currentPolicy.threshold != targetPolicy.threshold {
            if transactions.count == 0 || (numAdds == 0 && numRemoves == 0) {
                let tx = SafeTx.changeThreshold(targetPolicy.threshold)
                currentPolicy = try currentPolicy.applyTransaction(tx)
                transactions.append(tx)
            } else {
                let lastTx = transactions[transactions.indices.last!]
                switch lastTx {
                case .addOwnerWithThreshold(let owner, _):
                    transactions[transactions.indices.last!] = .addOwnerWithThreshold(owner, targetPolicy.threshold)
                case .removeOwner(let prev, let owner, _):
                    transactions[transactions.indices.last!] = .removeOwner(prev, owner, targetPolicy.threshold)
                default:
                    break;
                }
                currentPolicy = try Policy(owners: currentPolicy.owners, threshold: targetPolicy.threshold)
            }
        }
        return (transactions, currentPolicy)
    }
}

