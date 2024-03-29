//
//  SecureEnclaveKey.swift
//  Censo
//
//  Created by Ata Namvari on 2023-04-06.
//

import Foundation
import LocalAuthentication

protocol SecureEnclaveKey {
    var identifier: String { get }
    var secKey: SecKey { get }
}

enum SecKeyError: Error {
    case invalidKey
    case algorithmNotSupported
}

struct PreauthenticatedKey<Key> where Key : SecureEnclaveKey {
    fileprivate(set) var key: Key
    fileprivate var secKey: SecKey

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

enum PreauthSecureEnclaveKeyError: Error {
    case keyNoLongerExists
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

    public func preauthenticatedKey(context: LAContext) throws -> PreauthenticatedKey<Self> {
        if let key = SecureEnclaveWrapper.loadKey(name: identifier, authenticationContext: context) {
            return PreauthenticatedKey(key: self, secKey: key)
        } else {
            throw PreauthSecureEnclaveKeyError.keyNoLongerExists
        }
    }
}
