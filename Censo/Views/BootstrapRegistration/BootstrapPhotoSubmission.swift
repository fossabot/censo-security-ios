//
//  BootstrapPhotoSubmission.swift
//  Censo
//
//  Created by Ata Namvari on 2023-03-28.
//

import SwiftUI
import Moya
import CryptoKit
import BIP39

struct BootstrapPhotoSubmission: View {
    @Environment(\.censoApi) var censoApi

    @State private var phrase = Mnemonic(strength: 256).phrase
    @State private var inProgress = false
    @State private var alertPresented = false
    @State private var error: Error? = nil

    var email: String
    var uiImage: UIImage
    var deviceKey: DeviceKey
    var bootstrapKey: BootstrapKey
    var registrationController: DeviceRegistrationController
    var onSuccess: () -> Void
    var onRetake: () -> Void

    var body: some View {
        Group {
            if inProgress {
                CensoProgressView(text: "Registering your device...")
            } else {
                VStack(spacing: 40) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)

                    Button {
                        submitPhoto()
                    } label: {
                        Text("Use Photo")
                    }

                    Button {
                        onRetake()
                    } label: {
                        Text("Retake")
                    }
                }
                .buttonStyle(FilledButtonStyle())
            }
        }
        .alert("Error", isPresented: $alertPresented, presenting: error, actions: { _ in
            Button("OK", action: { })
        }, message: { error in
            Text(error.localizedDescription)
        })
    }

    private func submitPhoto() {
        let imageData = uiImage.jpegData(compressionQuality: 1) ?? Data()

        do {
            let rootSeed = try Mnemonic(phrase: phrase).seed

            inProgress = true

            registrationController.register(rootSeed: rootSeed, deviceKey: deviceKey, bootstrapKey: bootstrapKey, imageData: imageData) { result in
                inProgress = false

                switch result {
                case .success(let registeredDevice):
                    registrationController.completeRegistration(with: registeredDevice)
                    onSuccess()
                case .failure(let error):
                    self.error = error
                    self.alertPresented = true
                }
            }
        } catch {
            self.error = error
            self.alertPresented = true
        }
    }
}

extension CensoApi.BootstrapUserDeviceAndSigners {
    init(imageData: Data, deviceKey: PreauthenticatedKey<DeviceKey>, bootstrapKey: PreauthenticatedKey<BootstrapKey>, rootSeed: [UInt8]) throws {
        self.userDevice = CensoApi.UserDevice(
            publicKey: try deviceKey.key.publicExternalRepresentation().base58String,
            deviceType: .ios,
            userImage: CensoApi.UserImage(
                image: imageData.base64EncodedString(),
                type: .jpeg,
                signature: try deviceKey.signature(for: Data(SHA256.hash(data: imageData))).base64EncodedString()
            ),
            replacingDeviceIdentifier: nil
        )

        let shardingPolicy = try ShardingPolicy(deviceKey: deviceKey, bootstrapKey: bootstrapKey)

        self.signersInfo = try CensoApi.SignersInfo(
            shardingPolicy: shardingPolicy,
            rootSeed: rootSeed,
            deviceKey: deviceKey
        )

        self.bootstrapDevice = CensoApi.BootstrapDevice(
            publicKey: try bootstrapKey.key.publicExternalRepresentation().base58String,
            signature: try bootstrapKey.signature(for: signersInfo.signers.dataToSign).base64EncodedString()
        )
    }
}
