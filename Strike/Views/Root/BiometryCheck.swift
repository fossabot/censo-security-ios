//
//  BiometryCheck.swift
//  Strike
//
//  Created by Ata Namvari on 2021-11-19.
//

import SwiftUI
import LocalAuthentication

private let keychainAccount = "_global"
private let keychainService = "_tempBiometry"

struct BiometryCheck<V>: ViewModifier where V : View {
    @State private var biometryEnabled = LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)

    @AppStorage("permissionAsked") private var permissionAsked = false

    private let appForegroundedPublisher = NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)

    var lockedView: () -> V

    func body(content: Content) -> some View {
        ZStack {
            content

            if !biometryEnabled {
                ZStack {
                    Color.black.ignoresSafeArea()

                    lockedView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .onReceive(appForegroundedPublisher) { _ in
            biometryEnabled = LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        }
        .onAppear {
            DispatchQueue.main.async {
                if !permissionAsked {
                    let uuid = UUID()
                    let data = uuid.uuidString.data(using: .utf8)!

                    Keychain.save(account: keychainAccount, service: keychainService, data: data, biometryProtected: true)

                    if let storedUUIDData = Keychain.load(account: keychainAccount, service: keychainService, synced: false, biometryPrompt: "Identify Yourself"), let storedUUIDString = String(data: storedUUIDData, encoding: .utf8), UUID(uuidString: storedUUIDString) == uuid {
                        permissionAsked = true
                    } else {
                        biometryEnabled = false
                    }
                }
            }
        }
    }
}

extension View {
    func lockedByBiometry<V>(@ViewBuilder lockedView: @escaping () -> V) -> some View where V : View {
        modifier(BiometryCheck(lockedView: lockedView))
    }
}

struct Locked: View {
    var biometryType: String {
        switch LAContext().biometryType {
        case .faceID:
            return "Face ID"
        default:
            return "Touch ID"
        }
    }

    var biometryIcon: Image {
        switch LAContext().biometryType {
        case .faceID:
            return Image(systemName: "faceid")
        default:
            return Image(systemName: "touchid")
        }
    }

    var body: some View {
        VStack {
            Spacer()
            Spacer()
            
            Image("Logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 44)
                .padding(20)

            biometryIcon
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .foregroundColor(.Strike.purple)
                .padding()

            Text("Biometry Required")
                .font(.title2)
                .padding()

            Spacer()

            if LAContext().biometryType == .none {
                Text("We're sorry. The Strike Mobile App requirs biometric authentication for security purposes and your device does not support biometric authentication")
            } else {
                Text("The Strike Mobile App requires \(biometryType) to be enabled for security purposes.")
                    .multilineTextAlignment(.leading)
                    .padding()

                Button {
                    goToAppSettings()
                } label: {
                    Text("Enable in Settings")
                        .frame(maxWidth: .infinity)
                }
                .padding(30)
                .buttonStyle(FilledButtonStyle())
            }

            Spacer()
        }
    }

    func goToAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}
