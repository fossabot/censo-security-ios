//
//  RegistrationView.swift
//  Strike
//
//  Created by Ata Namvari on 2021-04-01.
//

import Foundation
import SwiftUI

struct RegistrationView: View {
    @Environment(\.strikeApi) var strikeApi

    var user: StrikeApi.User
    var onReloadUser: () -> Void
    var onShowDApp: () -> Void

    var body: some View {
        let storedPublicKey = Keychain.publicKey(email: user.loginName)

        switch (storedPublicKey, user.publicKeys.first) {
        case (_, .none):
            KeyGeneration(user: user, onSuccess: onReloadUser)
        case (.none, .some):
            KeyRetrieval(user: user, onReloadUser: onReloadUser)
        case (.some(let storedPublicKey), .some(let remotePublicKey)) where storedPublicKey == remotePublicKey.key:
            ApprovalRequestsView(user: user)
                .navigationTitle("Approvals")
                .onFirstTimeAppear(perform: registerForRemoteNotifications)
        case (.some, .some):
            Text("Keys do not match, call support")
        }
    }

    private func registerForRemoteNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            guard granted else { return }

            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}

#if DEBUG
struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView(user: .sample, onReloadUser: { }, onShowDApp: { })
    }
}
#endif
