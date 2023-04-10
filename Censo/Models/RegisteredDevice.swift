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
    private var encryptedRootSeed: Data

    private var authenticationContext: LAContext?

    var email: String

    init(email: String, deviceKey: DeviceKey, encryptedRootSeed: Data) {
        self.deviceKey = deviceKey
        self.encryptedRootSeed = encryptedRootSeed
        self.email = email
    }

    var bootstrapKey: BootstrapKey? {
        SecureEnclaveWrapper.bootstrapKey(email: email, authenticationContext: authenticationContext)
    }


    func deviceSignature(for data: Data) throws -> Data {
        try deviceKey.signature(for: data)
    }

    func privateKeys() throws -> PrivateKeys {
        let rootSeed = try deviceKey.decrypt(data: encryptedRootSeed)
        return try PrivateKeys(rootSeed: rootSeed.bytes)
    }

    func devicePublicKey() throws -> String {
        try deviceKey.publicExternalRepresentation().base58String
    }

    func decrypt(_ data: Data) throws -> Data {
        try deviceKey.decrypt(data: data)
    }

    func removeBootstrapKey() {
        SecureEnclaveWrapper.removeBootstrapKey(email: email)
    }
}

extension RegisteredDevice {
    func withAuthenticatedDevice(_ closure: @escaping (Result<RegisteredDevice, Error>) -> Void) {
        AuthenticatedKeys.withAuhenticatedKeys(from: email) { result in
            switch result {
            case .failure(let error):
                closure(.failure(error))
            case .success(let keys):
                var registeredDevice = RegisteredDevice(email: email, deviceKey: keys.deviceKey, encryptedRootSeed: encryptedRootSeed)
                registeredDevice.authenticationContext = keys.context
                closure(.success(registeredDevice))
            }
        }
    }
}

struct AuthenticatedKeys {
    enum AuthenticatedKeyError: Error {
        case keyNotFound
    }

    var context: LAContext
    var deviceKey: DeviceKey
    var bootstrapKey: BootstrapKey?

    static func withAuhenticatedKeys(from email: String, closure: @escaping (Result<AuthenticatedKeys, Error>) -> Void) {
        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Verify your identity") { success, error in
            if let error = error {
                closure(.failure(error))
            } else if let deviceKey = SecureEnclaveWrapper.deviceKey(email: email, authenticationContext: context) {
                let bootstrapKey = SecureEnclaveWrapper.bootstrapKey(email: email, authenticationContext: context)
                let registeredDevice = AuthenticatedKeys(context: context, deviceKey: deviceKey, bootstrapKey: bootstrapKey)
                closure(.success(registeredDevice))
                context.invalidate()
            } else {
                closure(.failure(AuthenticatedKeyError.keyNotFound))
            }
        }
    }
}
