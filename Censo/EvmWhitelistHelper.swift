//
//  EvmWhitelistHelper.swift
//  Censo
//
//  Created by Brendan Flood on 2/1/23.
//

import Foundation

import Foundation
import CryptoKit

struct EvmDestination {
    var name: String
    var address: String
}

struct WhitelistSettings: Equatable {
    var whitelistEnabled: Bool
    var dAppsEnabled: Bool
}

extension EvmDestination {
    var nameHash: Data {
        Data(SHA256.hash(data: name.data(using: .utf8)!).bytes.prefix(12))
    }
    
    var nameHashAndAddress: Data {
        nameHash + address.data(using: .hexadecimal)!
    }
}


struct EvmWhitelistHelper {
    var currentAddresses: [String]
    var targetAddresses: [String]
    var targetDestinations: [EvmDestination]
    
    init(addresses: [String], targetDests: [EvmDestination]) {
        targetDestinations = targetDests
        currentAddresses = addresses.map( { $0.lowercased() })
        targetAddresses = targetDestinations.map( { $0.address.lowercased() })
    }
    
    private static let censoGuard = "CensoGuard"
    private static let censoTransfersOnlyGuard = "CensoTransfersOnlyGuard"
    private static let censoTransfersOnlyWhitelistingGuard = "CensoTransfersOnlyWhitelistingGuard"
    private static let censoWhitelistingGuard = "CensoWhitelistingGuard"
    
    static func getTargetGuardAddress(currentGuardAddress: String, whitelistEnabled: Bool?, dappsEnabled: Bool?, guardAddresses: [ContractNameAndAddress]) -> String {
        let currentSettings = getCurrentSettingsForGuardName(
            guardAddresses.first(where: { $0.address.lowercased() == currentGuardAddress.lowercased() })?.name ?? censoGuard
        )
        let targetSettings = WhitelistSettings(whitelistEnabled: whitelistEnabled ?? currentSettings.whitelistEnabled,
                                               dAppsEnabled: dappsEnabled ?? currentSettings.dAppsEnabled)
        return guardAddresses.first(where: { $0.name == getGuardNameForTargetSettings(targetSettings) })?.address ?? currentGuardAddress
    }
    
    static func getCurrentSettingsForGuardName(_ guardName: String) -> WhitelistSettings {
        switch guardName {
        case censoGuard:
            return WhitelistSettings(whitelistEnabled: false, dAppsEnabled: true)
        case censoTransfersOnlyGuard:
            return WhitelistSettings(whitelistEnabled: false, dAppsEnabled: false)
        case censoTransfersOnlyWhitelistingGuard:
            return WhitelistSettings(whitelistEnabled: true, dAppsEnabled: false)
        default:
            return WhitelistSettings(whitelistEnabled: true, dAppsEnabled: true)
        }
    }
    
    static func getGuardNameForTargetSettings(_ targetSettings: WhitelistSettings) -> String {
        switch targetSettings {
        case WhitelistSettings(whitelistEnabled: false, dAppsEnabled: true):
            return censoGuard
        case WhitelistSettings(whitelistEnabled: false, dAppsEnabled: false):
            return censoTransfersOnlyGuard
        case WhitelistSettings(whitelistEnabled: true, dAppsEnabled: false):
            return censoTransfersOnlyWhitelistingGuard
        default:
            return censoWhitelistingGuard
        }
    }
    
    func addedAddresses() -> [String] {
        return Set(targetAddresses).subtracting(Set(currentAddresses)).sorted().map {
            address -> String in targetDestinations.first(where: {$0.address.lowercased() == address})!.nameHashAndAddress.toHexString()
        }
    }
    
    func removedAddresses() throws -> [String] {
        var sequenceList: [[String]] = []
        let removedAddresses = Set(currentAddresses).subtracting(Set(targetAddresses))
        if !removedAddresses.isEmpty {
            for address in currentAddresses {
                if removedAddresses.contains(address) {
                    let prevAddress = try prevAddress(address)
                    if !sequenceList.isEmpty && sequenceList.last!.contains(prevAddress) {
                        sequenceList.indices.last.map{ sequenceList[$0].append(address) }
                    } else {
                        sequenceList.append([address])
                    }
                }
            }
        }
        return try sequenceList.map {
            var txData = Data(capacity: 32)
            EvmTransactionUtil.appendPadded(destination: &txData, source: Bignum($0.count).data.suffix(12), padTo: 12)
            try EvmTransactionUtil.appendPadded(destination: &txData, source: prevAddress($0[0]).data(using: .hexadecimal)!, padTo: 20)
            return txData.toHexString()
        }
    }
    
    func allChanges() throws -> [String] {
        return try removedAddresses() + addedAddresses()
    }
    
    private func prevAddress(_ address: String) throws -> String {
        var prev: String? = nil
        for addr in currentAddresses {
            if (addr == address) {
                return prev ?? EvmTransactionUtil.sentinelAddress
            }
            prev = addr
        }
        throw EvmConfigError.invalidWhitelist("prev not found for \(address)")
    }
    
}



