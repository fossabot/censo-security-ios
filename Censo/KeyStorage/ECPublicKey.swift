//
//  ECPublicKey.swift
//  Censo
//
//  Created by Ata Namvari on 2023-04-05.
//

import Foundation
import Security

struct ECPublicKey {
    private var secKey: SecKey

    enum PublicKeyError: Error {
        case badPublicKey
    }

    init(data: Data) throws {
        guard let secKey = SecKeyCreateWithData(data as NSData, [
            kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
        ] as NSDictionary, nil) else {
            throw PublicKeyError.badPublicKey
        }

        self.secKey = secKey
    }

    func encrypt(data: Data) throws -> Data {
        let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM

        guard SecKeyIsAlgorithmSupported(secKey, .encrypt, algorithm) else {
            throw SecKeyError.algorithmNotSupported
        }

        var error: Unmanaged<CFError>?
        let encryptedData = SecKeyCreateEncryptedData(secKey, algorithm,
                                                   data as CFData,
                                                   &error) as Data?
        guard encryptedData != nil else {
            throw error!.takeRetainedValue() as Error
        }

        return encryptedData!
    }
}

extension ECPublicKey {
    init(base58String: String) throws {
        try self.init(data: Data(Base58.decode(base58String)))
    }
}
