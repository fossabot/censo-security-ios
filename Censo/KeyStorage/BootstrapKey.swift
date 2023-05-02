//
//  BootstrapKey.swift
//  Censo
//
//  Created by Ata Namvari on 2023-04-06.
//

import Foundation
import LocalAuthentication

struct BootstrapKey: SecureEnclaveKey {
    let identifier: String
    let secKey: SecKey

    fileprivate init(identifier: String, secKey: SecKey) {
        self.secKey = secKey
        self.identifier = identifier
    }
}

extension DeviceKey {
    func bootstrapKeyIdentifier() throws -> String {
        let identifier = try publicExternalRepresentation().base64EncodedString()
        return "bootstrapKey-\(identifier)"
    }

    func bootstrapKey(authenticationContext: LAContext? = nil) throws -> BootstrapKey? {
        guard let secKey = SecureEnclaveWrapper.loadKey(name: try bootstrapKeyIdentifier(), authenticationContext: authenticationContext) else {
            return nil
        }

        return BootstrapKey(identifier: try bootstrapKeyIdentifier(), secKey: secKey)
    }

    func generateBootstrapKey(authenticationContext: LAContext? = nil) throws -> BootstrapKey {
        if let bootstrapKey = try bootstrapKey(authenticationContext: authenticationContext) {
            return bootstrapKey
        } else {
            let secKey = try SecureEnclaveWrapper.makeAndStoreKey(name: try bootstrapKeyIdentifier(), authenticationContext: authenticationContext)
            return BootstrapKey(identifier: try bootstrapKeyIdentifier(), secKey: secKey)
        }
    }

    func removeBootstrapKey() throws {
        SecureEnclaveWrapper.removeKey(name: try bootstrapKeyIdentifier())
    }
}
