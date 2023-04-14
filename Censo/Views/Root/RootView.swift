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
    #if STUBBED
    var body: some View {
        MainView(onSignOut: {})
            .environment(\.censoApi, CensoApi(authProvider: nil, stubClosure: MoyaProvider.delayedStub(0.5)))
            .onFirstTimeAppear(perform: registerForRemoteNotifications)
            .foregroundBiometryProtected(onFailure: {})
    }
    #else

    @ObservedObject var authProvider: CensoAuthProvider

    var body: some View {
        if let jwtToken = authProvider.storedJWTToken {
            SignedInNavigationView(onSignOut: signOut) {
                NotificationCheck(email: jwtToken.email) {
                    MainView(email: jwtToken.email, authProvider: authProvider, onSignOut: signOut)
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
    #endif
}


#if DEBUG
struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        #if STUBBED
        RootView()
        #else
        RootView(authProvider: .init())
        #endif
    }
}
#endif
