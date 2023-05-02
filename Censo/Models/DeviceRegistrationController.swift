//
//  DeviceRegistrationController.swift
//  Censo
//
//  Created by Ata Namvari on 2023-04-24.
//

import Foundation
import Moya
import raygun4apple
import LocalAuthentication

class DeviceRegistrationController: ObservableObject {

    enum DeviceState {
        case needsToRegister(DeviceKey)
        case registered(device: RegisteredDevice)
    }

    var email: String
    @Published private(set) var state: DeviceState
    var authProvider: CensoAuthProvider
    var censoApi: CensoApi

    enum RegistrationError: Error {
        case conflict
    }

    init(email: String, authProvider: CensoAuthProvider, censoApi: CensoApi, registeredDevice: RegisteredDevice) {
        self.email = email
        self.authProvider = authProvider
        self.censoApi = censoApi
        self.state = .registered(device: registeredDevice)
    }

    init(email: String, authProvider: CensoAuthProvider, censoApi: CensoApi, deviceKey: DeviceKey) {
        self.email = email
        self.authProvider = authProvider
        self.censoApi = censoApi
        self.state = .needsToRegister(deviceKey)
    }

    func completeRegistration(with registeredDevice: RegisteredDevice) {
        state = .registered(device: registeredDevice)
    }

