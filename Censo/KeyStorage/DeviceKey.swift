//
//  DeviceKey.swift
//  Censo
//
//  Created by Ata Namvari on 2023-01-31.
//

import Foundation
import Security

protocol SecureEnclaveKey {
    var secKey: SecKey { get }
}

enum SecKeyError: Error {
    case invalidKey
    case algorithmNotSupported
}

extension SecureEnclaveKey {
    public func publicExternalRepresentation() throws -> Data {
        guard let publicKey = SecKeyCopyPublicKey(secKey) else {
            throw SecKeyError.invalidKey
        }

        var error: Unmanaged<CFError>?
        let data = SecKeyCopyExternalRepresentation(publicKey, &error) as Data?
        guard data != nil else {
            throw error!.takeRetainedValue() as Error
        }

        return data!
    }

    public func encrypt(data: Data) throws -> Data {
        guard let publicKey = SecKeyCopyPublicKey(secKey) else {
            throw SecKeyError.invalidKey
        }

        let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM

        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
            throw SecKeyError.algorithmNotSupported
        }

        var error: Unmanaged<CFError>?
        let encryptedData = SecKeyCreateEncryptedData(publicKey, algorithm,
                                                   data as CFData,
                                                   &error) as Data?
        guard encryptedData != nil else {
            throw error!.takeRetainedValue() as Error
        }

        return encryptedData!
    }

    public func decrypt(data: Data) throws -> Data {
        let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM

        guard SecKeyIsAlgorithmSupported(secKey, .decrypt, algorithm) else {
            throw SecKeyError.algorithmNotSupported
        }


        var error: Unmanaged<CFError>?
        let decryptedData = SecKeyCreateDecryptedData(secKey,
                                                      algorithm,
                                                      data as CFData,
                                                      &error) as Data?

        guard decryptedData != nil else {
            throw error!.takeRetainedValue() as Error
        }

        return decryptedData!
    }

    func signature(for data: Data) throws -> Data {
        let algorithm: SecKeyAlgorithm = .ecdsaSignatureMessageX962SHA256

        guard SecKeyIsAlgorithmSupported(secKey, .sign, algorithm) else {
            throw SecKeyError.algorithmNotSupported
        }


        var error: Unmanaged<CFError>?
        let signature = SecKeyCreateSignature(secKey, algorithm,
                                          data as CFData,
                                          &error) as Data?

        guard signature != nil else {
            throw error!.takeRetainedValue() as Error
        }

        return signature!
    }
}

// DeviceKey

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

    static func deviceKey(email: String) -> DeviceKey? {
        guard let secKey = loadKey(name: deviceKeyIdentifier(email: email)) else {
            return nil
        }

        return DeviceKey(secKey: secKey)
    }

    static func generateDeviceKey(email: String) throws -> DeviceKey {
        if let deviceKey = deviceKey(email: email) {
            return deviceKey
        } else {
            let secKey = try makeAndStoreKey(name: deviceKeyIdentifier(email: email))
            return DeviceKey(secKey: secKey)
        }
    }
}

// Bootstrap Key

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

#if DEBUG
extension DeviceKey {
    static var sample: DeviceKey {
        let access =
            SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                            [.privateKeyUsage, .biometryCurrentSet],
                                            nil)!

        let attributes: [String: Any] = [
            kSecAttrKeyType as String           : kSecAttrKeyTypeEC,
            kSecAttrKeySizeInBits as String     : 256,
            kSecPrivateKeyAttrs as String : [
                kSecAttrIsPermanent as String       : true,
                kSecAttrApplicationTag as String    : "test",
                //kSecAttrAccessControl as String     : access
            ]
        ]

        var error: Unmanaged<CFError>?
        let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error)!

        return DeviceKey(secKey: privateKey)
    }
}
#endif
