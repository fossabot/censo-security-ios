//
//  EIP712Data.swift
//  Censo
//
//  Created by Ben Holzman on 5/8/23.
//
import Foundation
import GenericJSON

struct EIP712Type: Codable {
    let name: String
    let type: String
}

struct EIP712Entry: Codable, Equatable, Hashable {
    let name: String
    let type: String
    let value: JSON
    func isArray() -> Bool {
        return type.hasSuffix("[]")
    }
    func baseType() -> String {
        if (isArray()) {
            return String(type.dropLast(2))
        } else {
            return type
        }
    }
}


struct EIP712TypedData: Codable {
    let types: [String: [EIP712Type]]
    let primaryType: String
    let domain: JSON
    let message: JSON

    func getDomainName() -> String? {
        let domainEntries = self.getDomainEntries()
        
        return domainEntries.first(where: { $0.name == "name" })?.value.stringValue
    }

    func getDomainVerifyingContract() -> String? {
        return self.getDomainEntries().first(where: { $0.name == "verifyingContract" })?.value.stringValue?.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
    }

    func getDomainEntries() -> Array<EIP712Entry> {
        guard let domainType = types["EIP712Domain"] else { return [] }
        return domainType.compactMap { field in
            if let value = domain[field.name] {
                return EIP712Entry(name: field.name, type: field.type, value: value)
            } else {
                return EIP712Entry?(nil)
            }
        }
    }
    
    func getEntriesForType(type: String, from: JSON) -> [EIP712Entry] {
        if let types = types[type] {
            return types.compactMap { field in
                if let value = from[field.name] {
                    return EIP712Entry(name: field.name, type: field.type, value: value)
                } else {
                    return EIP712Entry?(nil)
                }
            }
        } else {
            return []
        }
    }
    
    func getMessageEntries() -> [EIP712Entry] {
        return getEntriesForType(type: primaryType, from: message)
    }

    func hasType(type: String) -> Bool {
        return types.contains(where: { $0.key == type })
    }
}
