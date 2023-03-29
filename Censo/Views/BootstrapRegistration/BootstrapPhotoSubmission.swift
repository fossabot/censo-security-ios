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
            let privateKeys = try PrivateKeys(rootSeed: rootSeed)
            let devicePublicKey = try deviceKey.publicExternalRepresentation().base58String
            let signersInfo = try CensoApi.SignersInfo(publicKeys: privateKeys.publicKeys, deviceKey: deviceKey)

            let userDevice = CensoApi.UserDevice(
                publicKey: try deviceKey.publicExternalRepresentation().base58String,
                deviceType: .ios,
                userImage: CensoApi.UserImage(
                    image: imageData.base64EncodedString(),
                    type: .jpeg,
                    signature: try deviceKey.signature(for: Data(SHA256.hash(data: imageData))).base64EncodedString()
                ),
                replacingDeviceIdentifier: nil
            )

            let bootstrapDevice = CensoApi.BootstrapDevice(
                publicKey: try bootstrapKey.publicExternalRepresentation().base58String,
                signature: try bootstrapKey.signature(for: signersInfo.signers.dataToSign).base64EncodedString()
            )

            let bootstrapUserDeviceAndSigners = CensoApi.BootstrapUserDeviceAndSigners(
                userDevice: userDevice,
                bootstrapDevice: bootstrapDevice,
                signersInfo: signersInfo
            )

            inProgress = true

            censoApi.provider.request(.boostrapDeviceAndSigners(bootstrapUserDeviceAndSigners, devicePublicKey: devicePublicKey)) { result in
                inProgress = false

                switch result {
                case .failure(let error):
                    self.error = error
                    self.alertPresented = true
                case .success(let response) where response.statusCode < 400:
                    do {
                        try Keychain.saveRootSeed(rootSeed, email: email, deviceKey: deviceKey)

                        onSuccess()
                    } catch {
                        self.error = error
                        self.alertPresented = true
                    }
                case .success(let response):
                    self.error = MoyaError.statusCode(response)
                    self.alertPresented = true
                }
            }
        } catch {
            self.error = error
            self.alertPresented = true
        }

    }
}
