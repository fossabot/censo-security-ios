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
            MainView(email: jwtToken.email, onSignOut: signOut)
                .environment(\.censoApi, CensoApi(authProvider: authProvider))
                .onFirstTimeAppear(perform: registerForRemoteNotifications)
                .foregroundBiometryProtected(onFailure: signOut)
        } else {
            SignInView(authProvider: authProvider)
        }
    }

    private func signOut() {
        NotificationCenter.default.post(name: .userWillSignOut, object: nil)
        authProvider.invalidate()
    }
    #endif

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
