//
//  RootView.swift
//  Strike
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
            .environment(\.strikeApi, StrikeApi(authProvider: nil, stubClosure: MoyaProvider.delayedStub(0.5)))
            .onFirstTimeAppear(perform: registerForRemoteNotifications)
    }
    #else

    @ObservedObject var authProvider: StrikeAuthProvider

    var body: some View {
        if authProvider.isAuthenticated {
            MainView(onSignOut: signOut)
                .environment(\.strikeApi, StrikeApi(authProvider: authProvider))
                .onFirstTimeAppear(perform: registerForRemoteNotifications)
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
