//
//  DeviceKey.swift
//  Censo
//
//  Created by Ata Namvari on 2023-01-31.
//

import Foundation
import Security
import LocalAuthentication

struct DeviceKey: SecureEnclaveKey {
    let secKey: SecKey

    fileprivate init(secKey: SecKey) {
        self.secKey = secKey
    }
}

extension SecureEnclaveWrapper {
    static func deviceKeyIdentifier(email: String) -> String {
        let email = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return "deviceKey-\(email)"
    }

    static func deviceKey(email: String, authenticationContext: LAContext? = nil) -> DeviceKey? {
        guard let secKey = loadKey(name: deviceKeyIdentifier(email: email), authenticationContext: authenticationContext) else {
            return nil
        }

        return DeviceKey(secKey: secKey)
    }

    static func generateDeviceKey(email: String, authenticationContext: LAContext? = nil) throws -> DeviceKey {
        if let deviceKey = deviceKey(email: email, authenticationContext: authenticationContext) {
            return deviceKey
        } else {
            let secKey = try makeAndStoreKey(name: deviceKeyIdentifier(email: email), authenticationContext: authenticationContext)
            return DeviceKey(secKey: secKey)
        }
    }
}

#if DEBUG
extension DeviceKey {
    static var sample: DeviceKey {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String           : kSecAttrKeyTypeEC,
            kSecAttrKeySizeInBits as String     : 256,
            kSecPrivateKeyAttrs as String : [
                kSecAttrIsPermanent as String       : true,
                kSecAttrApplicationTag as String    : "test"
            ] as [String : Any]
        ]

        var error: Unmanaged<CFError>?
        let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error)!

        return DeviceKey(secKey: privateKey)
    }
}
#endif
