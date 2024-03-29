//
//  DevicePhotoSubmission.swift
//  Censo
//
//  Created by Ata Namvari on 2023-02-02.
//

import SwiftUI
import Moya
import CryptoKit
import LocalAuthentication

struct DevicePhotoSubmission: View {
    @Environment(\.censoApi) var censoApi

    @State private var inProgress = false
    @State private var alertPresented = false
    @State private var error: Error? = nil

    var uiImage: UIImage
    var deviceKey: DeviceKey
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

        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Verify your identity") { success, error in
            if let error = error {
                self.error = error
                self.alertPresented = true
            } else {
                do {
                    let oldDeviceIdentifier = try Keychain.oldDevicePublicKey(identifier: deviceKey.identifier)

                    let preauthenticatedDeviceKey = try deviceKey.preauthenticatedKey(context: context)
                    let userDevice = CensoApi.UserDevice(
                        publicKey: try deviceKey.publicExternalRepresentation().base58String,
                        deviceType: .ios,
                        userImage: CensoApi.UserImage(
                            image: imageData.base64EncodedString(),
                            type: .jpeg,
                            signature: try preauthenticatedDeviceKey.signature(for: Data(SHA256.hash(data: imageData))).base64EncodedString()
                        ),
                        replacingDeviceIdentifier: oldDeviceIdentifier?.base58String
                    )

                    inProgress = true

                    censoApi.provider.request(.registerDevice(userDevice, devicePublicKey: try deviceKey.publicExternalRepresentation().base58String)) { result in
                        inProgress = false

                        switch result {
                        case .failure(let error):
                            self.error = error
                            self.alertPresented = true
                        case .success(let response) where response.statusCode < 400:
                            Keychain.removeOldDevicePublicKey(identifier: deviceKey.identifier)
                            onSuccess()
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



    }
}
