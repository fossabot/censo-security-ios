//
//  Keychain+Storage.swift
//  Censo
//
//  Created by Ata Namvari on 2022-10-31.
//

import Foundation

extension Keychain {
    static private let rootSeedService = "com.censocustody.root-seed-encrypted"

    static func encryptedRootSeed(email: String) throws -> Data? {
        try load(account: email, service: rootSeedService)
    }

    static func saveEncryptedRootSeed(_ encryptedRootSeed: Data, email: String) throws {
        let email = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        try save(account: email, service: rootSeedService, data: encryptedRootSeed, biometryProtected: false)
    }
}
