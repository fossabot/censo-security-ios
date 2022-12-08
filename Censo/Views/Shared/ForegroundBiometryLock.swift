//
//  ForegroundBiometryLock.swift
//  Censo
//
//  Created by Ata Namvari on 2022-09-21.
//

import SwiftUI

struct ForegroundBiometryLockModifier: ViewModifier {
    @State private var inActive = false

    @StateObject private var biometryProtector = BiometryProtector()

    var onFailure: () -> Void

    func body(content: Content) -> some View {
        content
            .blur(radius: inActive ? 20 : 0)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                inActive = true
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                inActive = false
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                biometryProtector.captureBiometrics()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                if !biometryProtector.validateBiometrics() {
                    onFailure()
                }
            }
    }
}

class BiometryProtector: ObservableObject {
    static let keychainAccount = "_global"
    static let keychainService = "biometry"

    var uuid: UUID?

    init() {
        self.uuid = UUID()
    }

    func captureBiometrics() {
        let uuid = UUID()
        let data = uuid.uuidString.data(using: .utf8)!

        try? Keychain.save(account: Self.keychainAccount, service: Self.keychainService, data: data, synced: false, biometryProtected: true)

        self.uuid = uuid
    }

    func validateBiometrics() -> Bool {
        guard let storedUUIDData = try? Keychain.load(account: Self.keychainAccount, service: Self.keychainService, synced: false, biometryPrompt: "Identify Yourself"),
              let storedUUIDString = String(data: storedUUIDData, encoding: .utf8) else {
            return false
        }

        return UUID(uuidString: storedUUIDString) == self.uuid
    }
}

extension View {
    func foregroundBiometryProtected(onFailure: @escaping () -> Void) -> some View {
        modifier(ForegroundBiometryLockModifier(onFailure: onFailure))
    }
}
