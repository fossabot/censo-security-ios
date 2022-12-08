//
//  MainView.swift
//  Censo
//
//  Created by Ata Namvari on 2021-03-10.
//

import Foundation
import SwiftUI

struct MainView: View {
    @Environment(\.censoApi) var censoApi

    var onSignOut: () -> Void

    @RemoteResult private var user: CensoApi.User?

    init(onSignOut: @escaping () -> Void) {
        self.onSignOut = onSignOut
    }

    var body: some View {
        switch $user {
        case .idle:
            SignedInNavigationView(onSignOut: onSignOut) { _ in
                ProgressView()
                    .onAppear(perform: reload)
            }
        case .loading:
            SignedInNavigationView(onSignOut: onSignOut) { _ in
                ProgressView()
            }
        case .failure(let error):
            SignedInNavigationView(onSignOut: onSignOut) { _ in
                RetryView(error: error, action: reload)
            }
        case .success(let user):
            SignedInNavigationView(user: user, onSignOut: onSignOut) { onProfile in
                PublicKeysStorage(email: user.loginName) {
                    ProgressView()
                } success: { publicKeys, reloadPublicKeys in
                    RegistrationView(
                        user: user,
                        storedPublicKeys: publicKeys,
                        onReloadUser: reload,
                        onProfile: onProfile,
                        onReloadPublicKeys: reloadPublicKeys
                    )
                }
            }
        }
    }

    func reload() {
        _user.reload(using: censoApi.provider.loader(for: .verifyUser))
    }
}
