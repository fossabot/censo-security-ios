//
//  RootView.swift
//  Censo
//
//  Created by Ata Namvari on 2021-03-09.
//

import Foundation
import SwiftUI
import Moya

struct RootView: View {
    @ObservedObject var authProvider: CensoAuthProvider

    var body: some View {
        if let authenticatedState = authProvider.authenticatedState {
            SignedInNavigationView(onSignOut: signOut) {
                NotificationCheck(email: authenticatedState.token.email) {
                    MainView(registrationController: {
                        switch authenticatedState {
                        case .deviceAuthenticatedRegistered(let registeredDevice, _):
                            return DeviceRegistrationController(
                                email: authenticatedState.token.email,
                                authProvider: authProvider,
                                censoApi: CensoApi(authProvider: authProvider),
                                registeredDevice: registeredDevice
                            )
                        case .deviceAuthenticatedUnregistered(let deviceKey, _):
                            return DeviceRegistrationController(
                                email: authenticatedState.token.email,
                                authProvider: authProvider,
                                censoApi: CensoApi(authProvider: authProvider),
                                deviceKey: deviceKey
                            )
                        case .emailAuthenticated(let deviceKey, _):
                            return DeviceRegistrationController(
                                email: authenticatedState.token.email,
                                authProvider: authProvider,
                                censoApi: CensoApi(authProvider: authProvider),
                                deviceKey: deviceKey
                            )
                        }
                    }())
                    .foregroundBiometryProtected(onFailure: signOut)
                }
            }
            .environment(\.censoApi, CensoApi(authProvider: authProvider))
        } else {
            SignInView(authProvider: authProvider)
        }
    }

    private func signOut() {
        NotificationCenter.default.post(name: .userWillSignOut, object: nil)
        authProvider.invalidate()
    }
}

extension CensoAuthProvider.AuthenticatedState {
    var token: CensoAuthProvider.JWTToken {
        switch self {
        case .deviceAuthenticatedRegistered(_, let token):
            return token
        case .deviceAuthenticatedUnregistered(_, let token):
            return token
        case .emailAuthenticated(_, let token):
            return token
        }
    }
}

#if DEBUG
struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(authProvider: .init())
    }
}
#endif
