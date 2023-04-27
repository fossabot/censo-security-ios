//
//  RegisteredDevice.swift
//  Censo
//
//  Created by Ata Namvari on 2023-04-06.
//

import Foundation
import LocalAuthentication

struct RegisteredDevice {
    private(set) var deviceKey: DeviceKey
    var encryptedRootSeed: Data

    private var authenticationContext: LAContext?

    var email: String
    var publicKeys: PublicKeys

    init(email: String, deviceKey: DeviceKey, encryptedRootSeed: Data, publicKeys: PublicKeys) {
        self.deviceKey = deviceKey
        self.encryptedRootSeed = encryptedRootSeed
        self.email = email
        self.publicKeys = publicKeys
    }

    var bootstrapKey: BootstrapKey? {
        SecureEnclaveWrapper.bootstrapKey(email: email, authenticationContext: authenticationContext)
    }

//    func deviceSignature(for data: Data) throws -> Data {
//        try deviceKey.signature(for: data)
//    }

//    func privateKeys() throws -> PrivateKeys {
//        let rootSeed = try deviceKey.decrypt(data: encryptedRootSeed)
//        return try PrivateKeys(rootSeed: rootSeed.bytes)
//    }

    func devicePublicKey() throws -> String {
        try deviceKey.publicExternalRepresentation().base58String
    }

//    func decrypt(_ data: Data) throws -> Data {
//        try deviceKey.decrypt(data: data)
//    }

    func removeBootstrapKey() {
        SecureEnclaveWrapper.removeBootstrapKey(email: email)
    }
}

//struct AuthenticatedKeys {
//    enum AuthenticatedKeyError: Error {
//        case keyNotFound
//    }
//
//    var context: LAContext
//    var deviceKey: DeviceKey
//    var bootstrapKey: BootstrapKey?
//
//    static func withAuhenticatedKeys(from email: String, closure: @escaping (Result<AuthenticatedKeys, Error>) async -> Void) {
//        let context = LAContext()
//        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Verify your identity") { success, error in
//            if let error = error {
//                Task {
//                    await closure(.failure(error))
//                }
//            } else if let deviceKey = SecureEnclaveWrapper.deviceKey(email: email, authenticationContext: context) {
//                Task {
//                    let bootstrapKey = SecureEnclaveWrapper.bootstrapKey(email: email, authenticationContext: context)
//                    let registeredDevice = AuthenticatedKeys(context: context, deviceKey: deviceKey, bootstrapKey: bootstrapKey)
//                    await closure(.success(registeredDevice))
//                    //context.invalidate()
//                }
//            } else {
//                Task {
//                    await closure(.failure(AuthenticatedKeyError.keyNotFound))
//                }
//            }
//        }
//    }
//}