    func recover(deviceKey: DeviceKey, registeredPublicKeys: [PublicKey], completion: @escaping (Result<RegisteredDevice, Error>) -> Void) {
        let bootstrapKey = try? deviceKey.bootstrapKey()
        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Verify your identity") { [authProvider, censoApi, email] success, error in
            if let error = error {
                completion(.failure(error))
            } else if let authenticatedDeviceKey = try? deviceKey.preauthenticatedKey(context: context) {
                let bootstrapKey = try? bootstrapKey?.preauthenticatedKey(context: context)

                _Concurrency.Task {
                    do {
                        try await authProvider.exchangeTokenIfNeeded(deviceKey: authenticatedDeviceKey)

                        let response: CensoApi.RecoveryShardsResponse = try await censoApi.provider.request(.recoveryShards(deviceIdentifier: try! deviceKey.publicExternalRepresentation().base58String))
                        let recoveredRootSeed = try ShardRecovery.recoverRootSeed(recoverShardResponse: response, deviceKey: authenticatedDeviceKey, bootstrapKey: bootstrapKey)
                        let encryptedRootSeed = try authenticatedDeviceKey.encrypt(data: Data(recoveredRootSeed))
                        let publicKeys = try PrivateKeys(rootSeed: recoveredRootSeed).publicKeys

                        try registeredPublicKeys.validateRootSeed(recoveredRootSeed)
                        try Keychain.saveEncryptedRootSeed(encryptedRootSeed, email: email)

                        await MainActor.run {
                            completion(.success(
                                    RegisteredDevice(
                                        email: email,
                                        deviceKey: deviceKey,
                                        encryptedRootSeed: encryptedRootSeed,
                                        publicKeys: publicKeys
                                    )
                                )
                            )
                        }
                    } catch {
                        RaygunClient.sharedInstance().send(error: error, tags: ["recovery-error"], customData: nil)

                        await MainActor.run {
                            completion(.failure(error))
                        }
                    }
                }
            } else {
                completion(.failure(PreauthSecureEnclaveKeyError.keyNoLongerExists))
            }
        }
    }

    func register(rootSeed: [UInt8], deviceKey: DeviceKey, bootstrapKey: BootstrapKey, imageData: Data, completion: @escaping (Result<RegisteredDevice, Error>) -> Void) {
        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Verify your identity") { [authProvider, censoApi, email] success, error in
            if let error = error {
                completion(.failure(error))
            } else if let authenticatedDeviceKey = try? deviceKey.preauthenticatedKey(context: context), let authenticatedBootstrapKey = try? bootstrapKey.preauthenticatedKey(context: context) {

                _Concurrency.Task {
                    do {
                        let devicePublicKeyData = try deviceKey.publicExternalRepresentation()
                        let devicePublicKey = devicePublicKeyData.base58String

                        let bootstrapUserDeviceAndSigners = try CensoApi.BootstrapUserDeviceAndSigners(
                            imageData: imageData,
                            deviceKey: authenticatedDeviceKey,
                            bootstrapKey: authenticatedBootstrapKey,
                            rootSeed: rootSeed
                        )

                        let publicKeys = try PrivateKeys(rootSeed: rootSeed).publicKeys
                        let encryptedRootSeed = try authenticatedDeviceKey.encrypt(data: Data(rootSeed))

                        let response = try await censoApi.provider.request(.boostrapDeviceAndSigners(bootstrapUserDeviceAndSigners, devicePublicKey: devicePublicKey))

                        if response.statusCode < 400 {
                            try Keychain.saveEncryptedRootSeed(encryptedRootSeed, email: email)

                            try await authProvider.exchangeTokenIfNeeded(deviceKey: authenticatedDeviceKey)

                            await MainActor.run {
                                completion(.success(
                                    RegisteredDevice(
                                        email: email,
                                        deviceKey: deviceKey,
                                        encryptedRootSeed: encryptedRootSeed,
                                        publicKeys: publicKeys
                                    )
                                )
                                )
                            }
                        } else {
                            await MainActor.run {
                                completion(.failure(MoyaError.statusCode(response)))
                            }
                        }
                    } catch {
                        print(error)
                        await MainActor.run {
                            completion(.failure(error))
                        }
                    }
                }
            } else {
                completion(.failure(PreauthSecureEnclaveKeyError.keyNoLongerExists))
            }
        }
    }

    func register(rootSeed: [UInt8], shardingPolicy: ShardingPolicy, deviceKey: DeviceKey, completion: @escaping (Result<RegisteredDevice, Error>) -> Void) {
        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Verify your identity") { [authProvider, censoApi, email] success, error in
            if let error = error {
                completion(.failure(error))
            } else if let authenticatedDeviceKey = try? deviceKey.preauthenticatedKey(context: context) {

                _Concurrency.Task {
                    do {
                        try await authProvider.exchangeTokenIfNeeded(deviceKey: authenticatedDeviceKey)

                        let signersInfo = try CensoApi.SignersInfo(
                            shardingPolicy: shardingPolicy,
                            rootSeed: rootSeed,
                            deviceKey: authenticatedDeviceKey
                        )

                        let publicKeys = try PrivateKeys(rootSeed: rootSeed).publicKeys
                        let encryptedRootSeed = try authenticatedDeviceKey.encrypt(data: Data(rootSeed))

                        let response = try await censoApi.provider.request(.addWalletSigners(signersInfo, devicePublicKey: try deviceKey.publicExternalRepresentation().base58String))

                        if response.statusCode == 409 {
                            await MainActor.run {
                                completion(.failure(RegistrationError.conflict))
                            }
                        } else if response.statusCode < 400 {
                            try Keychain.saveEncryptedRootSeed(encryptedRootSeed, email: email)

                            await MainActor.run {
                                completion(.success(
                                        RegisteredDevice(
                                            email: email,
                                            deviceKey: deviceKey,
                                            encryptedRootSeed: encryptedRootSeed,
                                            publicKeys: publicKeys
                                        )
                                    )
                                )
                            }
                        } else {
                            RaygunClient.sharedInstance().send(error: MoyaError.statusCode(response), tags: ["registration-error"], customData: nil)

                            await MainActor.run {
                                completion(.failure(MoyaError.statusCode(response)))
                            }
                        }
                    } catch {
                        RaygunClient.sharedInstance().send(error: error, tags: ["registration-error"], customData: nil)

                        await MainActor.run {
                            completion(.failure(error))
                        }
                    }
                }
            } else {
                completion(.failure(PreauthSecureEnclaveKeyError.keyNoLongerExists))
            }
        }
    }
}
