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
    let identifier: String
    let secKey: SecKey

    fileprivate init(identifier: String, secKey: SecKey) {
        self.secKey = secKey
        self.identifier = identifier
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

        return DeviceKey(identifier: deviceKeyIdentifier(email: email), secKey: secKey)
    }

    static func generateDeviceKey(email: String, authenticationContext: LAContext? = nil) throws -> DeviceKey {
        if let deviceKey = deviceKey(email: email, authenticationContext: authenticationContext) {
            return deviceKey
        } else {
            let secKey = try makeAndStoreKey(name: deviceKeyIdentifier(email: email), authenticationContext: authenticationContext)
            return DeviceKey(identifier: deviceKeyIdentifier(email: email), secKey: secKey)
        }
    }
}



extension DeviceKey {
//    func preauthenticated(with context: LAContext) throws -> DeviceKey {
//        if let key = SecureEnclaveWrapper.loadKey(name: identifier, authenticationContext: context) {
//            return DeviceKey(identifier: identifier, secKey: secKey)
//        } else {
//            throw PreauthSecureEnclaveKeyError.keyNoLongerExists
//        }
//    }
//
//    func withPreauthenticatedKey(_ closure: @escaping (Result<Self, Error>) async -> Void) {
//        let context = LAContext()
//        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Verify your identity") { success, error in
//            if let error = error {
//                Task {
//                    await closure(.failure(error))
//                }
//            } else if let key = SecureEnclaveWrapper.loadKey(name: identifier, authenticationContext: context) {
//                Task {
//                    await closure(.success(DeviceKey(identifier: identifier, secKey: key)))
//                    //context.invalidate()
//                }
//            } else {
//                Task {
//                    await closure(.failure(PreauthSecureEnclaveKeyError.keyNoLongerExists))
//                }
//            }
//        }
//    }
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

        return DeviceKey(identifier: "test", secKey: privateKey)
    }
}
#endif
