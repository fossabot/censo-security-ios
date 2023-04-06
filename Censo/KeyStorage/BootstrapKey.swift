//
//  BootstrapKey.swift
//  Censo
//
//  Created by Ata Namvari on 2023-04-06.
//

import Foundation

struct BootstrapKey: SecureEnclaveKey {
    let secKey: SecKey

    fileprivate init(secKey: SecKey) {
        self.secKey = secKey
    }
}

extension SecureEnclaveWrapper {
    static func bootstrapKeyIdentifier(email: String) -> String {
        let email = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return "bootstrapKey-\(email)"
    }

    static func bootstrapKey(email: String) -> BootstrapKey? {
        guard let secKey = loadKey(name: bootstrapKeyIdentifier(email: email)) else {
            return nil
        }

        return BootstrapKey(secKey: secKey)
    }

    static func generateBootstrapKey(email: String) throws -> BootstrapKey {
        if let bootstrapKey = bootstrapKey(email: email) {
            return bootstrapKey
        } else {
            let secKey = try makeAndStoreKey(name: bootstrapKeyIdentifier(email: email))
            return BootstrapKey(secKey: secKey)
        }
    }
}
